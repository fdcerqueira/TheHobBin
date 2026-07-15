
    process megahit {
        conda "${projectDir}/env/assembly.yml"
        storeDir "${params.output}/02.Assembly"

        input:
        tuple val(sample_id), path(processed_reads)
        

        output:
        tuple val(sample_id), path("${sample_id}_final_contigs.fasta"), emit: assembly
        //tuple val(sample_id), path("log.txt"), emit: log

        script:
        def mode_option = ""
        if (params.assembly_mode == "default") {
            params.min=21
            params.max=141
            params.step=12
            mode_option = "--min-contig-len 500 --k-min ${params.min} --k-max ${params.max} --k-step ${params.step} -m 0.8"
        } else if (params.assembly_mode == "no_mercy") {
            mode_option = "--no-mercy --min-contig-len 500 --k-min ${params.min} --k-max ${params.max} --k-step ${params.step} -m 0.8"
        } else if (params.assembly_mode == "regular") {
            mode_option = "--min-contig-len 500 --k-min ${params.min} --k-max ${params.max} --k-step ${params.step} -m 0.8"
        } else {
            exit 1, "Invalid assembly mode provided: ${params.assembly_mode}"
        }

        """
        if [ ! -d "${params.output}/02.Assembly" ]
        then
        mkdir -p ${params.output}/02.Assembly
        fi

        {   megahit --num-cpu-threads ${task.cpus} \\
            -o megahit \\
            ${mode_option} \\
            -1 ${processed_reads[0]} \\
            -2 ${processed_reads[1]} 

            mv megahit/final.contigs.fa ${sample_id}_final_contigs.fasta
            echo pass > .status
        } || {
            echo fail > .status
            :> ${sample_id}_MEGAHIT.fasta

            echo fail > .status
            :>  log.txt
        }
        rm -r megahit || true
        """

}

process megahit_coassembly {
        conda "${projectDir}/env/assembly.yml"
        storeDir "${params.output}/02.Assembly"

        input:
        path(reads_for_coassembly)
        

        output:
        path('final_contigs.fasta'), emit: assembly
        path("log.txt"), emit: log

        script:

        def r1_list = reads_for_coassembly.findAll { it.name.endsWith("_R1.fastq.gz") }
        def r2_list = reads_for_coassembly.findAll { it.name.endsWith("_R2.fastq.gz") }

        
        def mode_option = ""
        if (params.assembly_mode == "default") {
            params.min=21
            params.max=141
            params.step=12
            mode_option = "--min-contig-len 500 --k-min ${params.min} --k-max ${params.max} --k-step ${params.step} -m 0.8"
        } else if (params.assembly_mode == "no_mercy") {
            mode_option = "--no-mercy --min-contig-len 500 --k-min ${params.min} --k-max ${params.max} --k-step ${params.step} -m 0.8"
        } else if (params.assembly_mode == "regular") {
            mode_option = "--min-contig-len 500 --k-min ${params.min} --k-max ${params.max} --k-step ${params.step} -m 0.8"
        } else {
            exit 1, "Invalid assembly mode provided: ${params.assembly_mode}"
        }

        """
        if [ ! -d ${params.output}/01.Pre_processing/merged_reads ]; then
        mkdir -p ${params.output}/01.Pre_processing/merged_reads
        fi

        cat ${r1_list.join(' ')} > ${params.output}/01.Pre_processing/merged_reads/merged_R1.fastq.gz
        cat ${r2_list.join(' ')} > ${params.output}/01.Pre_processing/merged_reads/merged_R2.fastq.gz

        {   megahit --num-cpu-threads ${task.cpus} \\
            -o megahit \\
            ${mode_option} \\
            -1 ${params.output}/01.Pre_processing/merged_reads/merged_R1.fastq.gz \\
            -2 ${params.output}/01.Pre_processing/merged_reads/merged_R2.fastq.gz

            mv megahit/final.contigs.fa final_contigs.fasta 
            mv megahit/log log.txt 
            echo pass > .status
        } || {
            echo fail > .status
            :> co_assembly_MEGAHIT.fasta

            echo fail > .status
            :>  co_assembly_log.txt
        }
        rm -r megahit || true
        """

}

