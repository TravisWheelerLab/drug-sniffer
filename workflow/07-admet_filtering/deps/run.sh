#!/usr/bin/env bash

set -e

# Required parameters:
#
# LIGANDS_SMI
#
# Optional parameters:
#
# ADMET_CHECKS
# OUTPUT_FILE
#

OUTPUT_FILE=${OUTPUT_FILE:-output.txt}

cat "$LIGANDS_SMI" | while read smi
do
    echo "$smi" > ligand.smi
    echo -n "$smi," >> "$OUTPUT_FILE"
    for check in $ADMET_CHECKS; do
        runadmet.sh -f ligand.smi -p "$check" -a
        awk 'NR!=1 {printf "%s,%s,%s,",2,3,4}' /opt/fpadmet/RESULTS/predicted.txt >> "$OUTPUT_FILE"
    done

    rm -f jlogp.txt
    java -jar /opt/JLogP/build/JLogP.jar ligand.smi jlogp.txt
    awk '{print $2}' jlogp.txt >> "$OUTPUT_FILE"
done

rm -f ligand.smi jlogp.txt

