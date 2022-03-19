#!/usr/bin/env python3

from argparse import ArgumentParser


def main(args):
    parser = ArgumentParser(
        "process_results.py",
        description="A script to process Drug Sniffer results",
    )

    parser.add_argument("--ligand-score")
    parser.add_argument("--admet-output")
    parser.add_argument("--admet-checks")

    options = parser.parse_args(args)

    headers = [
        "pose",
        "chemical name",
        "docked file",
        "dock2bind score",
    ]
    for check in options.admet_checks.split():
        headers.append(f"predicted {check}")
        headers.append(f"confidence {check}")
        headers.append(f"credibility {check}")
    headers.append("jlogp")

    print(",".join(headers))

    score_file = open(options.ligand_score, "r")
    admet_file = open(options.admet_output, "r")

    for score, admet in zip(score_file, admet_file):
        print(f"{score.strip()},{admet.strip()}")

    score_file.close()
    admet_file.close()


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
