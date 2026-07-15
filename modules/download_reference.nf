process download_reference {
    conda "${projectDir}/env/assembly.yml"
    storeDir "${projectDir}"

    input:
    val host
    val py_script

    output:
    tuple val(host), path("${host}.fasta"), emit: reference

    script:
    """
    python3 ${py_script} ${projectDir} ${host}
    """
}