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

    script:
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

    stub:
    """
    touch denovo.smi
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

    script:
    """
    cp ${denovo_ligands} denovo.smi
    """

    stub:
    """
    touch denovo.smi
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

    script:
    """
    DENOVO_LIGANDS_SMI="${denovo_ligands_smi}" \
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
    path "errors_pld_${task.index}.log" into pld_errors

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

    stub:
    """
    touch docked_0.pdbqt
    touch docked_1.pdbqt
    touch docked_2.pdbqt
    touch docked_3.pdbqt
    cp ${db_ligands_smi} admet.smi
    touch errors_pld_${task.index}.log
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
    path "errors_ap_${task.index}.log" into ap_errors

    script:
    """
    LIGAND_NAME=dummy \
    RECEPTOR_PDB=${receptor_pdb} \
    DOCKED_PDBQT=${docked_pdbqt} \
    run.sh
    """

    stub:
    """
    echo "name0,name1,name2,1.0" >> ligand.score
    touch errors_ap_${task.index}.log
    """
}

// Stage 7

process admet_filtering {
    container 'traviswheelerlab/07-admet_filtering'

    input:
    path db_ligands_smi from admet_smi

    output:
    path "output.txt" into admet_output

    script:
    """
    LIGAND_SMIS="${db_ligands_smi}" \
    ADMET_CHECKS="${params.admet_checks}" \
    run.sh
    """

    stub:
    """
    echo "1.0,1.0,1.0,1.0" >> output.txt
    """
}

// Stage 8

process error_collation {
    container 'traviswheelerlab/08-error_collation'

    publishDir "${params.output_dir}", mode: 'symlink'

    input:
    path pld_log from pld_errors.collectFile()
    path ap_log from ap_errors.collectFile()

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
    container 'traviswheelerlab/09-results_collation'

    publishDir "${params.output_dir}", mode: 'symlink'

    input:
    path ligand_score from ligand_score.collectFile()
    path admet_output from admet_output.collectFile()

    output:
    path "all_results.txt" into all_results

    script:
    """
    process_results.py \
        --ligand-score "${ligand_score}" \
        --admet-output "${admet_output}" \
        --admet-checks "${params.admet_checks}" \
        > all_results.txt
    """
}
