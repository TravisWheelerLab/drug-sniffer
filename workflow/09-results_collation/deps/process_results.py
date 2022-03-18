#!/usr/bin/env python3

from argparse import ArgumentParser


def main(args):
    parser = ArgumentParser(
        "process_results.py",
        description="A script to process Drug Sniffer results",
    )

    parser.add_argument("--ligand-score")
    parser.add_argument("--admet-output")

    options = parser.parse_args(args)

    score_file = open(options.ligand_score, "r")
    admet_file = open(options.admet_output, "r")

    for score, admet in zip(score_file, admet_file):
        print(f"{score.strip()},{admet.strip()}")

    score_file.close()
    admet_file.close()


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
