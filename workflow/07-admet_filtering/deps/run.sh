#!/usr/bin/env bash

set -e

# Required parameters:
#
# LIGAND_SMI
#
# Optional parameters:
#
# ADMET_CHECKS
# OUTPUT_FILE
#

OUTPUT_FILE=${OUTPUT_FILE:-output.txt}

for check in ADMET_CHECKS; do
    runadmet.sh -f "$LIGAND_SMI" -p "$check" -a
    echo -n "${check}_predicted,${check}_confidence,${check}_credibility," >> headers.csv
    awk 'NR!=1 {printf "%s,%s,%s,",2,3,4}' /opt/fpadmet/RESULTS/predicted.txt >> "_$OUTPUT_FILE"
done

# TODO: Now append jlogp value(s) to the end of each and then we just cat the two temp files into OUTPUT_FILE

java -jar /opt/admet_filtering/JLogP.jar "$LIGAND_SMI" jlogp.txt
echo "jlogp" >> headers.csv
awk '{print $2}' jlogp.txt >> "_$OUTPUT_FILE"
cat headers.csv "_$OUTPUT_FILE" > "$OUTPUT_FILE"
