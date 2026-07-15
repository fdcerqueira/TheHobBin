process depth_mapping {
    conda "./env/metabat2.yml"
    storeDir "${params.output}/08.Bins/${sample_idl}"
    
    input:
    tuple val(sample_idl), path(polished_assembly), path(reads_assembly)

    output:
    tuple val(sample_idl), path("${sample_idl}.bam"), emit: bam_depth
    //path "v_minimap2.txt"
    //path "v_samtools.txt"
    
    script:
    """
    mkdir -p ${params.output}/08.Bins/${sample_idl}

    minimap2 \\
        -t ${task.cpus} \\
        -ax map-ont \\
        ${polished_assembly} \\
        ${reads_assembly} | samtools sort -o ${sample_idl}.bam --write-index - > minimap2_stdout.log 2> minimap2_error.log

    """
}

process depth_creation {
    
    conda "${projectDir}/env/metabat2.yml"
    storeDir "${params.output}/08.Bins/${sample_idl}"

    input:
    tuple val(sample_idl), path(bam_depth)

    output:
    tuple val(sample_idl), path("${sample_idl}_depth.txt"), emit:depth_bins

    script:
    """
    jgi_summarize_bam_contig_depths --outputDepth ${sample_idl}_depth.txt ${bam_depth}
    """
}


process run_metabat2 {
    conda "${projectDir}/env/metabat2.yml"
    storeDir "${params.output}/08.Bins/${sample_idl}"
    errorStrategy 'ignore'

    input:
    tuple val(sample_idl), path(polished_assembly), path(depth_bins)

    output:
    tuple val(sample_idl), path("metabat2_bins"), emit:bins_metabat2

    script:
    """
    mkdir -p metabat2_bins

    metabat2 \\
    --inFile ${polished_assembly} \\
    --abdFile ${depth_bins} \\
    --outFile metabat2_bins/${sample_idl} \\
    --numThreads ${task.cpus} \\
    --seed 1

    """
}

process run_maxbin2 {

    tag "${sample_idl}"
    conda "${projectDir}/env/metabat2.yml"
    storeDir "${params.output}/08.Bins/${sample_idl}"
    errorStrategy 'ignore'

    input:
    tuple val(sample_idl), path(polished_assembly), path(depth_bins)

    output:
    tuple val(sample_idl), path("maxbin2_bins"), emit:bins_maxbin2

    script:
    """
    mkdir -p maxbin2_bins

    cut -f1,3- ${depth_bins} > maxbin2_depth.txt

    run_MaxBin.pl -contig ${polished_assembly} \\
    -out maxbin2_bins/${sample_idl} \\
    -abund maxbin2_depth.txt \\
    -thread ${task.cpus}
    """
}


