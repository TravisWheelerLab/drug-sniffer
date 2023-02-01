#!/usr/bin/env nextflow

external_seeds = params.seed_ligands != null

if (external_seeds) {
    seed_ligands = params.seed_ligands
} else {
    seed_ligands = Channel.empty()
}

if (params.autogrow_exhaustiveness == null) {
    autogrow_exhaustiveness = 1
} else {
    autogrow_exhaustiveness = params.autogrow_exhaustiveness
}

if (params.autogrow_generations == null) {
    autogrow_generations = 20
} else {
    autogrow_generations = params.autogrow_generations
}

// Stages 1 and 2 require manual intervention and are therefore excluded from the
// workflow definition.

// Stage 3

process denovo_ligands {
    container "$params.image_namespace/03-denovo:latest"

    publishDir "${params.output_dir}", mode: 'symlink'

    input:
    path receptor_pdb from params.receptor_pdb

    val center_x from params.receptor_center_x
    val center_y from params.receptor_center_y
    val center_z from params.receptor_center_z

    val size_x from params.receptor_size_x
    val size_y from params.receptor_size_y
    val size_z from params.receptor_size_z

    output:
    path "seeds.smi" into denovo_seed_ligands_smi

    cpus 12

    when:
    !external_seeds

    script:
    """
    DOCKING_EXHAUSTIVENESS=${autogrow_exhaustiveness} \
    NUMBER_OF_GENERATIONS=${autogrow_generations} \
    NUMBER_OF_PROCESSORS=12 \
    RECEPTOR_PATH="${receptor_pdb}" \
    CENTER_X="${center_x}" \
    CENTER_Y="${center_y}" \
    CENTER_Z="${center_z}" \
    SIZE_X="${size_x}" \
    SIZE_Y="${size_y}" \
    SIZE_Z="${size_z}" \
    run.sh
    """

    stub:
    """
    touch seeds.smi
    """
}

process external_seeds {
    container "$params.image_namespace/03-denovo:latest"

    input:
    path seed_ligands from seed_ligands

    output:
    path "seeds.smi" into external_seed_ligands_smi

    when:
    external_seeds

    script:
    """
    cp ${seed_ligands} seeds.smi
    """

    stub:
    """
    touch seeds.smi
    """
}

// Stage 4

process similarity_search {
    container "$params.image_namespace/04-similarity_search:latest"

    input:
    path seed_ligands_smi from denovo_seed_ligands_smi.mix(external_seed_ligands_smi)
    path molecule_db from params.molecule_db

    output:
    path "*.smi" into db_ligands_smi

    script:
    """
    SEED_LIGANDS_SMI="${seed_ligands_smi}" \
    MOLECULE_DB="${molecule_db}" \
    TANIMOTO_CUTOFF="${params.tanimoto_cutoff}" \
    run.sh
    """

    stub:
    """
    touch ligand0.smi
    touch ligand1.smi
    """
}

// Stage 5

process protein_ligand_docking {
    container "$params.image_namespace/05-protein_ligand_docking:latest"

    time '60min'
    errorStrategy 'ignore'

    input:
    path receptor_pdb from params.receptor_pdb
    path ligand_smi from db_ligands_smi.flatMap()
    val center_x from params.receptor_center_x
    val center_y from params.receptor_center_y
    val center_z from params.receptor_center_z
    val size_x from params.receptor_size_x
    val size_y from params.receptor_size_y
    val size_z from params.receptor_size_z

    output:
    path "docked_ligand.pdbqt" optional true into docked_ligand
    path "ligand.smi.admet" optional true into ligand_smi_admet
    path "ligand.smi.output" optional true into ligand_smi_output
    path "ligand.smi.activity" optional true into ligand_smi_activity
    path "errors.log" into pld_errors

    script:
    """
    RECEPTOR_PDB="${receptor_pdb}" \
    LIGAND_SMI="${ligand_smi}" \
    CENTER_X="${center_x}" \
    CENTER_Y="${center_y}" \
    CENTER_Z="${center_z}" \
    SIZE_X="${size_x}" \
    SIZE_Y="${size_y}" \
    SIZE_Z="${size_z}" \
    run.sh
    """

    stub:
    """
    touch docked_ligand.pdbqt
    cp ${ligand_smi} ligand.smi.admet
    cp ${ligand_smi} ligand.smi.output
    cp ${ligand_smi} ligand.smi.activity
    touch errors.log
    """
}

// Stage 6

process activity_prediction {
    container "$params.image_namespace/06-activity_prediction"

    input:
    path ligand_smi from ligand_smi_activity
    path receptor_pdb from params.receptor_pdb
    path docked_ligand from docked_ligand

    output:
    path "ligand.score" optional true into ligand_score
    path "errors.log" into ap_errors

    script:
    """
    LIGAND_SMI=${ligand_smi} \
    RECEPTOR_PDB=${receptor_pdb} \
    DOCKED_PDBQT=${docked_ligand} \
    run.sh
    """

    stub:
    """
    echo "1\t1.0" >> ligand.score
    touch errors.log
    """
}

// Stage 7

process admet_prediction {
    container "$params.image_namespace/07-admet_prediction"

    input:
    path ligand_smi from ligand_smi_admet

    output:
    path "admet.txt" into admet_output

    script:
    """
    cp ${ligand_smi} ligand.smi
    LIGAND_SMI="ligand.smi" \
    ADMET_CHECKS="${params.admet_checks}" \
    run.sh
    """

    stub:
    """
    echo "1.0,1.0,1.0,1.0" >> admet.txt
    """
}

// Stage 8

process error_collation {
    container "$params.image_namespace/08-error_collation"

    publishDir "${params.output_dir}", mode: 'symlink'

    input:
    path pld_log from pld_errors.collectFile(name: "pld_errors.log")
    path ap_log from ap_errors.collectFile(name: "ap_errors.log")

    output:
    path "all_errors.txt" into all_errors

    script:
    """
    process_errors.py \
        --protein-ligand-docking ${pld_log} \
        --activity-prediction ${ap_log} \
        > all_errors.txt
    """
}

// Stage 9

process results_collation {
    container "$params.image_namespace/09-results_collation"

    publishDir "${params.output_dir}", mode: 'symlink'

    input:
    path ligand_score from ligand_score.collectFile()
    path admet_output from admet_output.collectFile()
    path ligand_smi from ligand_smi_output.collectFile()

    output:
    path "all_results.txt" into all_results

    script:
    """
    process_results.py \
        --ligand-smi "${ligand_smi}" \
        --ligand-score "${ligand_score}" \
        --admet-output "${admet_output}" \
        --admet-checks "${params.admet_checks}" \
        > all_results.txt
    """
}
