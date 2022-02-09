#!/usr/bin/env sh

set -e

# Parameters below must be set in the environment, they are described in the
# pipeline documentation.
#
# RECEPTOR_PATH
# CENTER_X
# CENTER_Y
# CENTER_Z
# SIZE_X
# SIZE_Y
# SIZE_Z
#
# Optional parameters below may be set but they have reasonable defaults built
# into the container image.
#
# SOURCE_COMPOUND_FILE
# DOCKING_EXHAUSTIVENESS
# NUMBER_OF_PROCESSORS

FULL_RECEPTOR_PATH=$(realpath "$RECEPTOR_PATH")
ORIG_PWD="$PWD"

# TODO: Does number of processors even make sense given that we have to set it in nextflow?

cd /opt/autogrow4 && python RunAutogrow.py \
    --filename_of_receptor "$FULL_RECEPTOR_PATH" \
    --center_x "$CENTER_X" \
    --center_y "$CENTER_Y" \
    --center_z "$CENTER_Z" \
    --size_x "$SIZE_X" \
    --size_y "$SIZE_Y" \
    --size_z "$SIZE_Z" \
    --obabel_path "$(which obabel)" \
    --source_compound_file "$SOURCE_COMPOUND_FILE" \
    --root_output_folder "$ORIG_PWD" \
    --number_of_mutants_first_generation 50 \
    --number_of_crossovers_first_generation 50 \
    --number_of_mutants 50 \
    --number_of_crossovers 50 \
    --number_elitism_advance_from_previous_gen 50 \
    --top_mols_to_seed_next_generation 50 \
    --diversity_mols_to_seed_first_generation 10 \
    --diversity_seed_depreciation_per_gen 10 \
    --docking_executable "/opt/autodock_vina/bin/vina" \
    --num_generations 10 \
    --number_of_processors "$NUMBER_OF_PROCESSORS" \
    --selector_choice "Rank_Selector" \
    --max_variants_per_compound 5 \
    --filter_source_compounds false \
    --use_docked_source_compounds true \
    --LipinskiLenientFilter \
    --PAINSFilter \
    --docking_exhaustiveness "$DOCKING_EXHAUSTIVENESS" \
    --generate_plot false \
    --rescore_lig_efficiency \
    --scoring_choice "VINA" \
    --dock_choice "VinaDocking" \
    --gypsum_timeout_limit 1 \
    --rxn_library "all_rxns" \
    --conversion_choice "ObabelConversion"

