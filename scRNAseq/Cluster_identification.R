library(Seurat)
library(ggplot2)
library(tidyverse)
library(gridExtra)
library(cluster)
library(clustree)
library(dplyr) 
library(devtools)
library(speckle)
library(limma)
library(clusterProfiler)
library(org.Mm.eg.db)
library(RColorBrewer)
library(scMiko)
library(CellChat)
library(patchwork)
options(stringsAsFactors = FALSE)
library(future)
library(viridis)
library(grid)
library(Polychrome)
library(ggrepel)
library(cowplot)
library(dbscan)

setwd()

dirs <- list.dirs(path = 'CellRanger_matrices/', recursive = F, full.names = F)
for(x in dirs){
  name <- gsub('_filtered_feature_bc_matrix','', x)
  
  cts <- ReadMtx(mtx = paste0('CellRanger_matrices/',x,'/matrix.mtx.gz'),
                 features = paste0('CellRanger_matrices/',x,'/features.tsv.gz'),
                 cells = paste0('CellRanger_matrices/',x,'/barcodes.tsv.gz'))
  assign(name, CreateSeuratObject(counts = cts))
}

# Merge dataset 
merged_seurat <- merge(Naive_NL_F_01, y = c(Naive_NL_F_02, Naive_NL_M_03, Naive_NL_M_04, 
                                            Sham_L_F_05, Sham_L_M_07,Sham_L_M_08,
                                            Sham_NL_F_09,Sham_NL_F_10,Sham_NL_M_11,Sham_NL_M_12,
                                            VNS_L_F_13,VNS_L_F_14,VNS_L_M_16,
                                            VNS_NL_F_17,VNS_NL_F_18,VNS_NL_M_19,VNS_NL_M_20),
                       add.cell.ids = ls()[3:20],
                       project = 'VNS_Sham_LPC')


# Make groups from sample name
merged_seurat$sample <- rownames(merged_seurat@meta.data)
merged_seurat@meta.data <- separate(merged_seurat@meta.data, col = 'sample', into = c('Treatment', 'Tissue', 'Sex','Animal','Barcode'), 
                                    sep = '_')
# Save work 
saveRDS(merged_seurat,"merged_seurat")

# Filtering “Rik” and “Gm-” genes for downstream analyses 
genes_to_exclude <- grep("^Gm", rownames(merged_seurat), value = TRUE)  
genes_to_exclude <- c(genes_to_exclude, grep("Rik$", rownames(merged_seurat), value = TRUE)) 

merged_seurat <- subset(merged_seurat, features = setdiff(rownames(merged_seurat),genes_to_exclude))

# Calculate mitochondrial percentage
merged_seurat[["percent.mt"]] <- PercentageFeatureSet(merged_seurat, pattern='mt-')

# Calculate ribosomal RNA percentage
merged_seurat[["percent.ribo"]] <- PercentageFeatureSet(merged_seurat, pattern='Rp[sl]')

# Visualize QC metrics and apply filters (upper cut off = median + 3*MAD) 
pdf("VlnPlot_raw_QC.pdf")
VlnPlot(merged_seurat, features = c("nFeature_RNA", "nCount_RNA", "percent.mt","percent.ribo"), pt.size = 0.005, ncol = 4)
merged_seurat_filtered <- subset(merged_seurat, subset = nFeature_RNA > 200 
                                 & nFeature_RNA < (median(merged_seurat$nFeature_RNA)+3*mad(merged_seurat$nFeature_RNA)) 
                                 & percent.mt < (median(merged_seurat$percent.mt)+3*mad(merged_seurat$percent.mt))
                                 & percent.ribo < (median(merged_seurat$percent.ribo)+3*mad(merged_seurat$percent.ribo)))
VlnPlot(merged_seurat_filtered, features = c("nFeature_RNA", "nCount_RNA", "percent.mt","percent.ribo"), pt.size = 0.005, ncol = 4)
dev.off()

# Run SCTransform, regressing out mt contamination
merged_seurat_filtered <- SCTransform(merged_seurat_filtered, vars.to.regress = c("percent.mt"), conserve.memory = TRUE)

# Dimension reduction and clustering
merged_seurat_filtered <- RunPCA(object = merged_seurat_filtered)
## Quantitative determination of PCA components to include
pct <- merged_seurat_filtered[["pca"]]@stdev / sum(merged_seurat_filtered[["pca"]]@stdev) * 100
cumu <- cumsum(pct)
co1 <- which(cumu > 90 & pct < 5)[1]
co2 <- sort(which((pct[1:length(pct) - 1] - pct[2:length(pct)]) > 0.1), decreasing = T)[1] + 1
pcs <- min(co1, co2)


merged_seurat_filtered <- FindNeighbors(object = merged_seurat_filtered, dims = 1:pcs)
merged_seurat_filtered <- FindClusters(object = merged_seurat_filtered,resolution = 0.5) # Resolution was iteratively optimized as below
merged_seurat_filtered <- RunUMAP(object = merged_seurat_filtered, dims = 1:pcs,min.dist = 0.1, n.neighbors =50)

# Cluster tree
obj.list <- SplitObject(merged_seurat_filtered, split.by = 'Treatment')
saveRDS(obj.list,"obj.list")
obj.list<-readRDS("obj.list")

dist.matrix_Naive <- dist(x = Embeddings(object = obj.list$Naive[["pca"]])[,1:pcs])
dist.matrix_Sham <- dist(x = Embeddings(object = obj.list$Sham[["pca"]])[,1:pcs])

res = c(0.1, 0.2, 0.3, 0.4,0.6,0.8, 1, 1.2)

for (i in res){
  obj.list$Naive <- FindClusters(obj.list$Naive,resolution = i)
  clusters <- obj.list$Naive$seurat_clusters
  sil <- silhouette(x = as.numeric(x = as.factor(x = clusters)), dist = dist.matrix_Naive)
  obj.list$Naive$sil <- sil[, 3]
  sil_cluster <- with(obj.list$Naive@meta.data, tapply(sil, seurat_clusters,mean))
  filename <- paste(i,"_resolution_Naive.csv", sep='')
  write.csv(sil_cluster,filename)
}

tiff("ClusteringTrees_Naive.tiff", units="in",width=8, height =12, res=1000)
clustree(obj.list$Naive, prefix = "SCT_snn_res.")
dev.off()

for (i in res){
  obj.list$Sham <- FindClusters(obj.list$Sham,resolution = i)
  clusters <- obj.list$Sham$seurat_clusters
  sil <- silhouette(x = as.numeric(x = as.factor(x = clusters)), dist = dist.matrix_Sham)
  obj.list$Sham$sil <- sil[, 3]
  sil_cluster <- with(obj.list$Sham@meta.data, tapply(sil, seurat_clusters,mean))
  filename <- paste(i,"_resolution_Sham.csv", sep='')
  write.csv(sil_cluster,filename)
}


tiff("ClusteringTrees_Sham.tiff", units="in",width=8, height =12, res=1000)
clustree(obj.list$Sham, prefix = "SCT_snn_res.")
dev.off()

merged_seurat_filtered <- PrepSCTFindMarkers(merged_seurat_filtered, assay = "SCT", verbose = TRUE)
saveRDS(merged_seurat_filtered,"merged_seurat_filtered")

cluster_markers <- FindAllMarkers(merged_seurat_filtered, only.pos = TRUE) 
saveRDS(cluster_markers, file = "cluster_markers_updated")
write.csv(cluster_markers,"All_DEG_updated.csv")

defined_DEG <- subset(cluster_markers,subset = avg_log2FC >= 1.5 & p_val < 1E-4)
write.csv(defined_DEG,"Defined_DEG_updated.csv")

merged_seurat_filtered <- RenameIdents(merged_seurat_filtered,
                                       '0' = 'Hom.MG.1',
                                       '1' = 'MyelinDAM-L',
                                       '2' = 'MOL5/6.1',
                                       '3' = 'iHom.MG',
                                       '4' = 'Hom.MG.2',
                                       '5' = 'iMac',
                                       '6' = 'MOL2/3',
                                       '7' = 'Endo.1',
                                       '8' = 'MOL2/3_DA1',
                                       '9' = 'Hom.OPC',
                                       '10'= 'Astro.1',
                                       '11'= 'MOL5/6.2',
                                       '12'= 'iOPC',
                                       '13'= 'COP',
                                       '14'= 'iCAM',
                                       '15'= 'MOL5/6_DA1',
                                       '16'= 'p/mMG',
                                       '17'= 'Endo.2',
                                       '18'= 'Astro.2',
                                       '19'= 'Astro.3',
                                       '20'= 'Astro.4',
                                       '21'= 'Myelinprocessing.MG',
                                       '22'= 'DC',
                                       '23'= 'Pericytes',
                                       '24'= 'pOPC',
                                       '25'= 'Granulocytes',
                                       '26'= 'Hom.CAM',
                                       '27'= 'Neurons')

merged_seurat_filtered$cell_types <- Idents(merged_seurat_filtered)
saveRDS(merged_seurat_filtered,"merged_seurat_filtered_ClusterIdnt")