process racon {

    conda "${projectDir}/env/flye.yml"
    publishDir "${params.output}/03.Post_processing/quast_reports"
    publishDir "${params.output}/03.Post_processing/polishing"
  

    input:
    tuple val(sample_idl), path(reads_assembly), path(assembly_paf), path(fasta_assembly)


    output:
    tuple val(sample_idl), path("${sample_idl}_corrected.fasta") , emit: racon_assembly

    script:
    """
    mkdir -p ${params.output}/03.Post_processing/polishing

    racon -t ${task.cpus} \\
    ${reads_assembly} \\
    ${assembly_paf} \\
    ${fasta_assembly} > \\
    ${sample_idl}_corrected.fasta

    cp ${sample_idl}_corrected.fasta ${params.output}/03.Post_processing/polishing/${sample_idl}_corrected.fasta

    """
}


process racon2 {

    conda "${projectDir}/env/flye.yml"

    input:
    tuple val(sample_idl), path(reads_assembly), path(assembly_paf1), path(racon_assembly)


    output:
    tuple val(sample_idl), path("${sample_idl}_corrected1.fasta") , emit: racon_assembly1

    script:
    """

    racon -t ${task.cpus} \\
    ${reads_assembly} \\
    ${assembly_paf1} \\
    ${racon_assembly} > \\
    ${sample_idl}_corrected1.fasta

    cp ${sample_idl}_corrected1.fasta ${params.output}/03.Post_processing/polishing/${sample_idl}_corrected1.fasta
    rm ${params.output}/03.Post_processing/polishing/${sample_idl}_corrected.fasta

    """
}

process racon3 {

    conda "${projectDir}/env/flye.yml"

    input:
    tuple val(sample_idl), path(reads_assembly), path(assembly_paf2), path(racon_assembly1)


    output:
    tuple val(sample_idl), path("${sample_idl}_corrected2.fasta") , emit: racon_assembly2

    script:
    """
    racon -t ${task.cpus} \\
    ${reads_assembly} \\
    ${assembly_paf2} \\
    ${racon_assembly1} > \\
    ${sample_idl}_corrected2.fasta

    cp ${sample_idl}_corrected2.fasta ${params.output}/03.Post_processing/polishing/${sample_idl}_corrected2.fasta
    rm ${params.output}/03.Post_processing/polishing/${sample_idl}_corrected1.fasta

    """
}

    process racon4 {

    conda "${projectDir}/env/flye.yml"

    input:
    tuple val(sample_idl), path(reads_assembly), path(assembly_paf3), path(racon_assembly2)


    output:
    tuple val(sample_idl), path("${sample_idl}_corrected3.fasta") , emit: racon_assembly3

    script:
    """
    racon -t ${task.cpus} \\
    ${reads_assembly} \\
    ${assembly_paf3} \\
    ${racon_assembly2} > \\
    ${sample_idl}_corrected3.fasta

    cp ${sample_idl}_corrected3.fasta ${params.output}/03.Post_processing/polishing/${sample_idl}_corrected3.fasta
    rm ${params.output}/03.Post_processing/polishing/${sample_idl}_corrected2.fasta

    """

}

