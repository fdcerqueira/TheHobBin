#!/bin/bash

path="$1"

cd "$path"

ls *.fastq.gz > the.samples

while IFS= read -r line
do
    basename "$line"
done < the.samples > testt.samples