process minimap2_assembly {
    conda "${projectDir}/env/flye.yml"

    input:
    tuple val(sample_idl), path(reads_assembly), path(fasta_assembly)

    output:
    tuple val(sample_idl), path("${sample_idl}.paf"), emit: assembly_paf

    script:
    """
    minimap2 \\
        -t ${task.cpus} \\
        ${fasta_assembly} \\
        ${reads_assembly} \\
        -o ${sample_idl}.paf

        mv ${sample_idl}.paf ${params.output}/03.Post_processing
    """
}


process minimap2_assembly_2 {
    conda "${projectDir}/env/flye.yml"

    input:
    tuple val(sample_idl), path(reads_assembly), path(racon_assembly)

    output:
    tuple val(sample_idl), path("${sample_idl}.paf"), emit: assembly_paf1

    script:
    """
    minimap2 \\
        -t ${task.cpus} \\
        ${racon_assembly} \\
        ${reads_assembly} \\
        -o ${sample_idl}.paf

        mv ${sample_idl}.paf ${params.output}/03.Post_processing
    """
}


process minimap2_assembly_3 {
    conda "${projectDir}/env/flye.yml"

    input:
    tuple val(sample_idl), path(reads_assembly), path(racon_assembly1)

    output:
    tuple val(sample_idl), path("${sample_idl}.paf"), emit: assembly_paf2

    script:
    """
    minimap2 \\
        -t ${task.cpus} \\
        ${racon_assembly1} \\
        ${reads_assembly} \\
        -o ${sample_idl}.paf

        mv ${sample_idl}.paf ${params.output}/03.Post_processing
    """
}

process minimap2_assembly_4 {
    conda "${projectDir}/env/flye.yml"

    input:
    tuple val(sample_idl), path(reads_assembly), path(racon_assembly2)

    output:
    tuple val(sample_idl), path("${sample_idl}.paf"), emit: assembly_paf3


    script:
    """
    minimap2 \\
        -t ${task.cpus} \\
        ${racon_assembly2} \\
        ${reads_assembly} \\
        -o ${sample_idl}.paf

        mv ${sample_idl}.paf ${params.output}/03.Post_processing
    """
}

process minimap2_assembly_5 {
    conda "${projectDir}/env/flye.yml"

    input:
    tuple val(sample_idl), path(reads_assembly)
    tuple val(sample_idl), path(ch_polished_asm)
 
    output:
    tuple val(sample_idl), path("${sample_idl}.sam"), emit: final_assembly_sam

    script:
    """
    minimap2 \\
        -t ${task.cpus} \\
        ${ch_posilhed_asm} \\
        ${reads_assembly} \\
        -o ${sample_idl}.sam

        mv ${sample_idl}.sam ${params.output}/03.Post_processing
    """
}









