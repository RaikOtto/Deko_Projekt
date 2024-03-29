#!/usr/bin/env Rscript

library("devtools")
load_all("~/artdeco")
source("~/Deko_Projekt/CIBERSORT_package/CIBERSORT.R")
library("stringr")
library("bseqsc")
library("stringr")
library("reshape2")
library("bseqsc")
library("dplyr")
library("optparse")

option_list = list(
    make_option(c("-i", "--index"), type="integer", default=NULL,help="dataset file name", metavar="integer")
);
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
input_index = opt$index

#remove(props)

datasets = c(
    "Alvarez.S105.tsv", #1
    "Charite.S23.tsv", #2
    "Diedisheim.S62.tsv", #3
    "Master.S20.tsv", #4
    "Missiaglia.S88.tsv", #5
    "Sadanandam.S29.tsv", #6
    "Scarpa.S29.tsv") #7

<<<<<<< HEAD

#datasets = c(
#    "Alvarez.S100.tsv", #1
#    "Charite.S17.tsv", #2
#    "Diedisheim.S4.tsv", #3
#    "Master.S14.tsv", #4
#    "Sato.S32.tsv") #5

dataset_name = datasets[input_index]
i_filename = "~/Deko_Projekt/Data/Publication_datasets/"
=======
datasets = c(
    "Alvarez.S100.tsv", #1
    "Charite.S17.tsv", #2
    "Diedisheim.S4.tsv", #3
    "Master.S14.tsv", #4
    "Sato.S22.tsv") #5

dataset_name = datasets[input_index]
#i_filename = "~/Deko_Projekt/Data/Publication_datasets/"
i_filename = "~/Deko_Projekt/Data/Publication_datasets/NEN/"
>>>>>>> 44d98cb2c9a8d063c5710e6982bbf8436bd6d880
i_filename = paste(i_filename, dataset_name, sep ="")

#dataset_name = "Fadista"
#i_filename = "~/Deko_Projekt/Data/Human_differentiated_pancreatic_islet_cells_Bulk/Fadista.tsv"

expr_raw = read.table(i_filename,sep="\t", stringsAsFactors =  F, header = T, row.names = 1,as.is = F)

colnames(expr_raw) = str_replace(colnames(expr_raw), pattern = "^X", "")
expr_raw[1:5,1:5]
dim(expr_raw)

#meta_data = meta_info[colnames(expr_raw),]
#table(meta_data$Histology_Primary)

show_models_bseqsc()

#model_name = "Alpha_Beta_Gamma_Delta_Baron"
#model_name = "Alpha_Beta_Gamma_Delta_Acinar_Ductal_Baron"
#model_name = "Alpha_Beta_Gamma_Delta_Segerstolpe"
#model_name = "Alpha_Beta_Gamma_Delta_Acinar_Ductal_Segerstolpe"
#model_name = "Alpha_Beta_Gamma_Delta_Lawlor"
#model_name = "Alpha_Beta_Gamma_Delta_Segerstolpe"

#model_name = "Tosti_400_endocrine_only"
#model_name = "Tosti_400_endocrine_exocrine_all"
model_name = "Gopalan_S784"

print(dataset_name)

props = Deconvolve_transcriptome(
    transcriptome_data = expr_raw,
    deconvolution_algorithm = "bseqsc",
    models = model_name,
    Cibersort_absolute_mode = TRUE,
    nr_permutations = 1000,
    output_file = ""
)
colnames(props)[colnames(props) == "alpha"] = "Alpha";colnames(props)[colnames(props) == "beta"] = "Beta";colnames(props)[colnames(props) == "gamma"] = "Gamma";colnames(props)[colnames(props) == "delta"] = "Delta";colnames(props)[colnames(props) == "acinar"] = "Acinar";colnames(props)[colnames(props) == "ductal"] = "Ductal"

props = cbind(rownames(props),rep(model_name,nrow(props)),props)
colnames(props)[1:2] = c("Sample","Model")

#if ("Ductal" %in% colnames(props)){
    #props_export = props[,c("Sample","Model","Alpha","Beta","Gamma","Delta","Acinar","Ductal","P_value","Correlation","RMSE")]
#} else{
    props_export = props#[,c("Sample","Model","Alpha","Beta","Gamma","Delta","P_value","Correlation","RMSE")]
#}

if (exists("props_export")){
    #o_filename = "~/Deko_Projekt/Results/Cell_fraction_predictions_visualization/Absolute/Baron_exocrine/"
    #o_filename = "~/Deko_Projekt/Results/Cell_fraction_predictions_visualization/Absolute/Baron_exocrine/NEN/"
    #o_filename = "~/Deko_Projekt/Results/Cell_fraction_predictions_visualization/Absolute/Baron_endocrine/"
    #o_filename = "~/Deko_Projekt/Results/Cell_fraction_predictions_visualization/Absolute/Baron_endocrine/NEN/"
    #o_filename = "~/Deko_Projekt/Results/Cell_fraction_predictions_visualization/Absolute/Tosti_exocrine"
    #o_filename = "~/Deko_Projekt/Results/Cell_fraction_predictions_visualization/Absolute/Tosti_endocrine/"
    #o_filename = "~/Deko_Projekt/Results/Cell_fraction_predictions_visualization/Absolute/Baron_endocrine//"
    o_filename = "~/Deko_Projekt/Results/Cell_fraction_predictions_visualization/Absolute/Gopalan/"
    o_filename = paste(o_filename, dataset_name, sep ="/")
    write.table(props_export,o_filename,sep = "\t",row.names = FALSE)
}

"
Rscript --vanilla Bseqsc_deconvolution.R --index 1 &
Rscript --vanilla Bseqsc_deconvolution.R --index 2&
Rscript --vanilla Bseqsc_deconvolution.R --index 3&
Rscript --vanilla Bseqsc_deconvolution.R --index 4&
Rscript --vanilla Bseqsc_deconvolution.R --index 5&
Rscript --vanilla Bseqsc_deconvolution.R --index 6&
Rscript --vanilla Bseqsc_deconvolution.R --index 7&

"