process mkdir_database {
    input:
    val(database_dir)

    script:
    """
    mkdir -p "${database_dir}"
    """
}

process download_databases {
    conda "${projectDir}/env/squeezemeta.yml"

    input:
    val(database_dir)

    output:
    val(database_dir), emit: downloaded_dir


    script:
    """
    download_databases.pl "${database_dir}"
    """
}

process test_install {
    conda "${projectDir}/env/squeezemeta.yml"

    input:
    val(database_dir)
    val(downloaded_dir)

    output:
    path("test_install.log"), emit: log

    script:
    def test_install_log = "test_install_squeezemeta.log"
    """
    echo "testing SqueezeMeta installation"
    test_install.pl ${params.database_dir} > ${params.output}/04.Squeezemeta/${test_install_log}
    ln -s ${params.output}/04.Squeezemeta/${test_install_log} ${test_install_log}
    """
}

process test_install_no_db {
    conda "${projectDir}/env/squeezemeta.yml"

    input:
    val(database_dir)

    output:
    path("test_install.log"), emit: log

    script:
    """
    echo "testing SqueezeMeta installation"
    test_install.pl ${params.database_dir} > test_install.log
    ln -s ${params.output}/04.Squeezemeta/test_install_squeezemeta.log
    """
}

process create_status_file {
    input:
    path database_dir

    output:
    path ".status", emit: status_file

    """
    touch .status
    cp .status ${params.database_dir}
    """
}

process remove_database {
    input:
    val(database_dir)
    
    script:
    """
    rm -rf "${database_dir}"
    """
}

