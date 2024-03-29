# Dieses Skript dient zur Dekonvolution der Benchmark Datensets (bulk RNA-seq: healthy, panNEN, GEP-NEN)
# auf Basis der Trainings Datensets (scRNA-seq: healthy) mit SCDC und Ensemble 
# Trainings Datensets: Baron, Segerstolpe, Lawlor (SCDC+artdeco Quellen), Haber (GEO?)
# Benchmark Datensets: Califano, Missiaglia, Fadista, RepSet, Riemer, Sadanandam, Scarpa
#!! NOTE !!# 
# This will be endocrine+exocrine model (alpha, beta, gamma, delta, ductal, acinar)

#### load Metadata file ####
library(SCDC)
metadata <- read.table(file = "~/Praktikum/Data/Clinial_data_Meta_information.tsv", sep = "\t", header = T)

#### load Benchmark data sets ####
# Califano
alvarez <- read.table(file = "~/Praktikum/Data/Alverez.S105.tsv", sep = '\t', header = TRUE) 
alvarez_meta_idx <- which(metadata$Study == "Alvarez") 
alvarez_meta <- metadata[alvarez_meta_idx,]
alvarez_meta <- alvarez_meta[which(alvarez_meta$Location=="pancreas"),]
alvarez_meta <- alvarez_meta[which(alvarez_meta$Subtype!= "Outlier"),] #105!

# Fadista
fadista <- read.table(file = "~/Praktikum/Data/Fadista.S89.tsv", sep = '\t', header = TRUE)
rownames(fadista) <- fadista[,1]
fadista <- fadista[,-1]
fadista_meta_idx <- which(metadata$Study == "Fadista")
fadista_meta <- metadata[fadista_meta_idx,]

# Missiaglia
missiaglia <- read.table(file = "~/Praktikum/Data/Missaglia.S75.tsv", sep = '\t', header = TRUE)
missiaglia_meta_idx <- which(metadata$Study == "GSE73338")
missiaglia_meta <- metadata[missiaglia_meta_idx,] 
missiaglia_sample_idx <- which(missiaglia_meta$Name %in% colnames(missiaglia))
missiaglia_meta <- missiaglia_meta[missiaglia_sample_idx,]

# Riemer
riemer <- read.table(file = "~/Praktikum/Data/Riemer.S40.tsv", sep = '\t', header = TRUE)
rownames(riemer) <- riemer[,1]
riemer <- riemer[,-1]
riemer_meta_idx <- which(metadata$Study == "Riemer") 
riemer_meta <- metadata[riemer_meta_idx,]
riemer_meta <- riemer_meta[which(riemer_meta$Subtype=="Cancer"),] #40!

# Sadanandam
sadanandam <- read.table(file = "~/Praktikum/Data/Sadanandam.S29.tsv", sep = '\t', header = TRUE)
sad_meta_idx <- which(metadata$Study == "Sadanandam") 
sad_meta <- metadata[sad_meta_idx,]

# Scarpa
scarpa <- read.table(file = "~/Praktikum/Data/Scarpa.S29.tsv", sep = '\t', header = TRUE)
scarpa_meta_idx <- which(metadata$Study == "Scarpa") 
scarpa_meta <- metadata[scarpa_meta_idx,]

# RepSet
repset <- read.table(file = "~/Praktikum/Data/RepSet.S57.tsv", sep = '\t', header = TRUE)
repset_meta <- rbind(scarpa_meta, riemer_meta)
rownames(repset_meta) <- repset_meta$Name
rownames(repset_meta)[1:55] <- paste("X",rownames(repset_meta)[1:55], sep = "")
repset_meta$Name <- as.character(repset_meta$Name)
repset_meta$Name[1:55] <- paste("X", repset_meta$Name[1:55], sep = "")
repset_meta_idx <- which(repset_meta$Name %in% colnames(repset))
repset_meta <- repset_meta[repset_meta_idx,]



#### Turn Benchmark Data into ExpressionSet objects ####
fdata_alvarez <- rownames(alvarez)
pdata_alvarez <- cbind(cellname = colnames(alvarez), subjects = as.character(alvarez_meta$Subtype))
eset_alvarez <- getESET(alvarez, fdata = fdata_alvarez, pdata = pdata_alvarez)

fdata_fadista <- rownames(fadista)
pdata_fadista <- cbind(cellname = colnames(fadista), subjects = as.character(fadista_meta$Grading))
eset_fadista <- getESET(fadista, fdata = fdata_fadista, pdata = pdata_fadista)

fdata_missiaglia <- rownames(missiaglia)
pdata_missiaglia <- cbind(cellname = colnames(missiaglia), subjects = as.character(missiaglia_meta$Grading))
eset_missiaglia <- getESET(missiaglia, fdata = fdata_missiaglia, pdata = pdata_missiaglia)

fdata_riemer <- rownames(riemer)
pdata_riemer <- cbind(cellname = colnames(riemer), subjects = as.character(riemer_meta$Grading))
eset_riemer <- getESET(riemer, fdata = fdata_riemer, pdata = pdata_riemer)

fdata_sadanandam <- rownames(sadanandam)
pdata_sadanandam <- cbind(cellname = colnames(sadanandam), subjects = as.character(sad_meta$Grading))
eset_sadanandam <- getESET(sadanandam, fdata = fdata_sadanandam, pdata = pdata_sadanandam)

fdata_scarpa <- rownames(scarpa)
pdata_scarpa <- cbind(cellname = colnames(scarpa), subjects = as.character(scarpa_meta$Grading))
eset_scarpa <- getESET(scarpa, fdata = fdata_scarpa, pdata = pdata_scarpa)

fdata_repset <- rownames(repset)
pdata_repset <- cbind(cellname = colnames(repset), subjects = as.character(repset_meta$Grading))
eset_repset <- getESET(repset, fdata = fdata_repset, pdata = pdata_repset)



#### load Training data sets ####
library(data.table)
library(Biobase)
baron <- readRDS(file = "~/SCDC/SCDC/vignettes/data/baron.rds")

segerstolpe <- readRDS(file = "~/SCDC/SCDC/vignettes/data/segerstolpe.rds")

dt = fread("~/artdeco/artdeco/data/Lawlor.csv.gz") # expression values
lawlor_dt <- as.matrix(dt[,-1])
rownames(lawlor_dt) <- dt$V1

lawlor_meta <- metadata[which(metadata$Study=="Lawlor"),] # meta data
lawlor_idx <- which(lawlor_meta$Name %in% colnames(lawlor_dt))
lawlor_meta <- lawlor_meta[lawlor_idx,]
rownames(lawlor_meta) <- lawlor_meta$Name
lawlor_meta$Subtype <- tolower(lawlor_meta$Subtype)
lawlor_meta <- lawlor_meta[colnames(lawlor_dt),]
lawlor_meta_diff <- lawlor_meta
colnames(lawlor_meta_diff)[1] <- "sample" 
colnames(lawlor_meta_diff)[11] <- "cluster"

# single cell: 
lawlor <- getESET(exprs = lawlor_dt, fdata = dt$V1, pdata = lawlor_meta_diff)



#### SCDC QC on scRNA-seq data ####
library(SCDC)
qc_baron <- SCDC_qc(baron, ct.varname = "cluster", sample = "sample", 
                    scsetname = "Baron", ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"), 
                    qcthreshold = 0.7)
qc_segerstolpe <- SCDC_qc(segerstolpe, ct.varname = "cluster", sample = "sample", 
                          scsetname = "Segerstolpe", ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"), 
                          qcthreshold = 0.7)
qc_lawlor <- SCDC_qc_ONE(lawlor, ct.varname = "cluster", sample = "sample", scsetname = "Lawlor",
                         ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))



#### Ensemble deconvolution ####
# 7 times
pancreas.sc <- list(baron = qc_baron$sc.eset.qc,
                    seger = qc_segerstolpe$sc.eset.qc,
                    lawlor = qc_lawlor$sc.eset.qc)

ensemble_alvarez <- SCDC_ENSEMBLE(bulk.eset = eset_alvarez, sc.eset.list = pancreas.sc, ct.varname = "cluster",
                                  sample = "sample", ct.sub =  c("alpha","beta","delta","gamma","acinar", "ductal"), 
                                  search.length = 0.01)
ensemble_alvarez$w_table


ensemble_fadista <- SCDC_ENSEMBLE(bulk.eset = eset_fadista, sc.eset.list = pancreas.sc, ct.varname = "cluster",
                                  sample = "sample", ct.sub =  c("alpha","beta","delta","gamma","acinar", "ductal"), 
                                  search.length = 0.01)
ensemble_fadista$w_table


ensemble_missiaglia <- SCDC_ENSEMBLE(bulk.eset = eset_missiaglia, sc.eset.list = pancreas.sc, ct.varname = "cluster",
                                     sample = "sample", ct.sub =  c("alpha","beta","delta","gamma","acinar", "ductal"), 
                                     search.length = 0.01)
ensemble_missiaglia$w_table


ensemble_riemer <- SCDC_ENSEMBLE(bulk.eset = eset_riemer, sc.eset.list = pancreas.sc, ct.varname = "cluster",
                                 sample = "sample", ct.sub =  c("alpha","beta","delta","gamma", "acinar", "ductal"), 
                                 search.length = 0.01)
ensemble_riemer$w_table


ensemble_sadanandam <- SCDC_ENSEMBLE(bulk.eset = eset_sadanandam, sc.eset.list = pancreas.sc, ct.varname = "cluster",
                                     sample = "sample", ct.sub =  c("alpha","beta","delta","gamma", "acinar", "ductal"), 
                                     search.length = 0.01)
ensemble_sadanandam$w_table


ensemble_scarpa <- SCDC_ENSEMBLE(bulk.eset = eset_scarpa, sc.eset.list = pancreas.sc, ct.varname = "cluster",
                                 sample = "sample", ct.sub =  c("alpha","beta","delta","gamma", "acinar", "ductal"), 
                                 search.length = 0.01)
ensemble_scarpa$w_table


ensemble_repset <- SCDC_ENSEMBLE(bulk.eset = eset_repset, sc.eset.list = pancreas.sc, ct.varname = "cluster",
                                 sample = "sample", ct.sub =  c("alpha","beta","delta","gamma", "acinar", "ductal"), 
                                 search.length = 0.01)
ensemble_repset$w_table



ensemble_exocrine_dec_res <- list(ensemble_alvarez, ensemble_fadista, ensemble_missiaglia, ensemble_repset, ensemble_riemer,
                                   ensemble_sadanandam, ensemble_scarpa)
names(ensemble_exocrine_dec_res) <- c("Alvarez", "Fadista", "Missiaglia", "RepSet", "Riemer", "Sadanandam", "Scarpa")
saveRDS(ensemble_exocrine_dec_res, file = "~/Praktikum/decon_res/ensemble_exocrine_dec_res.RDS")


#### SCDC deconvolution ####
## Baron 7 times ##
baron_alvarez_deco <- SCDC_prop(bulk.eset = eset_alvarez, sc.eset = qc_baron$sc.eset.qc, 
                                ct.varname = "cluster", sample = "sample", 
                                ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

baron_fadista_deco <- SCDC_prop(bulk.eset = eset_fadista, sc.eset = qc_baron$sc.eset.qc, 
                                ct.varname = "cluster", sample = "sample", 
                                ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

baron_missiaglia_deco <- SCDC_prop(bulk.eset = eset_missiaglia, sc.eset = qc_baron$sc.eset.qc, 
                                   ct.varname = "cluster", sample = "sample", 
                                   ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

baron_riemer_deco <- SCDC_prop(bulk.eset = eset_riemer, sc.eset = qc_baron$sc.eset.qc, 
                               ct.varname = "cluster", sample = "sample", 
                               ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

baron_sadanandam_deco <- SCDC_prop(bulk.eset = eset_sadanandam, sc.eset = qc_baron$sc.eset.qc, 
                                   ct.varname = "cluster", sample = "sample", 
                                   ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

baron_scarpa_deco <- SCDC_prop(bulk.eset = eset_scarpa, sc.eset = qc_baron$sc.eset.qc, 
                               ct.varname = "cluster", sample = "sample", 
                               ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

baron_repset_deco <- SCDC_prop(bulk.eset = eset_repset, sc.eset = qc_baron$sc.eset.qc, 
                               ct.varname = "cluster", sample = "sample", 
                               ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

baron_exocrine_dec_res <- list(baron_alvarez_deco, baron_fadista_deco, baron_missiaglia_deco, baron_repset_deco, 
                                baron_riemer_deco, baron_sadanandam_deco, baron_scarpa_deco)
names(baron_exocrine_dec_res) <- c("Alvarez", "Fadista", "Missiaglia", "RepSet", "Riemer", "Sadanandam", "Scarpa")
saveRDS(baron_exocrine_dec_res, file = "~/Praktikum/decon_res/baron_exocrine_dec_res.RDS")



## Segerstolpe 7 times ##
seger_alvarez_deco <- SCDC_prop(bulk.eset = eset_alvarez, sc.eset = qc_segerstolpe$sc.eset.qc, 
                                ct.varname = "cluster", sample = "sample", 
                                ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

seger_fadista_deco <- SCDC_prop(bulk.eset = eset_fadista, sc.eset = qc_segerstolpe$sc.eset.qc, 
                                ct.varname = "cluster", sample = "sample", 
                                ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

seger_missiaglia_deco <- SCDC_prop(bulk.eset = eset_missiaglia, sc.eset = qc_segerstolpe$sc.eset.qc, 
                                   ct.varname = "cluster", sample = "sample", 
                                   ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

seger_riemer_deco <- SCDC_prop(bulk.eset = eset_riemer, sc.eset = qc_segerstolpe$sc.eset.qc, 
                               ct.varname = "cluster", sample = "sample", 
                               ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

seger_sadanandam_deco <- SCDC_prop(bulk.eset = eset_sadanandam, sc.eset = qc_segerstolpe$sc.eset.qc, 
                                   ct.varname = "cluster", sample = "sample", 
                                   ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

seger_scarpa_deco <- SCDC_prop(bulk.eset = eset_scarpa, sc.eset = qc_segerstolpe$sc.eset.qc, 
                               ct.varname = "cluster", sample = "sample", 
                               ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

seger_repset_deco <- SCDC_prop(bulk.eset = eset_repset, sc.eset = qc_segerstolpe$sc.eset.qc, 
                               ct.varname = "cluster", sample = "sample", 
                               ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

segerstolpe_exocrine_dec_res <- list(seger_alvarez_deco, seger_fadista_deco, seger_missiaglia_deco, seger_repset_deco, 
                                      seger_riemer_deco, seger_sadanandam_deco, seger_scarpa_deco)
names(segerstolpe_exocrine_dec_res) <- c("Alvarez", "Fadista", "Missiaglia", "RepSet", "Riemer", "Sadanandam", "Scarpa")
saveRDS(segerstolpe_exocrine_dec_res, file = "~/Praktikum/decon_res/segerstolpe_exocrine_dec_res.RDS")


## Lawlor 7 times ##
lawlor_alvarez_deco <- SCDC_prop_ONE(bulk.eset = eset_alvarez, sc.eset = qc_lawlor$sc.eset.qc, 
                                     ct.varname = "cluster", sample = "sample", 
                                     ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

lawlor_fadista_deco <- SCDC_prop_ONE(bulk.eset = eset_fadista, sc.eset = qc_lawlor$sc.eset.qc, 
                                     ct.varname = "cluster", sample = "sample", 
                                     ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

lawlor_missiaglia_deco <- SCDC_prop_ONE(bulk.eset = eset_missiaglia, sc.eset = qc_lawlor$sc.eset.qc, 
                                        ct.varname = "cluster", sample = "sample", 
                                        ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

lawlor_riemer_deco <- SCDC_prop_ONE(bulk.eset = eset_riemer, sc.eset = qc_lawlor$sc.eset.qc, 
                                    ct.varname = "cluster", sample = "sample", 
                                    ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

lawlor_sadanandam_deco <- SCDC_prop_ONE(bulk.eset = eset_sadanandam, sc.eset = qc_lawlor$sc.eset.qc, 
                                        ct.varname = "cluster", sample = "sample", 
                                        ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

lawlor_scarpa_deco <- SCDC_prop_ONE(bulk.eset = eset_scarpa, sc.eset = qc_lawlor$sc.eset.qc, 
                                    ct.varname = "cluster", sample = "sample", 
                                    ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))

lawlor_repset_deco <- SCDC_prop_ONE(bulk.eset = eset_repset, sc.eset = qc_lawlor$sc.eset.qc, 
                                    ct.varname = "cluster", sample = "sample", 
                                    ct.sub = c("alpha","beta","delta","gamma", "acinar", "ductal"))


lawlor_exocrine_dec_res <- list(lawlor_alvarez_deco, lawlor_fadista_deco, lawlor_missiaglia_deco, lawlor_repset_deco, 
                                 lawlor_riemer_deco, lawlor_sadanandam_deco, lawlor_scarpa_deco)
names(lawlor_exocrine_dec_res) <- c("Alvarez", "Fadista", "Missiaglia", "RepSet", "Riemer", "Sadanandam", "Scarpa")
saveRDS(lawlor_exocrine_dec_res, file = "~/Praktikum/decon_res/lawlor_exocrine_dec_res.RDS")
