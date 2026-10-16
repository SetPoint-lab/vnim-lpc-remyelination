# Run after Cluster_identification.R, same set of library

# Function to keep only cells in dense UMAP clusters
keep_cells <- function(object, eps = 1, minPts = 10, reduction = "umap") {
  emb <- Embeddings(object[[reduction]])
  db <- dbscan(emb, eps = eps, minPts = minPts)
  keep_cells <- rownames(emb)[db$cluster != 0]
  return(keep_cells)
}

setwd()

# Gene module score analysis on microglia 
MG <- subset(merged_seurat_filtered, idents = c("Hom.MG.1","Hom.MG.2", "iHom.MG", "MyelinDAM-L","p/mMG","Myelinprocessing.MG"))

## DAM score
DAM <- read.csv("DAM_geneset_28602351.csv", header=FALSE)
DAM <- unique(DAM)
DAM <- as.vector(DAM)

DAM_modulescore <- AddModuleScore(object = MG, features = DAM, nbin = 24, ctrl = 20, name = "DAM")

DAM_score <- with(DAM_modulescore@meta.data, tapply(DAM1, list(cell_types,Group), median))
write.csv(DAM_score,"DAM_score.csv")

p <- FeaturePlot(DAM_modulescore, cells= keep_cells(DAM_modulescore), features = "DAM1", label = TRUE,repel = TRUE, raster=FALSE) +
  scale_color_gradientn( colors = viridis::plasma(256))+
  theme_classic(base_size = 14)+
  theme(
    title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.line = element_line(arrow = arrow(type = "closed", length = unit(0.25, "cm"))),
    axis.title = element_text(hjust = 0.1)
  ) 
ggsave("DAM score.svg", plot=p,units="in",width=6, height =6)

## Demyelination score 
Demyelination <- read.csv("Demyelination_genset_36952346.csv", header=FALSE)
Demyelination <- unique(Demyelination)
Demyelination <- as.vector(Demyelination)

Demyelination_modulescore <- AddModuleScore(object = MG, features = Demyelination, nbin = 24, ctrl = 20, name = "Demyelination")

Demyelination_score <- with(Demyelination_modulescore@meta.data, tapply(Demyelination1, list(cell_types,Group), median))
write.csv(Demyelination_score,"Demyelination_score.csv")

p <- FeaturePlot(Demyelination_modulescore, cells= keep_cells(Demyelination_modulescore), features = "Demyelination1", label = FALSE, repel = TRUE, raster=FALSE) +
  scale_color_gradientn( colors = viridis::plasma(256))+
  theme_classic(base_size = 14)+
  theme(
    title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.line = element_line(arrow = arrow(type = "closed", length = unit(0.25, "cm"))),
    axis.title = element_text(hjust = 0.1)
  ) 
ggsave("Demyelination score.svg", plot=p,units="in",width=6, height =6)

## Remyelination score 
Remyelination <- read.csv("Remyelination_geneset_36952346.csv", header=FALSE)
Remyelination <- unique(Remyelination)
Remyelination <- as.vector(Remyelination)

Remyelination_modulescore <- AddModuleScore(object = MG, features = Remyelination, nbin = 24, ctrl = 20, name = "Remyelination")

Remyelination_score <- with(Remyelination_modulescore@meta.data, tapply(Remyelination1, list(cell_types,Group), median))
write.csv(Remyelination_score,"Remyelination_score.csv")

p <- FeaturePlot(Remyelination_modulescore, cells= keep_cells(Remyelination_modulescore), features = "Remyelination1", label = FALSE, repel = TRUE, raster=FALSE) +
  scale_color_gradientn( colors = viridis::plasma(256))+
  theme_classic(base_size = 14)+
  theme(
    title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    axis.line = element_line(arrow = arrow(type = "closed", length = unit(0.25, "cm"))),
    axis.title = element_text(hjust = 0.1)
  ) 
ggsave("Remyelination score.svg", plot=p,units="in",width=6, height =6)
