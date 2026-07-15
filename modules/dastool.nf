process run_dastool {

    conda "./env/dastool.yml"
    storeDir "${params.output}/08.Bins/refined_bins"
    errorStrategy 'ignore'

    input:
    tuple val(sample_idl), path(nanopore_assembly), path(bins_metabat2), path(bins_maxbin2)

    output:
    tuple val(sample_idl), path("${sample_idl}"), emit: refined_bins

    script:
    """
    DASTOOL_PATH=\$(dirname \$(which DAS_Tool))

    \$DASTOOL_PATH/Fasta_to_Contig2Bin.sh -i ${bins_maxbin2}  -e fasta > maxbin.contigs2bin.tsv
    \$DASTOOL_PATH/Fasta_to_Contig2Bin.sh -i ${bins_metabat2} -e fa    > metabat2.contigs2bin.tsv

    \$DASTOOL_PATH/DAS_Tool \\
        -t ${task.cpus} \\
        --score_threshold 0.2 \\
        -i maxbin.contigs2bin.tsv,metabat2.contigs2bin.tsv \\
        -l maxbin,metabat2 \\
        -c ${nanopore_assembly} \\
        --write_bins \\
        -o ${sample_idl}_refined

    # collect the refined bins (.fa) into a per-sample directory for checkm/gtdbtk/coverm
    mkdir -p ${sample_idl}
    mv ${sample_idl}_refined_DASTool_bins/*.fa ${sample_idl}/
    """
}




