process run_abricate_assembly {
    conda "./env/abricate.yml"
    storeDir "${params.output}/05.AMR/abricate"
    
    input:
        tuple val(sample_idl), path(nanopore_assembly)
    
    output:
        tuple val(sample_idl), path("${sample_idl}/assembly/*_abricate_*.txt"), emit: assembly_results
        tuple val(sample_idl), path("${sample_idl}/assembly/*_summary.txt"), emit: assembly_summary

    script:
        def databases = ["ncbi", "card", "resfinder", "argannot", "megares", "vfdb"]
        
        """
        # Process assembly
        mkdir -p ${sample_idl}/assembly
        
        for i in ${databases.join(" ")}
        do
            output_file="${sample_idl}/assembly/${sample_idl}_abricate_\${i}.txt"
            abricate \\
                --threads ${task.cpus} \\
                --db \$i \\
                ${nanopore_assembly} > \$output_file || touch \$output_file
        done
        
        # Generate summary for assembly
        summary_file="${sample_idl}/assembly/${sample_idl}_summary.txt"
        abricate --summary ${sample_idl}/assembly/${sample_idl}_abricate_*.txt > \$summary_file || touch \$summary_file

        """
}

process run_abricate_bins {
    conda "./env/abricate.yml"
    storeDir "${params.output}/05.AMR/abricate"
    
    input:
        tuple val(sample_idl), val(bin_name),path(bin_file)
    
    output:
        tuple val(sample_idl), path("${sample_idl}/bins/${bin_name}/${bin_name}_abricate_*.txt"), emit: bins_results
        tuple val(sample_idl), path("${sample_idl}/bins/${bin_name}/${bin_name}_summary.txt"), emit: bins_summary
    
    script:
        def databases = ["ncbi", "card", "resfinder", "argannot", "megares", "vfdb"]
        
        """

        # Process bins
        mkdir -p ${sample_idl}/bins/${bin_name}
        
            
        for i in ${databases.join(" ")}
        do
            output_file="${sample_idl}/bins/${bin_name}/${bin_name}_abricate_\${i}.txt"
            abricate \\
                --threads ${task.cpus} \\
                --db \$i \\
                ${bin_file} > \$output_file || touch \$output_file
        done
        
        # Generate summary for bin
        summary_file="${sample_idl}/bins/${bin_name}/${bin_name}_summary.txt"
        abricate --summary ${sample_idl}/bins/${bin_name}/${bin_name}_abricate_*.txt > \$summary_file || touch \$summary_file
        """
}