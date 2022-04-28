#!/usr/bin/env python3

# Combines output from FPADMET with the input SMI string
# We do this so we don't have to worry about newlines and such
# Usage: combine.py <smi> <admet>

def main(args):
    smi_path = args[0]
    admet_path = args[1]

    smi = open(smi_path, "r").read().strip()
    admet = open(admet_path, "r").read().strip()

    print(f"{smi}\t{admet}")


if __name__ == "__main__":
    import sys
    main(sys.argv[1:])
