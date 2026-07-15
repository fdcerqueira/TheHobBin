
process platon_db {
    conda "./env/platon.yml"
    storeDir "${params.platon_database}"

    input:
        val(platon_database)

    output:
        val(platon_database) 

    script:
    """
    mkdir -p ${params.platon_database}
    wget --tries=0 -O ${params.platon_database}/db.tar.gz https://zenodo.org/record/4066768/files/db.tar.gz \\
    2>&1 | tee downloaded_file.txt
    tar -xzf ${params.platon_database}/db.tar.gz -C ${params.platon_database}
    rm ${params.platon_database}/db.tar.gz
    """
}

process blast_db {
    conda "./env/platon.yml"
    //publishDir "${params.blast_database}"

    input:
        val(blast_database)
    
    output:
        val(blast_database)
    
    script:
    """
    mkdir -p ${params.blast_database}

    update_blastdb.pl \\
    --decompress \\
    --num_threads 0 \\
    core_nt

    mv core_nt* ${params.blast_database}

    wget -c 'ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz'
    tar -zxvf taxdump.tar.gz -C ${params.blast_database}
    rm taxdump.tar.gz

    wget 'ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz'
    tar -zxvf taxdb.tar.gz -C ${params.blast_database}
    rm taxdb.tar.gz

    wget -c 'ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz'
    gunzip -c nucl_gb.accession2taxid.gz > ${params.blast_database}/nucl_gb.accession2taxid
    """
}

process run_dnaapler_assembly {
    conda "./env/platon.yml"
    storeDir "${params.output}/06.Plasmids/dnaapler"

    input:
        tuple val(sample_idl), path(nanopore_assembly)

    output:
        tuple val(sample_idl), path("${sample_idl}/assembly"), emit:dnaapler_folder_assembly
        tuple val(sample_idl), path("${sample_idl}/assembly/${sample_idl}_reoriented.fasta"), emit:dnaapler_assembly

    script:
    """
    mkdir -p ${params.output}/06.Plasmids/dnaapler/${sample_idl}

    dnaapler all \\
    -i ${nanopore_assembly} \\
    -p ${sample_idl} \\
    -e 1e-10 \\
    -t ${task.cpus} \\
    -o ${sample_idl}/assembly \\
    --force 
    """
}


process run_dnaapler_bins {
    conda "./env/platon.yml"
    storeDir "${params.output}/06.Plasmids/dnaapler"
   
    input:
        tuple val(sample_idl), val(bin_name), path(bin_files)

    output:
        tuple val(sample_idl), path("${sample_idl}/bins"), emit:dnaapler_folder_bins
        tuple val(sample_idl), path("${sample_idl}/bins/${bin_name}/${bin_name}_reoriented.fasta"), emit:dnaapler_bins
        tuple val(sample_idl), val(bin_name), path("${sample_idl}/bins/${bin_name}/${bin_name}_reoriented.fasta"), emit:dnaapler_bins_named

    script:
    """
    mkdir -p ${params.output}/06.Plasmids/dnaapler/${sample_idl}/bins/${bin_name}

    dnaapler all \\
    -i ${bin_files} \\
    -p ${bin_name} \\
    -e 1e-10 \\
    -t ${task.cpus} \\
    -o ${sample_idl}/bins/${bin_name} \\
    --force
    """
}

process run_platon_assembly {

    conda "./env/platon.yml"
    storeDir "${params.output}/06.Plasmids/platon"

    input:
    tuple val(sample_idl), path(dnaapler_assembly)
    path(platon_db)

    output:
        tuple val(sample_idl), path("${sample_idl}/assembly"), emit:platon_folder_assembly
        tuple val(sample_idl), path("${sample_idl}/assembly/${sample_idl}.plasmid.fasta"), emit:platon_plasmids_assembly

    script:
    """
    mkdir -p ${sample_idl}/assembly

    platon \\
    --db ${params.platon_database}/db \\
    --meta \\
    --output ${sample_idl}/assembly \\
    --prefix ${sample_idl} \\
    --threads ${task.cpus} \\
    ${dnaapler_assembly}

    touch ${sample_idl}/assembly/${sample_idl}.plasmid.fasta
    """
}

process run_platon_bins {
    conda "./env/platon.yml"
    storeDir "${params.output}/06.Plasmids/platon"

    input:
    tuple val(sample_idl), val(bin_name), path(dnaapler_bins)
    path(platon_db)

    output:
        tuple val(sample_idl), val(bin_name), path("${sample_idl}/bins/${bin_name}"), emit:platon_folder_bins
        tuple val(sample_idl), val(bin_name), path("${sample_idl}/bins/${bin_name}/${bin_name}.plasmid.fasta"), emit:platon_plasmids_bins

    script:
    """
    mkdir -p ${sample_idl}/bins/${bin_name}

    platon \\
    --db ${params.platon_database}/db \\
    --meta \\
    --output ${sample_idl}/bins/${bin_name} \\
    --prefix ${bin_name} \\
    --threads ${task.cpus} \\
    ${dnaapler_bins}

    # platon omits the file when it calls no plasmid; downstream BLAST expects it to exist
    touch ${sample_idl}/bins/${bin_name}/${bin_name}.plasmid.fasta
    """
}


process run_blast_plasmids_assembly {
    conda "./env/platon.yml"
    storeDir "${params.output}/06.Plasmids/blast"
    
    input:
        tuple val(sample_idl), path(platon_plasmids)
        path(blast_db)
    output:
        tuple val(sample_idl), path("${sample_idl}/assembly/${sample_idl}_blast.txt")
        tuple val(sample_idl), path("${sample_idl}/assembly/${sample_idl}_verified_plasmids.txt")

    script:
    """
    mkdir -p ${sample_idl}/assembly
    touch ${sample_idl}/assembly/${sample_idl}_blast.txt

    if [[ -s ${platon_plasmids} ]] && grep -q ">" ${platon_plasmids}; then
      blastn -task megablast \\
        -query ${platon_plasmids} \\
        -db ${blast_db}/core_nt \\
        -outfmt '6 qseqid staxids bitscore pident evalue length qlen slen qcovs qcovhsp stitle' \\
        -num_threads ${task.cpus} \\
        -evalue 1e-5 \\
        -max_target_seqs 5 \\
        -max_hsps 1 \\
        -out ${sample_idl}/assembly/${sample_idl}_blast.txt

      while IFS= read -r i; do
        best=\$(awk -F'\\t' -v c="\$i" '\$1==c && \$3+0>max {max=\$3+0; t=\$11} END{print t}' ${sample_idl}/assembly/${sample_idl}_blast.txt)
        if [[ -z "\$best" ]]; then
            echo "${sample_idl}: \$i was not verified by BLAST search (no core_nt hit)." >> ${sample_idl}/assembly/${sample_idl}_verified_plasmids.txt
        elif echo "\$best" | grep -qi "plasmid"; then
            echo "${sample_idl}: \$i is a plasmid. Best hit: \$best" >> ${sample_idl}/assembly/${sample_idl}_verified_plasmids.txt
        else
            echo "${sample_idl}: \$i was not verified by BLAST search. Best hit: \$best" >> ${sample_idl}/assembly/${sample_idl}_verified_plasmids.txt
        fi
      done < <(grep ">" ${platon_plasmids} | sed 's/^>//; s/[[:space:]].*//')
    else
      echo "Platon found no plasmid in ${sample_idl}." > ${sample_idl}/assembly/${sample_idl}_verified_plasmids.txt
    fi
    """
}


process run_blast_plasmids_bins {
    conda "./env/platon.yml"
    storeDir "${params.output}/06.Plasmids/blast"

    input:
        tuple val(sample_idl), val(bin_name), path(platon_plasmids)
        path(blast_db)

    output:
        tuple val(sample_idl), val(bin_name), path("${sample_idl}/bins/${bin_name}/${bin_name}_blast.txt")
        tuple val(sample_idl), val(bin_name), path("${sample_idl}/bins/${bin_name}/${bin_name}_verified_plasmids.txt")

    script:
    """
    mkdir -p ${sample_idl}/bins/${bin_name}
    touch ${sample_idl}/bins/${bin_name}/${bin_name}_blast.txt

    if [[ -s ${platon_plasmids} ]] && grep -q ">" ${platon_plasmids}; then
      blastn -task megablast \\
        -query ${platon_plasmids} \\
        -db ${blast_db}/core_nt \\
        -outfmt '6 qseqid staxids bitscore pident evalue length qlen slen qcovs qcovhsp stitle' \\
        -num_threads ${task.cpus} \\
        -evalue 1e-5 \\
        -max_target_seqs 5 \\
        -max_hsps 1 \\
        -out ${sample_idl}/bins/${bin_name}/${bin_name}_blast.txt

      while IFS= read -r i; do
        # core_nt holds chromosomes too, so a hit alone proves nothing: take the contig's
        # best-scoring hit (col 3 = bitscore) and confirm only if its title says plasmid
        best=\$(awk -F'\\t' -v c="\$i" '\$1==c && \$3+0>max {max=\$3+0; t=\$11} END{print t}' ${sample_idl}/bins/${bin_name}/${bin_name}_blast.txt)
        if [[ -z "\$best" ]]; then
            echo "${bin_name}: \$i was not verified by BLAST search (no core_nt hit)." >> ${sample_idl}/bins/${bin_name}/${bin_name}_verified_plasmids.txt
        elif echo "\$best" | grep -qi "plasmid"; then
            echo "${bin_name}: \$i is a plasmid. Best hit: \$best" >> ${sample_idl}/bins/${bin_name}/${bin_name}_verified_plasmids.txt
        else
            echo "${bin_name}: \$i was not verified by BLAST search. Best hit: \$best" >> ${sample_idl}/bins/${bin_name}/${bin_name}_verified_plasmids.txt
        fi
      done < <(grep ">" ${platon_plasmids} | sed 's/^>//; s/[[:space:]].*//')
    else
      echo "Platon found no plasmid in ${bin_name}." > ${sample_idl}/bins/${bin_name}/${bin_name}_verified_plasmids.txt
    fi
    """
}
