
process non_pareil_reports {
  conda "${projectDir}/env/nonpareil.yml"
  storeDir "${params.output}/01.Pre_processing/nonPareil/nonPareil_reports"

  input:
  val nonpareil_script
  val non_pareil
  val non_pareil_reports
  tuple val(sample_id), path(npo) 

  output:
  tuple val(sample_id), path("${sample_id}.pdf"), path("${sample_id}.txt")

  script:
  """
  mkdir -p ${params.output}/01.Pre_processing/nonPareil/nonPareil_reports
  Rscript ${nonpareil_script} ${non_pareil} ${non_pareil_reports} ${sample_id}
  ln -s ${params.output}/01.Pre_processing/nonPareil/nonPareil_reports/${sample_id}.pdf ${sample_id}.pdf 
  ln -s ${params.output}/01.Pre_processing/nonPareil/nonPareil_reports/${sample_id}.txt ${sample_id}.txt
  """
}
