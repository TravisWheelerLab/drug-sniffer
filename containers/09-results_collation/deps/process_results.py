#!/usr/bin/env python3

from argparse import ArgumentParser


def main(args):
    parser = ArgumentParser(
        "process_results.py",
        description="A script to process Drug Sniffer results",
    )

    parser.add_argument("--ligand-smi")
    parser.add_argument("--ligand-score")
    parser.add_argument("--admet-output")
    parser.add_argument("--admet-checks")

    options = parser.parse_args(args)

    headers = [
        "pose",
        "chemical name",
        "chemical database",
        "smiles",
        "dock2bind score",
    ]
    for check in options.admet_checks.split():
        headers.append(f"predicted {check}")
        headers.append(f"confidence {check}")
        headers.append(f"credibility {check}")
    headers.append("logp")

    print("\t".join(headers))

    ligand_file = open(options.ligand_smi, "r")
    score_file = open(options.ligand_score, "r")
    admet_file = open(options.admet_output, "r")

    for ligand, score, admet in zip(ligand_file, score_file, admet_file):
        smi, db, name, _ = ligand.split("\t")
        pose, value = score.split("\t")

        print("\t".join([
            pose.strip(),
            name.strip(),
            db.strip(),
            smi.strip(),
            value.strip(),
            admet.strip(),
        ]))

    score_file.close()
    admet_file.close()


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
