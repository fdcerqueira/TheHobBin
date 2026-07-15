process checkm_db {
    conda "./env/checkm.yml"
    storeDir "${params.checkm_database}"

    input:
        val(checkm_database)

    output:
        val(checkm_database)

    script:
    """
    mkdir -p "${params.checkm_database}"
    wget "https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz" -O ${params.checkm_database}/checkm_data_2015_01_16.tar.gz
    tar -xzf ${params.checkm_database}/checkm_data_2015_01_16.tar.gz -C ${params.checkm_database}
    rm ${params.checkm_database}/checkm_data_2015_01_16.tar.gz
    """
}

process run_checkm {
    conda "./env/checkm.yml"
    storeDir "${params.output}/08.Bins/checkm"

    input:
        tuple val(sample_idl), path(ch_refined_bins)
        path(checkm_database)

    output:
        tuple val(sample_idl), path("${sample_idl}/lineage.ms")
        tuple val(sample_idl), path("${sample_idl}/checkm_stats.tsv")

    script:
    """
    checkm data setRoot ${params.checkm_database}

    checkm lineage_wf \\
    -t ${task.cpus} \\
    -x fa ${ch_refined_bins} \\
    ${sample_idl}

    checkm qa \\
    -o 2 -t ${task.cpus} \\
    --tab_table -f ${sample_idl}/checkm_stats.tsv \\
    ${sample_idl}/lineage.ms \\
    ${sample_idl}
    """
}