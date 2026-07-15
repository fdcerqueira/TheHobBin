process kraken2_db {
    conda "./env/krona.yml"

     storeDir "${params.kraken2_database}"

    input:
    val(kraken2_database)

    output:
    val(kraken2_database)

    script:
    """
    mkdir -p ${params.kraken2_database}
    kraken2-build --standard --db ${params.kraken2_database} --threads ${task.cpus}
    """
}
