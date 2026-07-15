process medaka {
     conda "${projectDir}/env/flye.yml"
     errorStrategy 'ignore'

     input:
     tuple val(sample_idl), path(reads_chopper), path(ch_polished_asm)

     output:
     tuple val(sample_idl), path("${sample_idl}_medaka.fasta"), emit: medaka_assembly

     script:
     """
     medaka_consensus \\
        -t ${task.cpus} \\
        -i ${reads_chopper} \\
        -d ${ch_polished_asm} \\
        -o ${sample_idl}_medaka

      cp ${sample_idl}_medaka/consensus.fasta ${sample_idl}_medaka.fasta

      mkdir -p ${params.output}/03.Post_processing/polishing
      cp -r ${sample_idl}_medaka ${params.output}/03.Post_processing/polishing

     """

}