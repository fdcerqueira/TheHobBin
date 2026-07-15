process gtdbtk_db {
    storeDir "${params.gtdbtk_database}"

    input:
        val(gtdbtk_database)

    output:
        val(gtdbtk_database)

    script:
    """
    mkdir -p ${params.gtdbtk_database}
    wget -O ${params.gtdbtk_database}/gtdbtk_data.tar.gz  https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/gtdbtk_package/full_package/gtdbtk_data.tar.gz 
    tar -xzf ${params.gtdbtk_database}/gtdbtk_data.tar.gz -C ${params.gtdbtk_database}
    rm ${params.gtdbtk_database}/gtdbtk_data.tar.gz 
    """
}

process run_gtdbtk{

    conda "./env/gtdbtk.yml"
    publishDir "${params.output}/09.Taxonomy/bins", mode: 'copy'

    input:
    tuple val(sample_idl), path(ch_refined_bins)
    path(gtdbtk_database)

    output:
    tuple val(sample_idl), path("${sample_idl}")

    script:
    """
    export GTDBTK_DATA_PATH=${params.gtdbtk_database}

     gtdbtk classify_wf \\
        -x fa \\
        --genome_dir ${ch_refined_bins} \\
        --prefix gtdbtk.${sample_idl} \\
        --mash_db ${params.gtdbtk_database} \\
        --out_dir ${sample_idl} \\
        --cpus ${task.cpus} --pplacer_cpus ${task.cpus}
    """
}

