#!/usr/bin/env python3

from argparse import ArgumentParser
from sys import argv, stdout


def main():
    parser = ArgumentParser(
        "dedup.py",
        description="Like cat, but removes duplicates",
    )
    parser.add_argument(
        "-o", "--output",
        default="",
        metavar="OUTPUT",
        help="File to write output to",
    )
    parser.add_argument(
        "files",
        metavar="FILES",
        help="Files to cat and dedup",
        nargs="+",
    )

    args = parser.parse_args(argv[1:])

    output = args.output
    paths = args.files

    lines = set()
    for path in paths:
        with open(path, "r") as file:
            for line in file:
                lines.add(line)
    
    if output:
        output_file = open(output, "w")
    else:
        output_file = stdout

    for line in sorted(lines):
        output_file.write(line)


if __name__ == "__main__":
    main()
