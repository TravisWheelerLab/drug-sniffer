#!/usr/bin/env python3

# Combines output from dock2bind with the input SMI string
# We do this so we don't have to worry about newlines and such
# Usage: combine.py <smi> <score>

def main(args):
    smi_path = args[0]
    score_path = args[1]

    smi = open(smi_path, "r").read().strip()
    score = open(score_path, "r").read().strip()

    print(f"{smi}\t{score}")


if __name__ == "__main__":
    import sys
    main(sys.argv[1:])
