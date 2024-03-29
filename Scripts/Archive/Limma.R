library("stringr")
library("limma")

# bP60, bP18, bP15, bP9, bP3, bP0, bE17.5
#bP = grep(colnames(expr_raw), pattern = "bP0")
cohort = as.character(subtypes)
cohort[cohort %in% c("Botton_1","Botton_2","Botton_3")] = "CASE"
cohort[cohort != "CASE"] = "CTRL"

design <- model.matrix(~0 + as.factor(cohort))
colnames(design) = c("CASE","CTRL")

vfit <- lmFit(new_merge,design)

contr.matrix = makeContrasts( contrast = CASE - CTRL ,  levels = design )
vfit <- contrasts.fit( vfit, contrasts = contr.matrix)
efit <- eBayes(vfit)

summary(decideTests(efit))

result_t = topTable( efit, coef = "contrast", number  = nrow(new_merge), adjust  ="none", p.value = 1, lfc = 0)
result_t$hgnc_symbol = rownames(result_t)
colnames(result_t) = c("Log_FC","Average_Expr","t","P_value","adj_P_value","B","HGNC")

result_t = result_t[c("HGNC","Log_FC","Average_Expr","P_value","adj_P_value")]
result_t = result_t[order(result_t$P_value, decreasing = F),]
result_t$Log_FC = round(result_t$Log_FC, 1)
result_t$Average_Expr = round(result_t$Average_Expr, 1)
result_t = result_t[order(result_t$Log_FC,decreasing = T),]

#write.table("~/Deko/Results/2_minus_all.tsv", x = result_t, sep = "\t", quote = F, row.names = F)

###

centroid_mat = read.table("~/Koop_Klinghammer/Misc/centroids of 821 predictive gene signatures.tsv",sep ="\t", header = T, stringsAsFactors = F)
centroid_mat$IMS = as.double(str_replace_all(centroid_mat$IMS, pattern = ",", "."))
centroid_mat$BA = as.double(str_replace_all(centroid_mat$BA, pattern = ",", "."))
centroid_mat$CL = as.double(str_replace_all(centroid_mat$CL, pattern = ",", "."))

r_match = match( str_to_upper(centroid_mat$GENE), str_to_upper(result_t$HGNC),  nomatch = 0)
rev_match = match( str_to_upper(result_t$HGNC),str_to_upper(centroid_mat$GENE),  nomatch = 0)

add_mat = matrix( rep("", 3 * nrow(result_t)), ncol = 3 )
add_mat[r_match , 1] = centroid_mat[ r_match != 0, 2]
add_mat[r_match , 2] = centroid_mat[ r_match != 0, 3]
add_mat[r_match , 3] = centroid_mat[ r_match != 0, 4]

result_t = cbind(result_t,add_mat )

#write.table("~/Deko/Results/Botton_vs_Segerstolpe_Merged.tsv", x = result_t, sep = "\t", quote = F, row.names = F)
