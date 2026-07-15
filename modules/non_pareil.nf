
process non_pareil {
   memory = '32 GB'
   cpus = 20
  conda "${projectDir}/env/nonpareil.yml"
  storeDir "${params.output}/01.Pre_processing/nonPareil"
  
  input:
  tuple val(sample_id), path(decompress_R1)

  output:
  tuple val(sample_id), file("cleaned-${sample_id}.npo"), emit: npo
  tuple val(sample_id), file("cleaned-${sample_id}.npa")
  tuple val(sample_id), file("cleaned-${sample_id}.npc")
  tuple val(sample_id), file("cleaned-${sample_id}.npl")

  script:
  """
  mkdir -p ${params.output}/01.Pre_processing/nonPareil
  nonpareil \\
  -s ${decompress_R1} \\
  -T kmer \\
  -f fastq \\
  -t ${task.cpus} \\
  -b cleaned-${sample_id} 
  
  """
}