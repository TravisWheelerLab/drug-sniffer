#!/usr/bin/env python
import time
import sys
import os
import glob
import argparse
from datetime import datetime
from rdkit import Chem
from rdkit.Chem import AllChem


def bitstring_to_bytes(s):
    # https://stackoverflow.com/questions/32675679/convert-binary-string-to-bytearray-in-python-3
    return int(s, 2).to_bytes((len(s) + 7) // 8, byteorder="big")


def parseArgs(sysArgs):
    parser = argparse.ArgumentParser(sysArgs)
    parser.add_argument("smiles_dir", help="Path to directory of input .smi files")
    parser.add_argument(
        "fingerprint_dir",
        help="Path where output fingerprints will be saved. Fingerprint file name will be based on input file name (i.e. SMILES file x.smi will yield x.fpt. Output format is: a binary file containing, for each smiles entry, [numbits]/8 bytes; all binary data is consecutive. Note that when fingerprinting fails, no binary output is created",
    )
    parser.add_argument(
        "index_dir",
        help="Path where where lookup index will be saved. Index file name will be based on input file name (i.e. SMILES file x.smi will yield x.index). When fingerprint is produced for a smiles entry, a 64-bit int value is written that indicates the offset of the current record in the smiles file ",
    )
    parser.add_argument(
        "skipped_dir",
        help="Path to directory where SMILES unable to be kekulized will be saved",
    )
    parser.add_argument(
        "--num_bits",
        type=int,
        default=1024,
        help="Length of output bit vector fingerprint",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print information such as input parameters, date run, time to process, NumPy Array length, total files fingerprinted",
    )

    return parser.parse_args()


def main():
    # parse command line arguments
    args = parseArgs(sys.argv[1:])
    smilesDir = args.smiles_dir
    fingerprintDir = args.fingerprint_dir
    indexDir = args.index_dir
    skippedSmiDir = args.skipped_dir
    numBits = args.num_bits
    verbose = args.verbose

    # grab all files in smile dir, then grab file corresponding to job number
    smilesList = sorted(glob.glob("%s/*.smi" % smilesDir))

    for smilesFilePath in smilesList:
        # generate fingerprint file path, based on input file name
        baseFilePath = os.path.splitext(smilesFilePath)[0]
        pathList = baseFilePath.split("/")
        baseFileName = pathList[-1]
        fingerprintFilePath = "%s/%s.fpt" % (fingerprintDir, baseFileName)
        indexFilePath = "%s/%s.index" % (indexDir, baseFileName)

        # generate skipped SMILES file path, based on input file name
        skippedSmilesFilePath = "%s/%s.skip.smi" % (skippedSmiDir, baseFileName)

        # iterate through lines in file
        with open(smilesFilePath, "r") as inputFile, open(
            fingerprintFilePath, "wb"
        ) as fingerprintFile, open(indexFilePath, "wb") as indexFile, open(
            skippedSmilesFilePath, "w"
        ) as skippedFile:
            start = time.time()
            actualFingerprints = 0
            iteration = 0
            input_byte_count = 0

            if verbose:
                print(
                    "Date and time run: %s"
                    % datetime.now().strftime("%d-%m-%Y %H:%M:%S")
                )
                print("Number of bits: %d" % numBits)
                print("Selected SMILES file: %s" % smilesFilePath)
                print("Output fingerprint file: %s" % fingerprintFilePath)
                print("Output index file: %s" % indexFilePath)
                print("Output skipped SMILES file: %s" % skippedSmilesFilePath)

            for iteration, line in enumerate(inputFile):
                iteration = iteration
                prev_byte_count = input_byte_count
                input_byte_count += len(line)
                # convert to molecule object
                # (smile, name) = line.split(maxsplit=1)
                if not line.strip():
                    continue

                smile = line.split()[0]
                mol = Chem.MolFromSmiles(smile)

                # if line doesn't convert nicely, skip SMILES entry, write skipped line to skippedFile:
                if mol is None:
                    # print("I'm skipping")
                    skippedFile.write(line)
                    continue

                # else, generate ECFP4 fingerprint ExplicitBitVect object
                bitVect = AllChem.GetMorganFingerprintAsBitVect(mol, 2, nBits=numBits)
                actualFingerprints += 1
                # then convert to NumPy Array and save array to fingerprintFile:
                s = bitVect.ToBitString()
                # print(s)
                bits_as_bytes = bitstring_to_bytes(s)
                fingerprintFile.write(bytearray(bits_as_bytes))
                # print(npArray)
                # Store the byte offset of this fingerprint's corresponding record in the input SMILES file as a 64 bit integer in the index file.
                bin_input_byte_count = prev_byte_count.to_bytes(
                    8, byteorder="big", signed=False
                )
                indexFile.write(bin_input_byte_count)

            end = time.time()

            inputFile.close
            fingerprintFile.close
            skippedFile.close
            indexFile.close

            if verbose:
                print(
                    "Total time to process %d lines: %lf seconds"
                    % (iteration + 1, (end - start))
                )
                print("Actual molecules fingerprinted: %d" % actualFingerprints)

            print("Success")


if __name__ == "__main__":
    main()
