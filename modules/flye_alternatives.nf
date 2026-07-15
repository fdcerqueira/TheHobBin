process meta_MDBG {
    conda "${projectDir}/env/flye_alternatives.yml"
    publishDir "${params.output}/02.Assembly", mode: "copy"

    input:
    tuple val(sample_idl), path(reads_chopper)

    output:
    tuple val(sample_idl), path("assembly_${sample_idl}/contigs.fasta"),emit:fasta_assembly

    script:
    """
    mkdir -p  "${params.output}/02.Assembly"

    metaMDBG asm --out-dir assembly_${sample_idl} \\
    --in-ont ${reads_chopper} \\
    --threads ${task.cpus} 

    gzip -d assembly_${sample_idl}/contigs.fasta.gz 

    cp -r assembly_${sample_idl} ${params.output}/02.Assembly
    mv ${params.output}/02.Assembly/assembly_${sample_idl}/contigs.fasta ${params.output}/02.Assembly/assembly_${sample_idl}/${sample_idl}.fasta
    """
}

process myloasm {
    conda "${projectDir}/env/flye_alternatives.yml"
    publishDir "${params.output}/02.Assembly", mode: "copy"

    input:
    tuple val(sample_idl), path(reads_chopper)

    output:
    tuple val(sample_idl), path("assembly_${sample_idl}/${sample_idl}.fasta"),emit:fasta_assembly

    script:
    """
    mkdir -p  "${params.output}/02.Assembly"

    myloasm ${reads_chopper} -o assembly_${sample_idl} -t ${task.cpus} 

    seqkit replace -p "^(.{20}).*" -r "\\\$1" assembly_${sample_idl}/assembly_primary.fa > assembly_${sample_idl}/${sample_idl}.fasta
    """
}
