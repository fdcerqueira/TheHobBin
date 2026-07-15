process decompress {
storeDir "${params.output}/01.Pre_processing/processed_reads"

input:
 tuple val(sample_id), path(processed_reads)

output:
tuple val(sample_id), file("cleaned-${sample_id}_R1.fastq"), emit: decompress_R1

script:
  """
  zcat ${processed_reads[0]} > cleaned-${sample_id}_R1.fastq
  """

}