library(slingshot)
setwd()

merged_seurat_filtered <- readRDS("merged_seurat_filtered_ClusterIdnt")
merged_seurat_filtered$Group <- paste0(merged_seurat_filtered$Treatment, merged_seurat_filtered$Tissue)

MG <- subset(merged_seurat_filtered, idents = c("Hom.MG.1","Hom.MG.2", "iHom.MG", "MyelinDAM-L","p/mMG","Myelinprocessing.MG"))
MG$cell_types <- Idents(MG)
MG_XMyelin <- subset(MG, idents = c("Hom.MG.1","Hom.MG.2", "iHom.MG", "MyelinDAM-L","p/mMG"))
OLC <- subset(merged_seurat_filtered, idents = c("MOL5/6.1","MOL2/3","MOL2/3_DA1","Hom.OPC","MOL5/6.2","iOPC","COP","MOL5/6_DA1","pOPC"))


# Input in slingshot - MG
dimred <- MG@reductions$umap@cell.embeddings
clustering <- MG$cell_types

lineages <- getLineages(data = dimred, clusterLabels = clustering, start.clus="Hom.MG.1", omega=TRUE)

dimred <- MG_XMyelin@reductions$umap@cell.embeddings
clustering <- MG_XMyelin$cell_types
lineages_postexclusion <- getLineages(data = dimred, clusterLabels = clustering, start.clus="Hom.MG.1")
curves <- getCurves(lineages_postexclusion, stretch = 0.5, allow.breaks = FALSE, shrink = 1)

pal <- c(RColorBrewer::brewer.pal(8, "Set2"),RColorBrewer::brewer.pal(12, "Set3"))

dimred <- MG@reductions$umap@cell.embeddings
clustering <- MG$cell_types

svg("MG_Slingshot_lineages.svg", width=16, height =8)
par(mfrow = c(1, 3))
plot(dimred[, 1:2], col = pal[clustering], cex = 0.5, pch = 16)
for (i in levels(clustering)) {
  text(mean(dimred[clustering == i, 1]), mean(dimred[clustering == i, 2]), labels = i, font = 2)
}
plot(dimred[, 1:2], col = pal[clustering], cex = 0.5, pch = 16)
lines(SlingshotDataSet(lineages), lwd = 3, col = "black",show.constraints = TRUE)
plot(dimred, col = pal[clustering], asp = 1, cex = 0.5,pch = 16)
lines(SlingshotDataSet(curves), lwd = 3, col = "black")
dev.off()

Lineage1 <- as.data.frame(curves@assays@data$pseudotime[,1])
colnames(Lineage1)[1] <- 'Pseudotime'  
Lineage1$celltype <- MG_XMyelin$cell_types
p1 <- ggplot(Lineage1, aes(x = celltype, y = Pseudotime, fill = celltype)) + 
  geom_violin(trim=FALSE,adjust = 2,bw = 0.25) + 
  scale_fill_brewer(palette="Set3", name = "Microglial subtypes") + 
  theme_classic() +
  coord_flip()+
  ggtitle("Lineage 1") +
  xlab("Microglial subtypes")

Lineage2 <- as.data.frame(curves@assays@data$pseudotime[,2])
colnames(Lineage2)[1] <- 'Pseudotime'  
Lineage2$celltype <- MG_XMyelin$cell_types
p2 <- ggplot(Lineage2, aes(x = celltype, y = Pseudotime, fill = celltype)) + 
  geom_violin(trim=FALSE,adjust = 2,bw = 0.25) + 
  scale_fill_brewer(palette="Set3", name = "Microglial subtypes") + 
  theme_classic() +
  coord_flip() +
  ggtitle("Lineage 2") +
  xlab("Microglial subtypes")

svg("MG_Slingshot_cellvstime.svg",width=8, height =10)
grid.arrange(p1,p2, ncol = 1, nrow = 2)
dev.off()

# Input in slingshot - OLC
dimred <- OLC@reductions$umap@cell.embeddings
clustering <- OLC$cell_types
counts <- as.matrix(OLC@assays$SCT@counts[OLC@assays$SCT@var.features,])

lineages <- getLineages(data = dimred, clusterLabels = clustering, start.clus="Hom.OPC")

curves <- getCurves(SlingshotDataSet(lineages), stretch = 0.5, allow.breaks = FALSE, shrink = 1)

pal <- c(RColorBrewer::brewer.pal(8, "Set2"),RColorBrewer::brewer.pal(12, "Set3"))

svg("OLC_Slingshot_lineages.svg", width=16, height =8)
par(mfrow = c(1, 3))
plot(dimred[, 1:2], col = pal[clustering], cex = 0.5, pch = 16)
for (i in levels(clustering)) {
  text(mean(dimred[clustering == i, 1]), mean(dimred[clustering == i, 2]), labels = i, font = 2)
}
plot(dimred[, 1:2], col = pal[clustering], cex = 0.5, pch = 16)
lines(SlingshotDataSet(lineages), lwd = 3, col = "black",show.constraints = TRUE)
plot(dimred, col = pal[clustering], asp = 1, cex = 0.5,pch = 16)
lines(SlingshotDataSet(curves), lwd = 3, col = "black")
dev.off()

Lineage1 <- as.data.frame(curves@assays@data$pseudotime[,1])
colnames(Lineage1)[1] <- 'Pseudotime'  
Lineage1$celltype <- OLC$cell_types
p1 <- ggplot(Lineage1, aes(x = celltype, y = Pseudotime, fill = celltype)) + 
  geom_violin(trim=FALSE,adjust = 2,bw = 0.25) + 
  scale_fill_brewer(palette="Set3", name = "Oligodendrocyte lineage") + 
  theme_classic() +
  coord_flip()+
  ggtitle("Lineage 1") +
  xlab("Oligodendrocyte lineage")

Lineage2 <- as.data.frame(curves@assays@data$pseudotime[,2])
colnames(Lineage2)[1] <- 'Pseudotime'  
Lineage2$celltype <- OLC$cell_types
p2 <- ggplot(Lineage2, aes(x = celltype, y = Pseudotime, fill = celltype)) + 
  geom_violin(trim=FALSE,adjust = 2,bw = 0.25) + 
  scale_fill_brewer(palette="Set3", name = "Oligodendrocyte lineage") + 
  theme_classic() +
  coord_flip() +
  ggtitle("Lineage 2") +
  xlab("Oligodendrocyte lineage")

Lineage3 <- as.data.frame(curves@assays@data$pseudotime[,3])
colnames(Lineage3)[1] <- 'Pseudotime'  
Lineage3$celltype <- OLC$cell_types
p3 <- ggplot(Lineage3, aes(x = celltype, y = Pseudotime, fill = celltype)) + 
  geom_violin(trim=FALSE,adjust = 2,bw = 0.25) + 
  scale_fill_brewer(palette="Set3", name = "Oligodendrocyte lineage") + 
  theme_classic() +
  coord_flip() +
  ggtitle("Lineage 3") +
  xlab("Oligodendrocyte lineage")

svg("OLC_Slingshot_cellvstime.svg", width=8, height =15)
grid.arrange(p1,p2,p3, ncol = 1, nrow = 3)
dev.off()