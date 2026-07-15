process flye {

    conda "${projectDir}/env/flye.yml"
    publishDir "${params.output}/02.Assembly", mode: "copy"
    //errorStrategy "ignore"

    input:
    tuple val(sample_idl), path(reads_chopper)

    output:
    tuple val(sample_idl), path("assembly_${sample_idl}/assembly.fasta"),emit: fasta_assembly

    script:
    """
    mkdir -p  "${params.output}/02.Assembly"
    
    flye --nano-raw ${reads_chopper} \\
    -t ${task.cpus} \\
    --meta \\
    --out-dir assembly_${sample_idl}

    cp -r assembly_${sample_idl} ${params.output}/02.Assembly
    mv ${params.output}/02.Assembly/assembly_${sample_idl}/assembly.fasta ${params.output}/02.Assembly/assembly_${sample_idl}/${sample_idl}.fasta
    """
}

process metaquast_long_reads {
    conda "${projectDir}/env/flye.yml"
    //publishDir "${params.output}/results/flye", mode: "copy"

    input:
    tuple val(sample_idl), path(ch_polished_asm)


    script:
    """
    metaquast ${ch_polished_asm} \\
     -o ${params.output}/03.Post_processing/quast_reports/racon_${sample_idl} \\
     -t ${task.cpus}
     """
}

process metaquast_long_reads_medaka {
    conda "${projectDir}/env/flye.yml"
    //publishDir "${params.output}/results/flye", mode: "copy"

    input:
    tuple val(sample_idl), path("${params.output}/03.Post_processing/polishing/${sample_idl}_medaka/consensus.fasta")


    script:
    """
    metaquast ${params.output}/03.Post_processing/polishing/${sample_idl}_medaka/consensus.fasta \\
     -o ${params.output}/03.Post_processing/quast_reports/medaka_${sample_idl} \\
     -t ${task.cpus}
     """
}
