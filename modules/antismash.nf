process antismash_db {
    conda "./env/antismash.yml"
    storeDir "${params.antismash_database}"

    input:
        val(antismash_database)

    output:
        val(antismash_database)

    script:
    """
    mkdir -p ${params.antismash_database}
    \$CONDA_PREFIX/bin/download-antismash-databases --database-dir ${params.antismash_database}
    """
}

process run_antismash_assembly {
    conda "./env/antismash.yml"
    storeDir "${params.output}/04.Annotations/antismash"
    

    input:
        tuple val(sample_idl), path(bakta_folder)
        path(antismash_db)

    //output:
    //    tuple val(sample_idl), path("${sample_idl}/assembly/*")
     
    script:
    """
    mkdir -p ${params.output}/04.Annotations/antismash/${sample_idl}/assembly

    antismash \\
    ${params.output}/04.Annotations/bakta/${sample_idl}/assembly/${sample_idl}.gbff \\
    --output-dir ${params.output}/04.Annotations/antismash/${sample_idl}/assembly \\
    --output-basename ${sample_idl} \\
    --databases ${params.antismash_database} \\
    --cpus ${task.cpus} \\
    --taxon "bacteria" \\
    --genefinding-tool none \\
    --cc-mibig \\
    --minlength 5000
    """
}


process run_antismash_bins {
    conda "./env/antismash.yml"
    storeDir "${params.output}/04.Annotations/antismash"
    //errorStrategy 'ignore' 
  

    input:
        tuple val(sample_idl),val(bin_name), path(gbff_file)
        path(antismash_db)

    //output:
    //    tuple val(sample_idl), path("${sample_idl}/bins")                                                                        
 
    script:
    """
    mkdir -p ${params.output}/04.Annotations/antismash/${sample_idl}/bins/${bin_name}

    antismash \\
    ${gbff_file} \\
    --output-dir ${params.output}/04.Annotations/antismash/${sample_idl}/bins/${bin_name} \\
    --output-basename ${bin_name} \\
    --databases ${params.antismash_database} \\
    --taxon "bacteria" \\
    --genefinding-tool none \\
    --cpus ${task.cpus} \\
    --cc-mibig \\
    --minlength 5000
    """
}
    