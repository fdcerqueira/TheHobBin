
process read_r_bbwrap {
    conda "${projectDir}/env/assembly.yml"
    storeDir "${params.output}/03.Post_processing/read_recruitment"

    input:
    tuple val(sample_id), path(reads), path(assembly)

   // output:
   // tuple val(sample_id),
        //path("sorted-${sample_id}.sam"),
   //     path("${sample_id}_reads.txt"),
   //     path("${sample_id}_reads_mapped_assembly.txt")

    script:
    """
     if [ ! -d "${params.output}/03.Post_processing/read_recruitment" ]
            then
        mkdir -p ${params.output}/03.Post_processing/read_recruitment
    fi

    bbwrap.sh \\
    -Xmx${params.mem} \\
    t=${task.cpus} \\
    in=${reads[0]} \\
    in2=${reads[1]} \\
    ref=${assembly} \\
    out=sorted-${sample_id}.sam \\
    outm=mapped-${sample_id}_R1.fastq.gz \\
    outm2=mapped-${sample_id}_R2.fastq.gz \\
    outu=unmapped-${sample_id}_R1.fastq.gz \\
    outu2=unmapped-${sample_id}_R2.fastq.gz \\
    ambig=toss \\
    2> ${sample_id}_reads.txt \\
    bamscript=bs.sh
    sh bs.sh
    
    awk "/kBases/ {for(i=1; i<=44; i++) {getline; print}}" ${sample_id}_reads.txt | \\
    awk "/mapped/ {getline; print} " | \\
    awk  '{ sum += \$2 } END { print "Reads mapped to assembly:" (sum / NR)"%" }' > ${sample_id}_reads_mapped_assembly.txt

    cp ${sample_id}_reads.txt ${params.output}/03.Post_processing/read_recruitment
    cp ${sample_id}_reads_mapped_assembly.txt ${params.output}/03.Post_processing/read_recruitment

    """
}

process read_r_bbwrap_coassembly {
    conda "${projectDir}/env/assembly.yml"
    storeDir "${params.output}/03.Post_processing/read_recruitment"

    input:
    tuple val(sample_id), path(processed_reads)
    path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_reads.txt"), path("${sample_id}_reads_mapped_assembly.txt")


    script:
    """
    if [ ! -d ${params.output}/03.Post_processing/read_recruitment ];then
        mkdir -p ${params.output}/03.Post_processing/read_recruitment
    fi

    bbwrap.sh \\
    -Xmx${params.mem} \\
    t=${task.cpus} \\
    in=${processed_reads[0]} \\
    in2=${processed_reads[1]} \\
    ref=${assembly} \\
    out=sorted-${sample_id}.sam \\
    outm=mapped-${sample_id}_R1.fastq.gz \\
    outm2=mapped-${sample_id}_R2.fastq.gz \\
    outu=unmapped-${sample_id}_R1.fastq.gz \\
    outu2=unmapped-${sample_id}_R2.fastq.gz \\
    ambig=toss \\
    2> ${sample_id}_reads.txt \\
    bamscript=bs.sh
    sh bs.sh
    
    awk "/kBases/ {for(i=1; i<=44; i++) {getline; print}}" ${sample_id}_reads.txt | \\
    awk "/mapped/ {getline; print} " | \\
    awk  '{ sum += \$2 } END { print "Reads mapped to assembly:" (sum / NR)"%" }' > ${sample_id}_reads_mapped_assembly.txt

    cp ${sample_id}_reads.txt ${params.output}/03.Post_processing/read_recruitment/${sample_id}_reads.txt
    cp ${sample_id}_reads_mapped_assembly.txt ${params.output}/03.Post_processing/read_recruitment/${sample_id}_reads_mapped_assembly.txt

    rm mapped-${sample_id}_R1.fastq.gz
    rm mapped-${sample_id}_R2.fastq.gz
    rm unmapped-${sample_id}_R1.fastq.gz
    rm unmapped-${sample_id}_R2.fastq.gz 
    """
}

