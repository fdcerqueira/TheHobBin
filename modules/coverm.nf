process coverm_assembly {
    conda "${projectDir}/env/coverm.yml"
    publishDir "${params.output}/02.Assembly/quantification"

    input:
    tuple val(sample_idl), path(reads_chopper), path(nanopore_assembly)

    output:
    tuple val(sample_idl), path("${sample_idl}/${sample_idl}_coverm.txt"), emit: coverm_assembly

    script:
        """
        coverm contig \\
        --threads ${task.cpus} \\
        --single ${reads_chopper} \\
        --mapper minimap2-ont \\
        --methods count rpkm tpm mean \\
        --reference ${nanopore_assembly} > ${params.output}/02.Assembly/quantification/${sample_idl}/${sample_idl}_coverm.txt 

        """
}

process run_coverm_bins {
    conda "./env/coverm.yml"
    storeDir "${params.output}/08.Bins/quantification"

    input:
    tuple val(sample_idl), path(reads_chopper), path(ch_refined_bins)

    output:
    tuple val(sample_idl), path("${sample_idl}/${sample_idl}_coverm_bins.txt"), emit: coverm_bins

    script:
        """
        mkdir -p ${sample_idl}

        coverm genome \\
        --threads ${task.cpus} \\
        --single ${reads_chopper} \\
        --mapper minimap2-ont \\
        --methods rpkm tpm mean relative_abundance \\
        --genome-fasta-files ${ch_refined_bins}/*.fa \\
        --output-file ${sample_idl}/${sample_idl}_coverm_bins.txt
        """
}

