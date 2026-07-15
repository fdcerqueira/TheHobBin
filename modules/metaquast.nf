
process metaquast {
    conda "${projectDir}/env/quast.yml"
    storeDir "${params.output}/03.Post_processing/quast_reports"

    input:
    tuple val(sample_id), path(assembly)

    output:
    path "metaquast.txt"

    script:
    """   
    mkdir -p ${params.output}/03.Post_processing/quast_reports
    metaquast ${assembly} -o ${params.output}/03.Post_processing/quast_reports/${sample_id} -t ${task.cpus}
    touch metaquast.txt
    """
}


process metaquast_coassembly {
    conda "${projectDir}/env/quast.yml"
    storeDir "${params.output}/03.Post_processing/quast_reports"

    input:
    path(assembly)

    output:
    path "metaquast.txt"

    script:
    """   
    mkdir -p ${params.output}/03.Post_processing/quast_reports
    metaquast ${assembly} -o ${params.output}/03.Post_processing/quast_reports -t ${task.cpus}
    touch metaquast.txt
    """
}