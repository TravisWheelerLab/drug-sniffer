#!/usr/bin/env python3

from argparse import ArgumentParser


def main(args):
    parser = ArgumentParser(
        "process_errors.py",
        description="A script to collate Drug Sniffer errors",
    )

    parser.add_argument("--protein-ligand-docking", required=True)
    parser.add_argument("--activity-prediction", required=True)

    options = parser.parse_args(args)

    print("Drug Sniffer Error Report")
    print("")

    with open(options.protein_ligand_docking) as file:
        print_group("Stage 6 - protein-ligand docking", file)
    
    with open(options.activity_prediction) as file:
        print_group("Stage 7 - activity prediction", file)


def print_group(name, file):
    print(name)
    print("")

    count = 0
    for line in (l for l in file if l != ""):
        print(f"    {line}", end="")
        count += 1
    if count == 0:
        print("    no errors")

    print("")


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
