process squeezemeta {
    conda "${projectDir}/env/squeezemeta.yml"
    publishDir "${params.output}/04.Squeezemeta"

        input:
        val(output_database)
        val(test_id)
        val(log)
        

        output:
        path("sq_end.txt"), emit: all_results

        script:
        if (params.input){
            if (params.coassembly) {
                """
                mkdir -p 04.Squeezemeta
                configure_nodb.pl ${params.database_dir}/db
                SqueezeMeta.pl -m coassembly \\
                -s ${test_id} \\
                -t ${task.cpus} \\
                -p ${params.output}/04.Squeezemeta \\
                -f ${params.assemb_in} \\
                -extassembly ${params.assemb} 
                sqm2tables.py ${params.output}/04.Squeezemeta ${params.output}/04.Squeezemeta/results/tables
                touch sq_end.txt
                """
            } else {
                """
                mkdir -p 04.Squeezemeta
                mkdir -p ${params.output}/04.Squeezemeta
                configure_nodb.pl ${params.database_dir}/db
               
                SqueezeMeta.pl -m sequential \\
                -s ${test_id} \\
                -t ${task.cpus} \\
                -f ${params.assemb_in} \\
                -extassembly ${params.assemb} 

                 for i in ${params.output}/02.Assembly/*.fasta
                        do
                    cc=\$(basename \$i _final_contigs.fasta)
                    cp -r \${cc} ${params.output}/04.Squeezemeta    
                    done 
                touch sq_end.txt
                """
        }
    }
}

process tables_squeezemeta {
    cache false
    conda "${projectDir}/env/squeezemeta.yml"

    input:
    val(all_results)

    script:
    """
    for i in ${params.output}/04.Squeezemeta/*/
    do
        if [ -d "\${i}/results/tables" ]; then
            continue
        fi
        sqm2tables.py \$i \${i}/results/tables
    done

    if [ -f "${params.output}/04.Squeezemeta/sq_end.txt" ]; then
        rm ${params.output}/04.Squeezemeta/sq_end.txt
    fi
    """
}