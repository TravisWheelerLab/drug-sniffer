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

smi=$(cat "$LIGAND_SMI")
echo "$smi" > ligand.smi
echo -n "$smi\t" >> admet.txt

for check in $ADMET_CHECKS; do
    runadmet.sh -f ligand.smi -p "$check" -a
    awk 'NR!=1 {printf "%s\t%s\t%s\t",2,3,4}' /opt/fpadmet/RESULTS/predicted.txt >> admet.txt
done

# JLogP - remove the output file in case we're running a test and the last run
# already created one
rm -f jlogp.txt
java -jar /opt/JLogP/build/JLogP.jar ligand.smi jlogp.txt
awk '{print $2}' jlogp.txt >> admet.txt

rm -f ligand.smi jlogp.txt

