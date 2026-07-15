args <- commandArgs(trailingOnly = TRUE)
# use shell input
path <- as.character(args[1])
setwd(path)

cat("Current working directory:", getwd(), "\n")

path1 <- file.path(path)

samples<-sort(list.files(path1,pattern="testt.samples"))

cat("Found samples:", samples, "\n")

table<-read.table(samples)
sample_names<-gsub("^M_|_R[12].fastq.gz","",table$V1)
pair<-c("pair1","pair2")
pairs<-rep(pair, times= (length(sample_names)/2))
table_final<-cbind(sample_names,table,pairs)



# Save the output file in the process work directory
output_path <- file.path(getwd(), "test.samples")
write.table(table_final, output_path,
            sep = "\t",
            row.names = F, col.names = F,
            quote = F)

cat("Output file created:", output_path, "\n")

# Save the output file in the assemb_in directory
#output_path_assemb_in <- file.path(getwd(), "test.samples")
#write.table(table_final, output_path_assemb_in,
#            sep = "\t",
#            row.names = F, col.names = F,
#            quote = F)

cat("Output file created in assemb_in directory:", output_path_assemb_in, "\n")
