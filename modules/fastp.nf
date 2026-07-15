process fastp {
        conda "${projectDir}/env/assembly.yml"
        storeDir "${params.output}/01.Pre_processing/fastp"

        input:
        tuple val(sample_id), path(reads) 
        
        output:
        tuple val(sample_id), path("filt_${sample_id}_R*.fastq.gz"), emit:reads
        path("${sample_id}.fastp.json"), emit:json
        path("${sample_id}.fastp.html"), emit:html
        
        script:
        """
        mkdir -p ${params.output}/01.Pre_processing/fastp

        fastp -i ${reads[0]} \\
        -I ${reads[1]} \\
        -o ${params.output}/01.Pre_processing/fastp/filt_${sample_id}_R1.fastq.gz \\
        -O ${params.output}/01.Pre_processing/fastp/filt_${sample_id}_R2.fastq.gz \\
        --detect_adapter_for_pe -w ${task.cpus} \\
        -j ${sample_id}.fastp.json \\
        --html ${sample_id}.fastp.html 
        """  
    }  