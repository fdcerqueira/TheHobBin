#!/usr/bin/env python3
#-- coding: utf-8 --

"""
Created on Wed Apr 27 17:54:26 2022
@author: chico
"""

from Bio import Entrez
from Bio import SeqIO
import sys
import os

#system input
WD = sys.argv[1]
ref_id = sys.argv[2]

#set work directory
os.chdir(WD)

#mail to identify myself to NCBI
Entrez.email = "francisco.cerqueira@ait.ac.at"

#download and write file to specified directory (sys.argv[1])
record = Entrez.efetch(db="nucleotide", id=ref_id, rettype="fasta", retmode="text")

filename = '{}.fasta'.format(ref_id)
print('Writing: {}'.format(filename),"to",WD)
with open(filename, 'w') as f:
    f.write(record.read())