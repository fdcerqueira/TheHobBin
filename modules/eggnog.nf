process eggnog_db {
    conda "./env/eggnogmapper.yml"
    storeDir "${params.eggnog_database}"

    input:
    val(eggnog_database)

    output:
    val (eggnog_database) 

    script:
    """
    mkdir -p "${params.eggnog_database}"
    download_eggnog_data.py -y --data_dir ${params.eggnog_database}
    """
}

process run_eggnog_assembly {
    conda "${projectDir}/env/eggnogmapper.yml"
    storeDir "${params.output}/04.Annotations/eggnogg/${sample_idl}/assembly"
    //errorStrategy "ignore"
    
    input:
        tuple val(sample_idl), path(bakta_folder)  
        path(eggnog_db)
    
    output:
        tuple val(sample_idl), path("*")

    script:
        """
        # Process assembly — write to the work dir; storeDir moves outputs to the store only on success
        mkdir -p temp
        export EGGNOG_DATA_DIR=${params.eggnog_database}

        emapper.py \\
            -i ${params.output}/04.Annotations/bakta/${sample_idl}/assembly/${sample_idl}.faa \\
            -o ${sample_idl} \\
            -m diamond \\
            --decorate_gff yes \\
            --temp_dir temp \\
            --data_dir ${params.eggnog_database} \\
            --cpu ${task.cpus} \\
            --override
    """  
}

process run_eggnog_bins {
    conda "${projectDir}/env/eggnogmapper.yml"
    storeDir "${params.output}/04.Annotations/eggnogg/${sample_idl}/bins"
    //errorStrategy "ignore"
    
    input:
        tuple val(sample_idl), val(bin_name), path(bakta_folder)  
        path(eggnog_db)
    
    output:
        tuple val(sample_idl), path("${bin_name}")
       
    script:
        """
        # Process bin — write to the work dir; storeDir moves outputs to the store only on success
        mkdir -p ${bin_name}/temp
        export EGGNOG_DATA_DIR=${params.eggnog_database}

        emapper.py \\
            -i ${params.output}/04.Annotations/bakta/${sample_idl}/bins/${bin_name}/${bin_name}.faa \\
            -o ${bin_name} \\
            --output_dir ${bin_name} \\
            -m diamond \\
            --decorate_gff yes \\
            --temp_dir ${bin_name}/temp \\
            --data_dir ${params.eggnog_database} \\
            --cpu ${task.cpus} \\
            --override
        """  
}

