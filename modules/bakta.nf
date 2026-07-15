process bakta_db {
    conda "./env/bakta.yml"
    storeDir "${params.bakta_database}"

    input:
    val(bakta_database)

    output:
    val(bakta_database)

    script:
    """
    mkdir -p "${params.bakta_database}"
    bakta_db download --output ${params.bakta_database} --type full
    tar -xzf ${params.bakta_database}/db.tar.gz
    rm  ${params.bakta_database}/db.tar.gz
    """

}

   process run_bakta_assembly {
    conda "./env/bakta.yml"
    publishDir "${params.output}/04.Annotations/bakta", mode: "copy"
    //errorStrategy "ignore"

    input:
    tuple val(sample_idl), path(nanopore_assembly)
    path(bakta_db)

    output:
    tuple val(sample_idl), path("${sample_idl}/assembly"), emit: bakta_folder_assembly

    script:
    """
    export PYTHONNOUSERSITE=1
    mkdir -p tmp_bakta ${sample_idl}/assembly
    
    bakta \\
        --force \\
        --tmp-dir tmp_bakta \\
        --compliant \\
        --keep-contig-headers \\
        --min-contig-length ${params.bakta_min_contig_length} \\
        --output ${sample_idl}/assembly \\
        --prefix ${sample_idl} \\
        --translation-table 11 \\
        --threads ${task.cpus} \\
        --db ${params.bakta_database}/db \\
        ${nanopore_assembly}
    """
}

//mkdir -p ${params.output}/04.Annotations/bakta/${sample_idl}/assembly/
//mkdir -p ${params.output}/04.Annotations/bakta/${sample_idl}/assembly/tmp

process run_bakta_bins {
    conda "./env/bakta.yml"
    storeDir "${params.output}/04.Annotations/bakta/${sample_id}/bins"
    
    input:
    tuple val(sample_id), val(bin_name), path(bin_file)
    path(bakta_db)
    
    output:
    tuple val(sample_id), val(bin_name), path("${bin_name}/${bin_name}.gbff"), emit: bakta_folder_bin

    //maximum number of concurrent jobs
    script:
    """
    mkdir -p ${params.output}/04.Annotations/bakta/${sample_id}/bins/${bin_name}
    mkdir -p ${params.output}/04.Annotations/bakta/${sample_id}/bins/${bin_name}/tmp
     
    bakta \\
        --force \\
        --tmp-dir ${params.output}/04.Annotations/bakta/${sample_id}/bins/${bin_name}/tmp \\
        --compliant \\
        --keep-contig-headers \\
        --min-contig-length ${params.bakta_min_contig_length} \\
        --output ${params.output}/04.Annotations/bakta/${sample_id}/bins/${bin_name} \\
        --prefix ${bin_name} \\
        --translation-table 11 \\
        --threads ${task.cpus} \\
        --db ${bakta_db}/db \\
        ${bin_file}
    """
}