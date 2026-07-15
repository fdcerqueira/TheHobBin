process genomad_db {

    conda "./env/genomad.yml"
    storeDir "${params.genomad_database}"

    input:
    val(genomad_database)

    output:
    val(genomad_database)

    script:
    """
        mkdir -p ${params.genomad_database}
        genomad download-database ${params.genomad_database}
    """
}

process run_genomad_assembly {

    conda "./env/genomad.yml"
    storeDir "${params.output}/07.Phages/genomad"

    input:
        tuple val(sample_idl), path(dnaapler_assembly)
        path(genomad_db)

    output:
        tuple val(sample_idl), path("${sample_idl}/assembly")
        
    script:
    """
    mkdir -p ${sample_idl}/assembly

    genomad end-to-end \\
    ${dnaapler_assembly} \\
    ${sample_idl}/assembly \\
    ${params.genomad_database}/genomad_db
    """
}

process run_genomad_bins {

    conda "./env/genomad.yml"
    publishDir "${params.output}/07.Phages/genomad"

    input:
        tuple val(sample_idl), val(dnaapler_bins)
        path(genomad_db)

    //output:
    //    tuple val(sample_idl), path("${sample_idl}/bins")
        
    script:
    """
    mkdir -p ${params.output}/07.Phages/genomad/${sample_idl}/bins

    bin_name=\$(basename ${dnaapler_bins} .fasta)

    genomad end-to-end \\
    ${dnaapler_bins} \\
    ${params.output}/07.Phages/genomad/${sample_idl}/bins/\${bin_name} \\
    ${params.genomad_database}/genomad_db
    """
}
