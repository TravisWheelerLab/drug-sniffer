#!/usr/bin/env nextflow

// Channels
// --------

// Processes
// ---------

// Stages 1 and 2 require manual intervention and are therefore excluded from the
// workflow definition.

// Stage 3

process denovo {
    container 'traviswheelerlab/03-denovo:latest'

    input:
    path receptor_pdb from params.receptor_pdb

    val center_x from params.receptor_center_x
    val center_y from params.receptor_center_y
    val center_z from params.receptor_center_z

    val size_x from params.receptor_size_x
    val size_y from params.receptor_size_y
    val size_z from params.receptor_size_z

    output:
    path "denovo.smi" into denovo_ligands_smi

    cpus 4

    when:
    params.denovo_ligands == null

    """
    NUMBER_OF_PROCESSORS=4 \
    RECEPTOR_PATH="${receptor_pdb}" \
    CENTER_X="${center_x}" \
    CENTER_Y="${center_y}" \
    CENTER_Z="${center_z}" \
    SIZE_X="${size_x}" \
    SIZE_Y="${size_y}" \
    SIZE_Z="${size_z}" \
    run.sh
    """
}

process external_denovo {
    container 'traviswheelerlab/03-denovo:latest'

    input:
    path denovo_ligands from params.denovo_ligands

    output:
    path "denovo.smi" into external_denovo_ligands_smi

    cpus 4

    when:
    params.denovo_ligands != null

    """
    cp ${denovo_ligands} denovo.smi
    """
}

// Stage 4

process similarity_search {
    container 'traviswheelerlab/04-similarity_search:latest'

    input:
    path denovo_ligands_smi from denovo_ligands_smi.mix(external_denovo_ligands_smi)
    path molecule_db from params.molecule_db

    output:
    path "*.smi" into db_ligands_smi

    cpus 1

    """
    DENOVO_LIGANDS_SMI="${denovo_ligands_smi}" \
    MOLECULE_DB="${molecule_db}" \
    TANIMOTO_CUTOFF="${params.tanimoto_cutoff}" \
    run.sh
    """
}

// Stage 5

process protein_ligand_docking {
    container 'traviswheelerlab/05-protein_ligand_docking:latest'

    input:
    path receptor_pdb from params.receptor_pdb
    path db_ligands_smi from db_ligands_smi.flatMap()
    val center_x from params.receptor_center_x
    val center_y from params.receptor_center_y
    val center_z from params.receptor_center_z
    val size_x from params.receptor_size_x
    val size_y from params.receptor_size_y
    val size_z from params.receptor_size_z

    output:
    path "docked_*.pdbqt" optional true into docked_pdbqt
    path "admet.smi" optional true into admet_smi
    path "errors.log" into protein_ligand_docking_errors

    cpus 1

    script:
    """
    RECEPTOR_PDB="${receptor_pdb}" \
    LIGANDS_SMI="${db_ligands_smi}" \
    CENTER_X="${center_x}" \
    CENTER_Y="${center_y}" \
    CENTER_Z="${center_z}" \
    SIZE_X="${size_x}" \
    SIZE_Y="${size_y}" \
    SIZE_Z="${size_z}" \
    run.sh
    """
}

// Stage 6

process activity_prediction {
    container 'traviswheelerlab/06-activity_prediction'

    input:
    path receptor_pdb from params.receptor_pdb
    path docked_pdbqt from docked_pdbqt

    output:
    path "ligand.score" into ligand_score
    path "errors.log" into activity_prediction_errors

    """
    LIGAND_NAME=dummy \
    RECEPTOR_PDB=${receptor_pdb} \
    DOCKED_PDBQT=${docked_pdbqt} \
    run.sh
    """
}

// Stage 7

process admet_filtering {
    container 'traviswheelerlab/07-admet_filtering'

    input:
    path db_ligands_smi from admet_smi

    output:
    path "output.txt" into admet_output

    """
    LIGAND_SMIS="${db_ligands_smi}" \
    ADMET_CHECKS="${params.admet_checks}" \
    run.sh
    """
}

// Stage 8

process error_collation {
    container 'traviswheelerlab/08-error_collation'

    publishDir "${params.output_dir}", mode: 'symlink'

    input:
    path pld_log from protein_ligand_docking_errors.collectFile()
    path ap_log from activity_prediction_errors.collectFile()

    output:
    path "all_errors.txt" into all_errors

    """
    process_errors.py \
        --protein-ligand-docking ${pld_log} \
        --activity-prediction ${ap_log} \
        > all_errors.txt
    """
}

// Stage 9

process results_collation {
    container 'traviswheelerlab/09-results_collation'

    publishDir "${params.output_dir}", mode: 'symlink'

    input:
    path ligand_score from ligand_score.collectFile()
    path admet_output from admet_output.collectFile()

    output:
    path "all_results.txt" into all_results

    """
    process_results.py \
        --ligand-score ${ligand_score} \
        --admet-output ${admet_output} \
        > all_results.txt
    """
}
