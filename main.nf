#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.help=params.help||!params.input
if (params.help) {
    showHelp()
    exit 0
}

def showHelp() {
    log.info """

     The workflows available: -entry assembly; -entry binning; -entry long_reads

    Usage: 

    nextflow run my_pipe.nf -entry long_reads -c my_config.config 
 
    All the following options can modified in the config file:

    --max_jobs             : The maximum number of task to be done at the same time
    --cores                : The maximum number of threads to be used

    Assembly workflow:

    --input                : Path to input data (e.g "/home/user/samples/*_{1,2}.fastq.gz")
    --output               : Output directory [default: 'results'] (e.g. "/home/user/Desktop")
    --assembly_mode        : Mode of assembly [default: --k-min 21 --k-max 99 --k-step 12] 
                                              [regular: it needs to be specified the k-mer sizes] (e.g --assembly_mode regular --min 31 --max 127 --step 20)
                                              [no_mercy: same as previous with --no-mercy parameter included]  
    --coassembly           : true/false option if you desire to assemble the samples individually, or together
    --min                  : Minimum k-mer size for Megahit (odd number, default 21)
    --max                  : Maximum k-mer size for Megahit (odd number, default 99)
    --step                 : Increment of k-mer for Megahit                              
    --mem                  : Memory to be used by bbmap either to remove host contamination or read_recruitment step (e.g 20g)
    --host                 : In case host contamination is necessary, genome ID (e.g. NC_000913.2)                         
    --filter_taxa_interest : Alternative to host option. Use kraken2 to keep the taxa of interest by writting their NCBI taxonomic ID number. (.e.g. for bacteria and Archea "2 2157")
    --help                 : Display this help message

    Binning workflow:

    --overwrite_database   : (true/false), If you do not have the necessary databases for SqueezeMeta. They will be downloaded automatically. 
                             If you want to overwrite them just type --overwrite_database true. Otherwise it will just skip this step

    --database_dir         : Path to SqueezeMeta database (/path/to/squeezemeta/database)
    --assemb_in            : Path to the processed Illumina reads. If the assembly worflow was used there is no need to modify it.
    --assemb               : Path to the Megahit assembly. If the assembly workflow was used there is no need to modify it.

    Long_reads workflow:
    --input_long_reads     : Path to the input ONT reads. This can be paired with Illumina reads defined in --input.
    --long_reads_trim      : Select the program to trim the ONT reads (filtlong or fastplong)
    --racon_rounds         : Number of rounds for polishing ONT reads with Racon (min: 0, max: 4)
    --medaka_rounds        : Number of rounds for polishing ONT reads with Medaka after Racon or instead of Racon(min: 0, max:1)
    --bakta_min_contig_length: Minimum length of sequences for Bakta

    Databases:

    --download_databases   : (true/false) [default: false]. If a required database is not found at its declared path,
                             the run stops with an error listing what is missing. Re-run with --download_databases true
                             to fetch them automatically (not advised).

    NOTES: Polypolish is used automatically to polish ONT assembly, if Illumina reads are given as --input
           The Database sections has to be filled with the paths to the required databases. Downloading is slow and connection problems may occur. In such situation it will start from scratch again. so it is adviced to download them manually.

    Databases:

    blast_database="/path/to/database/NCBI_nt_core_X.X.X"
    checkm_database="/path/to/database/checkm"
    eggnog_database="/path/to/database/eggnog"
    bakta_database="/path/to/database/bakta_X.X"
    platon_database="/path/to/database/platon"
    genomad_database="/path/to/database/genomad"
    kraken2_database="/path/to/database/Kraken2_core_nt_X.X.X"
    gtdbtk_database="/path/to/database/GTDB_RXXX/releaseXXX"
    antismash_database="/path/to/database/antismash"

    
    """
}

//include modules for assembly
include {fastp} from "./modules/fastp.nf"
include {merge_process} from "./modules/merge_process.nf"
include {merge_reads_host} from "./modules/merge_reads_host.nf"
include {download_reference} from "./modules/download_reference.nf"
include {removeContaminations} from "./modules/removeContaminations.nf"
include {kraken2_remove_cont_illumina; extract_kraken2_reads_illumina} from "./modules/kraken2_illumina_reads.nf"
include {megahit; megahit_coassembly} from "./modules/megahit.nf"
include {metaquast; metaquast_coassembly} from "./modules/metaquast.nf"
include {read_r_bbwrap; read_r_bbwrap_coassembly} from "./modules/read_r_bbwrap.nf"

//include modules for Binning
include {sample_id_squeezemeta} from "./modules/sample_tests.nf"
include {mkdir_database; download_databases; test_install;test_install_no_db; remove_database; create_status_file} from "./modules/processdatabase.nf"
include {squeezemeta; tables_squeezemeta} from "./modules/squeezemeta.nf"

//include modules for long reads================================================================================================================================================================

include {fastplong; porechop_abi; filtlong; nanoplot} from "./modules/long_reads.nf"
include {remove_cont_long} from "./modules/removeContaminations_long.nf"
include {kraken2_db} from "./modules/kraken2_database.nf"
include {fastp_longworkflow; kraken2_remove_cont_long; extract_kraken2_reads; kraken2_remove_cont_short; extract_kraken2_reads_short} from "./modules/remove_cont_long_kraken2.nf"
include {flye; metaquast_long_reads; metaquast_long_reads_medaka} from "./modules/long_read_assembly.nf"
include {meta_MDBG; myloasm} from "./modules/flye_alternatives.nf"

//polishing
include {minimap2_assembly; minimap2_assembly_2; minimap2_assembly_3; minimap2_assembly_4} from "./modules/minimap2.nf"
include {racon; racon2; racon3; racon4} from "./modules/racon_polishing.nf"                                                                                                                                          
include {medaka} from "./modules/medaka_polishing.nf"
include {polypolish_index; polypolish} from "./modules/polypolish.nf"

//functional analysis
include {bakta_db ;run_bakta_assembly ; run_bakta_bins} from "./modules/bakta.nf"
include {eggnog_db ;run_eggnog_assembly; run_eggnog_bins} from "./modules/eggnog.nf"
include {run_abricate_assembly; run_abricate_bins} from "./modules/abricate.nf"
include {blast_db; platon_db; run_dnaapler_assembly; run_dnaapler_bins; run_platon_assembly; run_platon_bins; run_blast_plasmids_assembly; run_blast_plasmids_bins} from "./modules/platon.nf"
include {genomad_db; run_genomad_assembly; run_genomad_bins} from "./modules/genomad.nf"
include {antismash_db; run_antismash_assembly; run_antismash_bins} from "./modules/antismash.nf"

//long reads binning
include {gtdbtk_db; run_gtdbtk} from "./modules/gtdbtk.nf"
include {depth_mapping; depth_creation; run_metabat2; run_maxbin2} from "./modules/metabat2.nf"
include {run_dastool} from "./modules/dastool.nf"
include {checkm_db; run_checkm} from "./modules/checkm.nf"
include {coverm_assembly; run_coverm_bins} from "./modules/coverm.nf"

//Assembly workflow
workflow assembly {
    read_ch=Channel.fromFilePairs(params.input,).view()
    fastp(read_ch)
    
    //remove host contamination/get taxa of interes
    switch( [params.host,params.filter_taxa_interest]){
        case {it[0]==null && it[1]==null}:
            merge_process(fastp.out[0]).view()
            processed_reads=merge_process.out[0]
            break
        case {it[0]!=null && it[1]==null}:
            download_reference(params.host,params.py_script).view()
            merge_reads_host(fastp.out[0]).view()
            removeContaminations(merge_reads_host.out[0],download_reference.out)
            processed_reads=removeContaminations.out[0]
            break
        case {it[0]==null && it[1]!=null}:
            if (!file(params.kraken2_database).exists()){
                ch_k2db=kraken2_db(params.kraken2_database).first()
            } else {
                ch_k2db=Channel.value(params.kraken2_database)
            }
            if (params.input){
                merge_process(fastp.out[0]).view()
                kraken2_remove_cont_illumina(merge_process.out.merged_reads,ch_k2db)
                extract_kraken2_reads_illumina(
                                                kraken2_remove_cont_illumina.out.kraken2_short_all
                                                .join(merge_process.out.merged_reads )
                )
                processed_reads=extract_kraken2_reads_illumina.out.decontaminated_reads_short
                }
        break
        default:
            error "Unsuported combination of parameters: host=${params.host}, taxa of interest=${params.filter_taxa_interest}"
    }

     def mode_message="Selected assembly mode: ${params.assembly_mode}"
        if (params.assembly_mode=="no_mercy" || params.assembly_mode=="regular") {
            mode_message += " with the parameters: k-min=${params.min}, k-max=${params.max}, k-step=${params.step}"
        }

    Channel.value(mode_message).view()

    if (params.coassembly){

        processed_reads
            .map {id,reads -> reads}
            .flatten()
            .collect()
            .set {reads_for_coassembly}

        megahit_coassembly(reads_for_coassembly)
        metaquast_coassembly(megahit_coassembly.out.assembly)
        read_r_bbwrap_coassembly(processed_reads,megahit_coassembly.out.assembly)
    } else {
        megahit(processed_reads)
        metaquast(megahit.out.assembly)

        //to avoid crossed pairs between reads processing and assemblies
        processed_reads
            .join(megahit.out.assembly)
            .set {reads_with_assembly}

        read_r_bbwrap(reads_with_assembly)
    }
}


//workflow binning
workflow binning {
    println("${workDir}")
    sample_id_squeezemeta(params.sample_tests,params.assemb_in,params.sample_squeezemeta)
    
        
    if (!file(params.database_dir).exists()||!file("${params.database_dir}/.status").exists()) {
        println "Creating/overwriting ${params.database_dir} directory"
        mkdir_database(params.database_dir)
        create_status_file(params.database_dir)
        download_databases(params.database_dir)
        //test_install(params.database_dir, download_databases.out.downloaded_dir)
        squeezemeta(assembly,params.test_id,params.database_dir)
        tables_squeezemeta(squeezemeta.out.all_results)
    } else if (params.overwrite_database) {
        println "Overwriting ${params.database_dir} directory"
        remove_database(params.database_dir)
        mkdir_database(params.database_dir)
        create_status_file(params.database_dir)
        download_databases(params.database_dir)
        squeezemeta(assembly,params.test_id,params.database_dir)
    } else {
        println "Proceeding with the pipeline"
        squeezemeta(assembly,params.test_id,params.database_dir)
    }

    if (!params.coassembly){
        tables_squeezemeta(squeezemeta.out.all_results)
    }
}
  


//Workflow long-read assembly
workflow long_reads {

    def databases=[
            "CheckM":params.checkm_database,
            "GTDB-Tk":params.gtdbtk_database,
            "Bakta":params.bakta_database,
            "EggNOG":params.eggnog_database,
            "Platon":params.platon_database,
            "BLAST":params.blast_database,
            "Genomad":params.genomad_database,
            "Antismash":params.antismash_database,
            "Kraken2":params.kraken2_database
        ]
        
    // Define download processes for each database (local to this workflow)
    def downloadProcesses=[
        "CheckM":{dbPath ->
            checkm_db(dbPath)
        },
        "GTDB-Tk":{dbPath ->
            gtdbtk_db(dbPath)
        },
        "Bakta":{dbPath ->
            bakta_db(dbPath)
        },
        "EggNOG":{dbPath ->
            eggnog_db(dbPath)
        },
        "Platon":{dbPath ->
            platon_db(dbPath)
        },
        "BLAST":{dbPath ->
            blast_db(dbPath)
        },
        "Genomad":{dbPath ->
            genomad_db(dbPath)
        },
        "Antismash":{dbPath ->
            antismash_db(dbPath)
        },
        "Kraken2":{dbPath ->
            kraken2_db(dbPath)
        },

    ]
    
    //function to check for missing databases, prompt the user, and create channels
    def checkAndDownloadDatabases={dbMap,procMap ->
        def databaseChannels=[:]
        def missingDatabases=[]
        
        dbMap.each {dbName,dbPath ->
            if (!file(dbPath).exists()) {
                missingDatabases.add(dbName)
                println "Database '$dbName' not found at '$dbPath'."
            } else {
                println "Database '$dbName' found at '$dbPath'."
                databaseChannels[dbName]=Channel.fromPath(dbPath).collect()
            }
        }
        if (missingDatabases) {
            if (params.download_databases) {
                missingDatabases.each {dbName ->
                    databaseChannels[dbName]=procMap[dbName](dbMap[dbName]).first()
                }
            } else {
                error """The following databases are missing: ${missingDatabases.join(', ')}.
Either set their paths in the config file, or re-run with --download_databases true to fetch them automatically.
Downloading is slow and needs a lot of disk space, so it is adviced to download them manually."""
            }
        } else {
            println "All databases are present."
        }
        return databaseChannels
    }
    
    def databaseChannels=checkAndDownloadDatabases(databases,downloadProcesses)
    def ch_checkm_db=databaseChannels["CheckM"]
    def ch_gtdbtk_db=databaseChannels["GTDB-Tk"]
    def ch_bakta_db=databaseChannels["Bakta"]
    def ch_eggnog_db=databaseChannels["EggNOG"]
    def ch_platon_db=databaseChannels["Platon"]
    def ch_blast_db=databaseChannels["BLAST"]
    def ch_genomad_db=databaseChannels["Genomad"]
    def ch_antismash_db=databaseChannels["Antismash"]
    def ch_kraken2_db=databaseChannels["Kraken2"]


    //long reads channel
    Channel
        .fromPath(params.input_long_reads + "/*_1.fastq.gz")
        .map {path -> tuple(path.baseName.replaceAll(".fastq",""),path)}
        .map {
            sample_idl,reads_long -> 
            println("Sample ID: ${sample_idl}, Long Reads: ${reads_long}")
            tuple(sample_idl,reads_long)
        }
        .set {reads_long}
  
    if (params.input) {
        reads_short=Channel.fromFilePairs(params.input,)
        fastp_longworkflow(reads_short)
        porechop_abi(reads_long)
        filtlong(fastp_longworkflow.out.reads,porechop_abi.out.reads_porechop)
        long_reads_trimmed=filtlong.out.reads_filtlong
    } else {
        fastplong(reads_long)
        long_reads_trimmed=fastplong.out.reads_fastplong
    }
    
    nanoplot(long_reads_trimmed)

    //remove host contamination/select taxa for long reads
    switch( [params.host,params.filter_taxa_interest]){
        case {it[0]==null && it[1]==null}:
            reads_assembly=long_reads_trimmed
            break
        case {it[0]!=null && it[1]==null}:
            download_reference(params.host,params.py_script).view()
            remove_cont_long(long_reads_trimmed,download_reference.out)
            reads_assembly=remove_cont_long.out.long_reads_host_remove 
            
            if (params.input){
            remove_cont_short(fastp_longworkflow.out.reads,download_reference.out)
            reads_short_clean=remove_cont_short.out.short_reads_host_remove
            }
            break
        case {it[0]==null && it[1]!=null}:
            if (params.input){
                kraken2_remove_cont_short(fastp_longworkflow.out.reads,ch_kraken2_db)
                extract_kraken2_reads_short(kraken2_remove_cont_short.out.kraken2_report_short,
                                            kraken2_remove_cont_short.out.kraken2_output_short,
                                            fastp_longworkflow.out.reads)
                reads_short_clean=extract_kraken2_reads_short.out.decontaminated_reads_short
            }

            kraken2_remove_cont_long(long_reads_trimmed,ch_kraken2_db)
            extract_kraken2_reads(kraken2_remove_cont_long.out.kraken2_report,
                                  kraken2_remove_cont_long.out.kraken2_output,
                                  long_reads_trimmed)
            reads_assembly=extract_kraken2_reads.out.decontaminated_reads
            break

        default:
            error "Unsuported combination of parameters: host=${params.host}, taxa of interest=${params.filter_taxa_interest}"
    }
  
    if (params.assembler=="flye") {
        flye(reads_assembly)
        ont_assembly=flye.out.fasta_assembly
    } else if (params.assembler=="myloasm"){
        myloasm(reads_assembly)
        ont_assembly=myloasm.out.fasta_assembly
    } else {
        meta_MDBG(reads_assembly)
        ont_assembly=meta_MDBG.out.fasta_assembly
    }

   if (params.input) {
        polypolish_index(ont_assembly.join(reads_short_clean))
        polypolish(polypolish_index.out.alignment1_polypolish
                    .join(polypolish_index.out.alignment2_polypolish)
                    .join(ont_assembly)
                  )
        ch_polished_asm=polypolish.out.polypolish_assembly
    } 

    //polishing nanopore assembly
    if (params.racon_rounds==0&&!params.input) {
        ch_polished_asm=ont_assembly
    }

    if (params.racon_rounds>0) {
        minimap2_assembly(reads_assembly.join(ont_assembly))

        if (params.racon_rounds<2) {
            racon(reads_assembly.join(minimap2_assembly.out.assembly_paf).join(ont_assembly))
            ch_polished_asm=racon.out.racon_assembly
        }
        else {
            racon(reads_assembly.join(minimap2_assembly.out.assembly_paf).join(ont_assembly))
            ch_polished_asm=racon.out.racon_assembly
        }
    }
    
    if (params.racon_rounds>1) {
        minimap2_assembly_2(reads_assembly.join(racon.out.racon_assembly))

        if (params.racon_rounds<3) {
            racon2(reads_assembly.join(minimap2_assembly_2.out.assembly_paf1).join(racon.out.racon_assembly))
            ch_polished_asm=racon2.out.racon_assembly1
        }

        else {
            racon2(reads_assembly.join(minimap2_assembly_2.out.assembly_paf1).join(racon.out.racon_assembly))
            ch_polished_asm=racon2.out.racon_assembly1
        }
    }

    if (params.racon_rounds>2) {
            minimap2_assembly_3(reads_assembly.join(racon2.out.racon_assembly1))

        if (params.racon_rounds<4) {
            racon3(reads_assembly.join(minimap2_assembly_3.out.assembly_paf2).join(racon2.out.racon_assembly1))
            ch_polished_asm=racon3.out.racon_assembly2
        }

        else {
            racon3(reads_assembly.join(minimap2_assembly_3.out.assembly_paf2).join(racon2.out.racon_assembly1))
            ch_polished_asm=racon3.out.racon_assembly2
        }
    }


    if (params.racon_rounds==4 ) {
        minimap2_assembly_4(reads_assembly.join(racon3.out.racon_assembly2))
        racon4(reads_assembly.join(minimap2_assembly_4.out.assembly_paf3).join(racon3.out.racon_assembly2))
        ch_polished_asm=racon4.out.racon_assembly3
    }
    

    if (params.medaka_round) {
        medaka(reads_assembly.join(ch_polished_asm))
        ch_polished_asm=medaka.out.medaka_assembly
        metaquast_long_reads_medaka(ch_polished_asm)
    } else {
       metaquast_long_reads(ch_polished_asm)
    }

    depth_mapping(ch_polished_asm.join(reads_assembly))
    depth_creation(depth_mapping.out.bam_depth)
    run_metabat2(ch_polished_asm.join(depth_creation.out.depth_bins))
    run_maxbin2(ch_polished_asm.join(depth_creation.out.depth_bins))

    run_dastool(ch_polished_asm
                .join(run_metabat2.out.bins_metabat2)
                .join(run_maxbin2.out.bins_maxbin2))

    ch_refined_bins=run_dastool.out.refined_bins
    run_checkm(ch_refined_bins,ch_checkm_db)
    run_gtdbtk(ch_refined_bins,ch_gtdbtk_db)
    run_coverm_bins(reads_assembly.join(ch_refined_bins))
    
    //per-bin channel: one entry per refined bin, expanded from the DAS_Tool output
    ch_bin_files_parallelized=ch_refined_bins.flatMap {sample_idl,bins_dir ->
        file("${bins_dir}/*.fa").collect {bin_file ->
            tuple(sample_idl,bin_file.baseName,bin_file)
        }
    }

    run_bakta_assembly(ch_polished_asm,ch_bakta_db)
    run_bakta_bins(ch_bin_files_parallelized,ch_bakta_db)

    run_eggnog_assembly(run_bakta_assembly.out.bakta_folder_assembly,ch_eggnog_db)
    run_eggnog_bins(run_bakta_bins.out.bakta_folder_bin,ch_eggnog_db)

    run_abricate_assembly(ch_polished_asm)
    run_abricate_bins(ch_bin_files_parallelized)
    
    run_antismash_assembly(run_bakta_assembly.out.bakta_folder_assembly,ch_antismash_db)
    run_antismash_bins(run_bakta_bins.out.bakta_folder_bin,ch_antismash_db)

    run_dnaapler_assembly(ch_polished_asm)
    run_dnaapler_bins(ch_bin_files_parallelized)

    run_platon_assembly(run_dnaapler_assembly.out.dnaapler_assembly,ch_platon_db)
    run_platon_bins(run_dnaapler_bins.out.dnaapler_bins_named,ch_platon_db)

    run_blast_plasmids_assembly(run_platon_assembly.out.platon_plasmids_assembly,ch_blast_db)
    run_blast_plasmids_bins(run_platon_bins.out.platon_plasmids_bins,ch_blast_db)
    
    run_genomad_assembly(run_dnaapler_assembly.out.dnaapler_assembly,ch_genomad_db)
    run_genomad_bins(run_dnaapler_bins.out.dnaapler_bins,ch_genomad_db)
}
  


