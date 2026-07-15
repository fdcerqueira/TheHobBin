#!/usr/bin/env python3

import os
from graphviz import Digraph


os.makedirs("output", exist_ok=True)

dot = Digraph("metagenomics_dag", format="png")
dot.attr(rankdir="TB",splines="ortho",bgcolor="white")

with dot.subgraph(name="cluster_input") as input_cluster:
    input_cluster.attr(
        style="filled",
        fillcolor="lightgrey",
        fontsize="16",
        fontname="Arial"
    )

    input_cluster.node("FASTQ","Illumina fastq",shape="folder",fillcolor="#f9f871",style="filled")
    input_cluster.node("FASTQLONG","ONT fastq",shape="folder",fillcolor="#f9f871",style="filled")
    input_cluster.node("REF","download_reference.py",shape="rectangle",fillcolor="#ccdceb",style="filled")
    input_cluster.node("DATABASES","\n Kraken2 \n checkM \n GTDB-Tk \n Bakta \n EggNOG \n Platon \n BLAST core_nt \n Genomad \n Antismash \n SqueezeMeta",shape="cylinder",fillcolor="#ffffff",style="filled")

#assembly Cluster
with dot.subgraph(name="cluster_assembly") as workflow_assembly:
    workflow_assembly.attr(
        style="filled",
        fillcolor="#ffd6a5",
        fontsize="16",
        fontname="Arial"
    )

    workflow_assembly.attr("node",shape="rectangle",style="filled",fontname="Arial")

    workflow_assembly.node("QC","Fastp",fillcolor="#ffffff")
    workflow_assembly.node("HOST","Host/contaminant removal (BBMap)",fillcolor="#ccdceb")
    workflow_assembly.node("KRAKEN2","Taxa of interest \n Kraken2/KrakenTools",fillcolor="#ccdceb")
    workflow_assembly.node("MEGAHIT","Megahit\nAssembly/Co-assembly",fillcolor="#ffffff")
    workflow_assembly.node("QUAST","Quast",fillcolor="#ffffff")
    workflow_assembly.node("BBMAP","BBmap\nAlign reads back to assembly",fillcolor="#ffffff")

with dot.subgraph(name="cluster_binning") as workflow_binning:
    workflow_binning.attr(
        style="filled",
        fillcolor="#20B2AA",
        fontsize="16",
        fontname="Arial")

    workflow_binning.attr("node",shape="rectangle",style="filled",fontname="Arial")

    workflow_binning.node("TEST","Check databases",fillcolor="#ffffff")
    workflow_binning.node("SAMPLES","Create samples file",fillcolor="#ffffff")
    workflow_binning.node("SQUEEZEMETA","SqueezeMeta",fillcolor="#ffffff")

#ONT workflow
with dot.subgraph(name="cluster_ont") as workflow_ont:
    workflow_ont.attr(
        style="filled",
        fillcolor="#FFFACD",
        fontsize="16",
        fontname="Arial")

    workflow_ont.attr("node",shape="rectangle",style="filled",fontname="Arial")

    workflow_ont.node("FASTPLONG","Fastplong",fillcolor="#ccdceb")
    workflow_ont.node("PORECHOP","Porechop_abi",fillcolor="#ccdceb")
    workflow_ont.node("FILTLONG","Filtlong",fillcolor="#ccdceb")
    workflow_ont.node("FASTPL","Fastp",fillcolor="#ccdceb")
    workflow_ont.node("NANOPLOT","Nanoplot",fillcolor="#ffffff")
    workflow_ont.node("HOSTLONG","Host/contaminant removal (BBMap)",fillcolor="#ccdceb")
    workflow_ont.node("KRAKEN2LONG","Taxa of interest \n Kraken2/KrakenTools",fillcolor="#ccdceb")
    workflow_ont.node("FLYE","Flye",fillcolor="#ccdceb")
    workflow_ont.node("MYLOASM","myloasm",fillcolor="#ccdceb")
    workflow_ont.node("METAMDBG","MetaMDBG",fillcolor="#ccdceb")
    workflow_ont.node("RACON","Racon polishing",fillcolor="#ccdceb")
    workflow_ont.node("MEDAKA","Medaka polishing",fillcolor="#ccdceb")
    workflow_ont.node("POLYPOLISH","Polypolish with Illumina reads",fillcolor="#ccdceb")
    workflow_ont.node("FINALASSEMBLY","Final assembly",fillcolor="#ffffff")
    workflow_ont.node("QUASTLONG","Quast",fillcolor="#ffffff")
    workflow_ont.node("METABAT2","Metabat2",fillcolor="#ffffff")
    workflow_ont.node("MAXBIN2","Maxbin2",fillcolor="#ffffff")
    workflow_ont.node("DASTOOL","DasTool",fillcolor="#ffffff")
    workflow_ont.node("CHECKM","CheckM",fillcolor="#ffffff")
    workflow_ont.node("GTDBTK","GTDB-Tk",fillcolor="#ffffff")
    workflow_ont.node("COVERM","CoverM",fillcolor="#ffffff")
    workflow_ont.node("BAKTA","Bakta MAGs \n Bakta assembly",fillcolor="#ffffff")
    workflow_ont.node("EGGNOG","EggNOG MAGs \n EggNOG assembly",fillcolor="#ffffff")
    workflow_ont.node("ABRICATE","Abricate MAGs \n Abricate assembly",fillcolor="#ffffff")
    workflow_ont.node("ANTISMASH","AntiSMASH MAGs \n AntiSMASH assembly",fillcolor="#ffffff")
    workflow_ont.node("DNAPLER","Dnaapler MAGs \n Dnaapler assembly",fillcolor="#ffffff")
    workflow_ont.node("PLATON","Platon MAGs \n Platon assembly",fillcolor="#ffffff")
    workflow_ont.node("BLAST","BLAST plasmid confirmation MAGs \n BLAST plasmid confirmation assembly",fillcolor="#ffffff")
    workflow_ont.node("GENOMAD","Genomad MAGs \n Genomad assembly",fillcolor="#ffffff")
    workflow_ont.node("QUASTBINS","Quast MAGs",fillcolor="#ffffff")

#assembly edges
dot.edge("FASTQ","QC",color="#555555",penwidth="2")
dot.edge("QC","KRAKEN2",color="#555555",penwidth="2",style="dashed")
dot.edge("QC","HOST",color="#555555",penwidth="2",style="dashed")
dot.edge("REF","HOST",color="#555555",penwidth="2",style="dashed")
dot.edge("HOST","MEGAHIT",color="#555555",penwidth="2")
dot.edge("KRAKEN2","MEGAHIT",color="#555555",penwidth="2")
dot.edge("MEGAHIT","QUAST",color="#555555",penwidth="2")
dot.edge("MEGAHIT","BBMAP",color="#555555",penwidth="2")

#binning edges
dot.edge("MEGAHIT","TEST",color="#555555",penwidth="2")
dot.edge("TEST","SAMPLES",color="#555555",penwidth="2")
dot.edge("SAMPLES","SQUEEZEMETA",color="#555555",penwidth="2")

#ONT edges
dot.edge("FASTQLONG","FASTPLONG",color="#555555",penwidth="2",style="dashed")
dot.edge("FASTQLONG","PORECHOP",color="#555555",penwidth="2",style="dashed")
dot.edge("PORECHOP","FILTLONG",color="#555555",penwidth="2",style="dashed")
dot.edge("FASTQ","FASTPL",color="#555555",penwidth="2",style="dashed")
dot.edge("FASTPL","HOSTLONG",color="#555555",penwidth="2",style="dashed")
dot.edge("FASTPL","KRAKEN2LONG",color="#555555",penwidth="2",style="dashed")
dot.edge("FASTPLONG","NANOPLOT",color="#555555",penwidth="2")
dot.edge("FILTLONG","NANOPLOT",color="#555555",penwidth="2")
dot.edge("FILTLONG","HOSTLONG",color="#555555",penwidth="2",style="dashed")
dot.edge("FASTPLONG","HOSTLONG",color="#555555",penwidth="2",style="dashed")
dot.edge("FILTLONG","KRAKEN2LONG",color="#555555",penwidth="2",style="dashed")
dot.edge("FASTPLONG","KRAKEN2LONG",color="#555555",penwidth="2",style="dashed")
dot.edge("HOSTLONG","FLYE",color="#555555",penwidth="2",style="dashed")
dot.edge("KRAKEN2LONG","FLYE",color="#555555",penwidth="2",style="dashed")
dot.edge("HOSTLONG","MYLOASM",color="#555555",penwidth="2",style="dashed")
dot.edge("KRAKEN2LONG","MYLOASM",color="#555555",penwidth="2",style="dashed")
dot.edge("HOSTLONG","METAMDBG",color="#555555",penwidth="2",style="dashed")
dot.edge("KRAKEN2LONG","METAMDBG",color="#555555",penwidth="2",style="dashed")
dot.edge("FLYE","RACON",color="#555555",penwidth="2",style="dashed")
dot.edge("RACON","MEDAKA",color="#555555",penwidth="2",style="dashed")
dot.edge("FLYE","POLYPOLISH",color="#555555",penwidth="2",style="dashed")
dot.edge("FLYE","FINALASSEMBLY",color="#555555",penwidth="2")
dot.edge("MYLOASM","RACON",color="#555555",penwidth="2",style="dashed")
dot.edge("MYLOASM","POLYPOLISH",color="#555555",penwidth="2",style="dashed")
dot.edge("MYLOASM","FINALASSEMBLY",color="#555555",penwidth="2")
dot.edge("METAMDBG","RACON",color="#555555",penwidth="2",style="dashed")
dot.edge("METAMDBG","POLYPOLISH",color="#555555",penwidth="2",style="dashed")
dot.edge("METAMDBG","FINALASSEMBLY",color="#555555",penwidth="2")
dot.edge("RACON","FINALASSEMBLY",color="#555555",penwidth="2")
dot.edge("MEDAKA","FINALASSEMBLY",color="#555555",penwidth="2")
dot.edge("POLYPOLISH","FINALASSEMBLY",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","QUASTLONG",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","METABAT2",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","MAXBIN2",color="#555555",penwidth="2")
dot.edge("MAXBIN2","DASTOOL",color="#555555",penwidth="2")
dot.edge("METABAT2","DASTOOL",color="#555555",penwidth="2")
dot.edge("DASTOOL","CHECKM",color="#555555",penwidth="2")
dot.edge("DASTOOL","GTDBTK",color="#555555",penwidth="2")
dot.edge("DASTOOL","COVERM",color="#555555",penwidth="2")
dot.edge("DASTOOL","BAKTA",color="#555555",penwidth="2")
dot.edge("DASTOOL","EGGNOG",color="#555555",penwidth="2")
dot.edge("DASTOOL","ANTISMASH",color="#555555",penwidth="2")
dot.edge("DASTOOL","ABRICATE",color="#555555",penwidth="2")
dot.edge("DASTOOL","GENOMAD",color="#555555",penwidth="2")
dot.edge("DASTOOL","DNAPLER",color="#555555",penwidth="2")
dot.edge("DNAPLER","PLATON",color="#555555",penwidth="2")
dot.edge("PLATON","BLAST",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","GTDBTK",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","BAKTA",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","EGGNOG",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","ANTISMASH",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","ABRICATE",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","GENOMAD",color="#555555",penwidth="2")
dot.edge("FINALASSEMBLY","DNAPLER",color="#555555",penwidth="2")
dot.edge("DASTOOL","QUASTBINS",color="#555555",penwidth="2")

with dot.subgraph(name="cluster_legend") as legend:
    legend.attr(rank="min",style="filled",fillcolor="white",color="none",label="")

    legend.node("LEGEND_MAIN", """<
        <TABLE BORDER="0" CELLBORDER="0" CELLSPACING="8" CELLPADDING="0">
          <TR>
            <TD><TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0"><TR><TD WIDTH="20" HEIGHT="15" BGCOLOR="#ffd6a5"></TD></TR></TABLE></TD>
            <TD ALIGN="LEFT">Assembly</TD>

            <TD><TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0"><TR><TD WIDTH="20" HEIGHT="15" BGCOLOR="#20B2AA"></TD></TR></TABLE></TD>
            <TD ALIGN="LEFT">Binning</TD>

            <TD><TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0"><TR><TD WIDTH="20" HEIGHT="15" BGCOLOR="#FFFACD"></TD></TR></TABLE></TD>
            <TD ALIGN="LEFT">ONT</TD>

            <TD WIDTH="30"></TD>

            <TD><TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0"><TR><TD WIDTH="20" HEIGHT="15" BGCOLOR="#ccdceb"></TD></TR></TABLE></TD>
            <TD>
              <TABLE BORDER="0" CELLBORDER="0"><TR>
                <TD><FONT POINT-SIZE="14" FACE="Arial"><B>╍ ╍ ╍ ╍▶</B></FONT></TD>
              </TR></TABLE>
            </TD>
            <TD ALIGN="LEFT">Optional</TD>
          </TR>
        </TABLE>
    >""",shape="plaintext",fontname="Arial")

dot.render("output/workflow_diagram",view=False)
