#!/usr/bin/env bash

set -e

# Required parameters:
#
# LIGAND_SMI
#
# Optional parameters:
#
# ADMET_CHECKS
#

for check in ADMET_CHECKS; do
    runadmet.sh -f "$LIGAND_SMI" -p "$check" -a
done

java -jar /opt/admet_filtering/JLogP.jar "$LIGAND_SMI" jlogp.txt
