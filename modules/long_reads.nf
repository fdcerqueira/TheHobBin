process fastplong {
    conda "${projectDir}/env/assembly.yml"
    storeDir "${params.output}/01.pre_processing/fastplong"

    input:
    tuple val(sample_idl), path(reads_long) 

    output:
    tuple val(sample_idl), path("${sample_idl}_adapter_clipped.fastq.gz"), emit:reads_fastplong
    path("${sample_idl}.fastp.json")
    path("${sample_idl}.fastp.html")

    script:
    """
    fastplong -i ${reads_long} \\
    -o ${sample_idl}_adapter_clipped.fastq.gz \\
    --length_required ${params.min_length} \\
    -j ${sample_idl}.fastp.json \\
    --html ${sample_idl}.fastp.html
    """
}

process porechop_abi {
    conda "${projectDir}/env/porechop_abi.yml"
    storeDir "${params.output}/01.pre_processing/porechop_abi"

    input:
    tuple val(sample_idl), val(reads_long)

    output:
    tuple val(sample_idl), path("${sample_idl}_porechop.fastq.gz"), emit:reads_porechop

    script:
    """
    porechop_abi \\
    --ab_initio \\
    --threads ${task.cpus} \\
    --input ${reads_long} \\
    --output ${sample_idl}_porechop.fastq.gz
    """
}

process filtlong {
    conda "${projectDir}/env/assembly.yml"
    storeDir "${params.output}/01.pre_processing/filtlong"

    input:
    tuple val(sample_id), path(reads_short)
    tuple val(sample_idl), path(reads_porechop)

    output:
    tuple val(sample_id), path("${sample_idl}_adapter_clipped.fastq.gz"), emit:reads_filtlong

    script:
    """
    filtlong \\
    -1 ${reads_short[0]} \\
    -2 ${reads_short[1]} \\
    --min_length ${params.min_length} \\
    --keep_percent 90 \\
    ${reads_porechop} | gzip > ${sample_idl}_adapter_clipped.fastq.gz
    """
}


process nanoplot {
    conda "${projectDir}/env/long_read_qc.yml"
    //storeDir "${params.output}/results/nano_plots"
    errorStrategy "ignore"

    input:
    tuple val(sample_idl), path(reads_fastplong)

    //output:
    //tuple val(sample_idl), path("*.png"), path("*.txt"), path("*.log")
    
    script:
    """
    mkdir -p ${params.output}/01.pre_processing/nano_plots

    NanoPlot -t ${task.cpus} \\
    --fastq ${reads_fastplong} \\
    --loglength \\
    -o ${sample_idl} \\
    --plots dot 

    cp -r ${sample_idl} ${params.output}/01.pre_processing/nano_plots
    """
}