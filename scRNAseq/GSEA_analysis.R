library(presto)
library(msigdbr)
library(fgsea)
library(dplyr)
library(ggplot2)
library(MAST)
library(stats)

setwd()

msigdbr_species()
msigdbr_collections(db_species = "MM")
m_df_Hallmark<- msigdbr(db_species = "MM", species = "Mus musculus", collection = "MH")
m_df_GOBP<- msigdbr(db_species = "MM", species = "Mus musculus", collection = "M5", subcollection = "BP")
m_df_Immune<- msigdbr(db_species = "MM", species = "Mus musculus", collection = "M7")
m_df_Celltype<- msigdbr(db_species = "MM", species = "Mus musculus", collection = "M8")
m_df_Pathways<- msigdbr(db_species = "MM", species = "Mus musculus", collection = "M2", subcollection = "CP:WIKIPATHWAYS")


fgsea_sets_Hallmark<- m_df_Hallmark %>% split(x = .$gene_symbol, f = .$gs_name)
fgsea_sets_GOBP<- m_df_GOBP %>% split(x = .$gene_symbol, f = .$gs_name)
fgsea_sets_Immune<- m_df_Immune %>% split(x = .$gene_symbol, f = .$gs_name)
fgsea_sets_Celltype<- m_df_Celltype %>% split(x = .$gene_symbol, f = .$gs_name)
fgsea_sets_Pathways<- m_df_Pathways %>% split(x = .$gene_symbol, f = .$gs_name)

# Comparisons b/w tissue type 
merged_seurat_filtered@meta.data$Group <- gsub("NaiveNL","Naive",merged_seurat_filtered@meta.data$Group)
merged_seurat_filtered@meta.data$Group <- gsub("ShamNL","NL",merged_seurat_filtered@meta.data$Group)
merged_seurat_filtered@meta.data$Group <- gsub("VNSNL","NL",merged_seurat_filtered@meta.data$Group)
merged_seurat_filtered@meta.data$Group <- gsub("ShamL","L",merged_seurat_filtered@meta.data$Group)
merged_seurat_filtered@meta.data$Group <- gsub("VNSL","L",merged_seurat_filtered@meta.data$Group)

Naive <- subset(merged_seurat_filtered, subset = merged_seurat_filtered$Group == "Naive")
NL <- subset(merged_seurat_filtered, subset = merged_seurat_filtered$Group == "NL")
L <- subset(merged_seurat_filtered, subset = merged_seurat_filtered$Group == "L")

## Astrocytes 
Astro <- subset(merged_seurat_filtered, idents = c("Astro.1","Astro.2","Astro.3","Astro.4"))

Astro_LvsNaive <- FindMarkers(Astro, ident.1 = "L", ident.2 = "Naive", group.by = 'Group', logfc.threshold = 0.1, min.pct = 0, only.pos = F,assay = "SCT",recorrect_umi=FALSE,test.use = "MAST")
saveRDS(Astro_LvsNaive, file = "Astro_LvsNaive_markers")
Astro_LvsNaive <- Astro_LvsNaive[Astro_LvsNaive$p_val_adj < 0.05,]
Astro_LvsNaive <- arrange(Astro_LvsNaive,desc(avg_log2FC))
rankings <- Astro_LvsNaive$avg_log2FC
names(rankings) <- rownames(Astro_LvsNaive)
rankings <- sort(rankings, decreasing = TRUE) # sort genes by ranking

fgseaRes <- fgsea(fgsea_sets_Hallmark, stats = rankings)
fgseaResTidy <- fgseaRes %>%
  as_tibble() %>%
  arrange(desc(NES))

fgseaResTidy_plot <- fgseaResTidy %>% filter(padj < 0.05) %>% head(n= 20)
fgseaResTidy_plot$pathway <- sub("HALLMARK_","",fgseaResTidy_plot$pathway)
fgseaResTidy_plot$logp <- -log10(fgseaResTidy_plot$padj)
fgseaResTidy_plot <- fgseaResTidy_plot %>%
  arrange(desc(NES)) %>%  
  mutate(pval_label = ifelse(row_number() == 1, sprintf("padj = %.3g", padj), sprintf("%.3g", padj)))

### Do the same analysis for L vs NL and NL vs Naive, save marker lists.  

## Immune cells
Immune <- subset(merged_seurat_filtered, idents = c("Hom.MG.1","MyelinDAM-like.MG","iHom.MG","Hom.MG.2","iCAM.1","iCAM.2","p/mMG","Myelinprocessing.MG","DC","Granulocytes","Hom.CAM"))

Immune_LvsNaive <- FindMarkers(Immune, ident.1 = "L", ident.2 = "Naive", group.by = 'Group', logfc.threshold = 0.1, min.pct = 0, only.pos = F,assay = "SCT",recorrect_umi=FALSE,test.use = "MAST")
saveRDS(Immune_LvsNaive, file = "Immune_LvsNaive_markers")
Immune_LvsNaive <- Immune_LvsNaive[Immune_LvsNaive$p_val_adj < 0.05,]
Immune_LvsNaive <- arrange(Immune_LvsNaive,desc(avg_log2FC))
rankings <- Immune_LvsNaive$avg_log2FC
names(rankings) <- rownames(Immune_LvsNaive)
rankings <- sort(rankings, decreasing = TRUE) # sort genes by ranking

fgseaRes <- fgsea(fgsea_sets_Hallmark, stats = rankings)
fgseaResTidy <- fgseaRes %>%
  as_tibble() %>%
  arrange(desc(NES))

fgseaResTidy_plot <- fgseaResTidy %>% filter(padj < 0.05) %>% head(n= 20)
fgseaResTidy_plot$pathway <- sub("HALLMARK_","",fgseaResTidy_plot$pathway)
fgseaResTidy_plot$logp <- -log10(fgseaResTidy_plot$padj)
fgseaResTidy_plot <- fgseaResTidy_plot %>%
  arrange(desc(NES)) %>%  
  mutate(pval_label = ifelse(row_number() == 1, sprintf("padj = %.3g", padj), sprintf("%.3g", padj)))

### Do the same analysis for L vs NL and NL vs Naive, save marker lists.  

## OPCs + COPs
OPC <- subset(merged_seurat_filtered, idents = c("Hom.OPC","iOPC","COP","pOPC"))
OPC_LvsNaive <- FindMarkers(OPC, ident.1 = "L", ident.2 = "Naive", group.by = 'Group', logfc.threshold = 0.1, min.pct = 0, only.pos = F,assay = "SCT",recorrect_umi=FALSE,test.use = "MAST")
saveRDS(OPC_LvsNaive, file = "OPC_LvsNaive_markers")
OPC_LvsNaive <- OPC_LvsNaive[OPC_LvsNaive$p_val_adj < 0.05,]
OPC_LvsNaive <- arrange(OPC_LvsNaive,desc(avg_log2FC))
rankings <- OPC_LvsNaive$avg_log2FC
names(rankings) <- rownames(OPC_LvsNaive)
rankings <- sort(rankings, decreasing = TRUE) # sort genes by ranking

fgseaRes <- fgsea(fgsea_sets_Hallmark, stats = rankings)
fgseaResTidy <- fgseaRes %>%
  as_tibble() %>%
  arrange(desc(NES))

fgseaResTidy_plot <- fgseaResTidy %>% filter(padj < 0.05) %>% head(n= 20)
fgseaResTidy_plot$pathway <- sub("HALLMARK_","",fgseaResTidy_plot$pathway)
fgseaResTidy_plot$logp <- -log10(fgseaResTidy_plot$padj)
fgseaResTidy_plot <- fgseaResTidy_plot %>%
  arrange(desc(NES)) %>%  
  mutate(pval_label = ifelse(row_number() == 1, sprintf("padj = %.3g", padj), sprintf("%.3g", padj)))

### Do the same analysis for L vs NL and NL vs Naive, save marker lists.  

## Mature Oligodendrocytes 
Olig <- subset(merged_seurat_filtered, idents = c("MOL2/3","MOL5/6","MOL2/3_DA1","MOL5/6_DA1"))
Olig_LvsNaive <- FindMarkers(Olig, ident.1 = "L", ident.2 = "Naive", group.by = 'Group', logfc.threshold = 0.1, min.pct = 0, only.pos = F,assay = "SCT",recorrect_umi=FALSE,test.use = "MAST")
saveRDS(Olig_LvsNaive, file = "Olig_LvsNaive_markers")
Olig_LvsNaive <- Olig_LvsNaive[Olig_LvsNaive$p_val_adj < 0.05,]
Olig_LvsNaive <- arrange(Olig_LvsNaive,desc(avg_log2FC))
rankings <- Olig_LvsNaive$avg_log2FC
names(rankings) <- rownames(Olig_LvsNaive)
rankings <- sort(rankings, decreasing = TRUE) # sort genes by ranking

fgseaRes <- fgsea(fgsea_sets_Hallmark, stats = rankings)
fgseaResTidy <- fgseaRes %>%
  as_tibble() %>%
  arrange(desc(NES))

fgseaResTidy_plot <- fgseaResTidy %>% filter(padj < 0.05) %>% head(n= 20)
fgseaResTidy_plot$pathway <- sub("HALLMARK_","",fgseaResTidy_plot$pathway)
fgseaResTidy_plot$logp <- -log10(fgseaResTidy_plot$padj)
fgseaResTidy_plot <- fgseaResTidy_plot %>%
  arrange(desc(NES)) %>%  
  mutate(pval_label = ifelse(row_number() == 1, sprintf("padj = %.3g", padj), sprintf("%.3g", padj)))

### Do the same analysis for L vs NL and NL vs Naive, save marker lists.  

## Vascular cells
Vascular <- subset(merged_seurat_filtered, idents = c("Endo.1","Endo.2","Pericytes"))
Vascular_LvsNaive <- FindMarkers(Vascular, ident.1 = "L", ident.2 = "Naive", group.by = 'Group', logfc.threshold = 0.1, min.pct = 0, only.pos = F,assay = "SCT",recorrect_umi=FALSE,test.use = "MAST")
saveRDS(Vascular_LvsNaive, file = "Vascular_LvsNaive_markers")
Vascular_LvsNaive <- Vascular_LvsNaive[Vascular_LvsNaive$p_val_adj < 0.05,]
Vascular_LvsNaive <- arrange(Vascular_LvsNaive,desc(avg_log2FC))
rankings <- Vascular_LvsNaive$avg_log2FC
names(rankings) <- rownames(Vascular_LvsNaive)
rankings <- sort(rankings, decreasing = TRUE) # sort genes by ranking

fgseaRes <- fgsea(fgsea_sets_Hallmark, stats = rankings)
fgseaResTidy <- fgseaRes %>%
  as_tibble() %>%
  arrange(desc(NES))

fgseaResTidy_plot <- fgseaResTidy %>% filter(padj < 0.05) %>% head(n= 20)
fgseaResTidy_plot$pathway <- sub("HALLMARK_","",fgseaResTidy_plot$pathway)
fgseaResTidy_plot$logp <- -log10(fgseaResTidy_plot$padj)
fgseaResTidy_plot <- fgseaResTidy_plot %>%
  arrange(desc(NES)) %>%  
  mutate(pval_label = ifelse(row_number() == 1, sprintf("padj = %.3g", padj), sprintf("%.3g", padj)))

### Do the same analysis for L vs NL and NL vs Naive, save marker lists.  

# Comparisons b/w VNIM and Sham-treated astrocytes and microglia in lesion tissue 
Astro_VNSL_ShamL <- FindMarkers(Astro, ident.1 = "VNSL", ident.2 = "ShamL", group.by = 'Group', logfc.threshold = 0.1, min.pct = 0, only.pos = F,assay = "SCT",recorrect_umi=FALSE,test.use = "MAST")
saveRDS(Astro_VNSL_ShamL, file = "Astro_VNSL_ShamL_markers")

Mg_VNSL_ShamL <- FindMarkers(MG, ident.1 = "VNSL", ident.2 = "ShamL", group.by = 'Group', logfc.threshold = 0.1, min.pct = 0, only.pos = F,assay = "SCT",recorrect_umi=FALSE,test.use = "MAST")
saveRDS(Mg_VNSL_ShamL, file = "MG_VNSL_ShamL_markers")

# Comparisons b/w homeostatic and disease-associated states of mature oligodendrocyte clusters
MOL23_DA1vsNaive <- FindMarkers(Olig, ident.1 = "MOL2/3_DA1", ident.2 = "MOL2/3", logfc.threshold = 0.1, min.pct = 0, only.pos = F,assay = "SCT",recorrect_umi=FALSE,test.use = "MAST")
saveRDS(MOL23_DA1vsNaive, file = "MOL23_DA1vsNaive_markers")
MOL23_DA1vsNaive <- readRDS("MOL23_DA1vsNaive_markers")

MOL56_DA1vsNaive <- FindMarkers(Olig, ident.1 = "MOL5/6_DA1", ident.2 = "MOL5/6", logfc.threshold = 0.1, min.pct = 0, only.pos = F,assay = "SCT",recorrect_umi=FALSE,test.use = "MAST")
saveRDS(MOL56_DA1vsNaive, file = "MOL56_DA1vsNaive_markers")
MOL56_DA1vsNaive <- readRDS("MOL56_DA1vsNaive_markers")

MOL23_DA1vsNaive <- MOL23_DA1vsNaive[MOL23_DA1vsNaive$p_val_adj < 0.05,]
MOL23_DA1vsNaive <- arrange(MOL23_DA1vsNaive,desc(avg_log2FC))
rankings <- MOL23_DA1vsNaive$avg_log2FC
names(rankings) <- rownames(MOL23_DA1vsNaive)
rankings <- sort(rankings, decreasing = TRUE) # sort genes by ranking

fgseaRes <- fgsea(fgsea_sets_Hallmark, stats = rankings)
fgseaResTidy <- fgseaRes %>%
  as_tibble() %>%
  arrange(desc(NES))

fgseaResTidy_plot <- fgseaResTidy %>% filter(padj < 0.05) %>% head(n= 20)
fgseaResTidy_plot$pathway <- sub("HALLMARK_","",fgseaResTidy_plot$pathway)
fgseaResTidy_plot$logp <- -log10(fgseaResTidy_plot$padj)
fgseaResTidy_plot <- fgseaResTidy_plot %>%
  arrange(desc(NES)) %>%  
  mutate(pval_label = ifelse(row_number() == 1, sprintf("padj = %.3g", padj), sprintf("%.3g", padj)))

MOL56_DA1vsNaive <- MOL56_DA1vsNaive[MOL56_DA1vsNaive$p_val_adj < 0.05,]
MOL56_DA1vsNaive <- arrange(MOL56_DA1vsNaive,desc(avg_log2FC))
rankings <- MOL56_DA1vsNaive$avg_log2FC
names(rankings) <- rownames(MOL56_DA1vsNaive)
rankings <- sort(rankings, decreasing = TRUE) # sort genes by ranking

fgseaRes <- fgsea(fgsea_sets_Hallmark, stats = rankings)
fgseaResTidy <- fgseaRes %>%
  as_tibble() %>%
  arrange(desc(NES))

fgseaResTidy_plot <- fgseaResTidy %>% filter(padj < 0.05) %>% head(n= 20)
fgseaResTidy_plot$pathway <- sub("HALLMARK_","",fgseaResTidy_plot$pathway)
fgseaResTidy_plot$logp <- -log10(fgseaResTidy_plot$padj)
fgseaResTidy_plot <- fgseaResTidy_plot %>%
  arrange(desc(NES)) %>%  
  mutate(pval_label = ifelse(row_number() == 1, sprintf("padj = %.3g", padj), sprintf("%.3g", padj)))