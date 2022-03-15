#!/usr/bin/env python3

from argparse import ArgumentParser
from glob import glob
from os import path
import os
from subprocess import run
from tempfile import NamedTemporaryFile, TemporaryDirectory
from typing import Iterable, List, NamedTuple

from rdkit import Chem  # type: ignore
from rdkit.Chem import AllChem  # type: ignore


LIGAND_INDEX = 0


class DenovoLigand:
    __slots__ = ["index", "smi_str", "fpt"]

    index: int
    smi_str: str
    fpt: bytes

    def __init__(self, smi_str: str):
        global LIGAND_INDEX

        self.index = LIGAND_INDEX
        LIGAND_INDEX += 1

        self.smi_str = smi_str
        self.fpt = bytes()


class Neighbor(NamedTuple):
    ligand: DenovoLigand
    ligand_fpt_path: str
    ligand_index: int
    db_fpt_path: str
    db_index: int

    @property
    def db_index_path(self) -> str:
        pieces = self.db_fpt_path.split(os.sep)
        name_pieces = pieces[-1].split(".")

        db_path = os.sep.join(pieces[:-2])
        name = ".".join(name_pieces[:-1])

        return f"{db_path}/indexes/{name}.index"

    @property
    def db_smi_path(self) -> str:
        pieces = self.db_fpt_path.split(os.sep)
        name_pieces = pieces[-1].split(".")

        db_path = os.sep.join(pieces[:-2])
        name = ".".join(name_pieces[:-1])

        return f"{db_path}/splits/{name}.smi"


class DBLigand(NamedTuple):
    smi_str: str
    db_src: str
    neighbor: Neighbor


def main(args: List[str]):
    parser = ArgumentParser(
        "similarity.py",
        description="determine similarity to a molecule database for a given ligand",
    )
    parser.add_argument(
        "ligands_smi",
        help="a file containing the SMILES strings for each denovo ligand",
        metavar="SMI",
    )
    parser.add_argument(
        "--tanimoto",
        "-t",
        default=0.5,
        type=float,
        help="minimum Tanimoto value for a match",
        metavar="FLOAT",
    )
    parser.add_argument(
        "--db-dir",
        "-d",
        required=True,
        help="a directory containing a fingerprint database (fingerprints, indexes, splits)",
        metavar="DB",
    )
    parser.add_argument(
        "--out-dir",
        "-o",
        default=".",
        help="directory to write .smi output files to",
        metavar="OUT",
    )
    options = parser.parse_args(args)

    denovo_ligands = load_ligands(options.ligands_smi)
    fingerprint_ligands(denovo_ligands)
    neighbors = find_ligand_neighbors(denovo_ligands, options.db_dir, options.tanimoto)
    db_ligands = fetch_neighbors(neighbors, options.db_dir)

    index = 0
    for db_ligand in db_ligands:
        with open(f"{options.out_dir}/{index}.smi", "w") as out_file:
            out_file.write(
                f"{db_ligand.smi_str} {db_ligand.db_src} {db_ligand.neighbor.db_index}\n"
            )
        index += 1


def load_ligands(ligands_smi: str) -> List[DenovoLigand]:
    """
    Load denovo ligands from the given .smi file.

    >>> ls = load_ligands("test/denovo.smi")
    >>> ls[0].smi_str
    'C=C[C@](C)(O)CNCc1cn(CC2CC2)nn1\\t(Gen_3_Cross_449571+ZINC001252572940)Gen_10_Mutant_48_356978'
    >>> len(ls)
    150
    """
    ligands = []
    with open(ligands_smi, "r") as smi_file:
        for smi_str in smi_file:
            ligands.append(DenovoLigand(smi_str.strip()))
    return ligands


def fingerprint_ligands(ligands: Iterable[DenovoLigand]) -> None:
    """
    Fingerprint the given ligands and return the path to a directory
    containing the resulting .fpt files. Also updates the DenovoLigand
    instances with their fingerprints.

    >>> l = DenovoLigand('C#N')
    >>> l.fpt
    b''
    >>> fingerprint_ligands([l])
    >>> len(l.fpt)
    128
    >>> l.fpt
    b'\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x80\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00@\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x10\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00'
    """
    for ligand in ligands:
        smi_str = ligand.smi_str
        mol = Chem.MolFromSmiles(smi_str)
        if mol is None:
            continue

        bit_vec = AllChem.GetMorganFingerprintAsBitVect(mol, 2, nBits=1024)
        bit_str = bit_vec.ToBitString()
        byte_str = bitstring_to_bytes(bit_str)

        ligand.fpt = byte_str


def find_ligand_neighbors(
    ligands: List[DenovoLigand],
    db_dir: str,
    tanimoto: float,
) -> Iterable[Neighbor]:
    ligands_fpts = NamedTemporaryFile("wb")
    for ligand in ligands:
        ligands_fpts.write(ligand.fpt)
    ligands_fpts.flush()

    db_list = NamedTemporaryFile("w")
    for fpt_path in glob(f"{db_dir}/fingerprints/*.fpt"):
        db_list.write(f"{fpt_path}\n")
    db_list.flush()

    proc = run(
        [
            "neighbors",
            ligands_fpts.name,
            db_list.name,
            str(tanimoto),
        ],
        capture_output=True,
        text=True,
    )

    ligands_fpts.close()
    db_list.close()

    for line in proc.stdout.split("\n"):
        if not line.strip():
            continue

        pieces = line.split()
        ligand_index = int(pieces[1])
        yield Neighbor(
            ligands[ligand_index],
            pieces[0],
            ligand_index,
            pieces[2],
            int(pieces[3]),
        )


def fetch_neighbors(neighbors: Iterable[Neighbor], db_dir: str) -> Iterable[DBLigand]:
    """
    Use the given neighbors to look up and return a list of corresponding
    SMILES strings from the database.

    TODO: Re-use open files if possible
    """
    for neighbor in neighbors:
        smi_file = open(neighbor.db_smi_path, "r")
        index_file = open(neighbor.db_index_path, "rb")

        index_file.seek(neighbor.db_index * 8)
        index_value = index_file.read(8)

        smi_offset = int.from_bytes(index_value, "big")
        smi_file.seek(smi_offset)
        smi_line = smi_file.readline()
        (smi_str, db_src, _db_id) = smi_line.split()

        yield DBLigand(smi_str, db_src, neighbor)

        smi_file.close()
        index_file.close()


def bitstring_to_bytes(bit_str: str):
    return int(bit_str, 2).to_bytes((len(bit_str) + 7) // 8, byteorder="big")


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
