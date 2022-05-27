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
# Outputs:
#
# admet.txt
#

for check in $ADMET_CHECKS; do
    runadmet.sh -f "$LIGAND_SMI" -p "$check" -a

    # For debugging
    cp /opt/fpadmet/RESULTS/fps.txt fps.txt

    cp /opt/fpadmet/RESULTS/predicted.txt predicted.txt

    awk 'NR!=1 {printf "%s\t%s\t%s\t",$2,$3,$4}' predicted.txt >> _admet.txt
done

# JLogP - remove the output file in case we're running a test and the last run
# already created one
rm -f jlogp.txt
java -jar /opt/JLogP/build/JLogP.jar "$LIGAND_SMI" jlogp.txt
awk '{print $2}' jlogp.txt >> _admet.txt

combine_admet.py "$LIGAND_SMI" _admet.txt > admet.txt
