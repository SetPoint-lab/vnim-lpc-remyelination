# To be used in conjunction with https://imagej.net/plugins/blind-analysis-tools
library(readr)

#Set working directory
setwd()
#Create a list of files 
files_list <- list.files( pattern = "*.nd2", full.names = F)

name_map <- read.csv("Mappings***.csv", header=TRUE) 
Blind_name <- name_map$AssignedName
UNblind_name <- name_map$OriginalName
file.rename(Blind_name, UNblind_name)
