// Open raw images to generate 2D maximum intensity projections

// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "Raw images directory", style = "directory") input
#@ File (label = "Microglia Output directory", style = "directory") dir_mg
#@ File (label = "CD68 Output directory", style = "directory") dir_CD68
#@ File (label = "MBP Output directory", style = "directory") dir_MBP
#@ File (label = "DAPI Output directory", style = "directory") dir_DAPI

#@ String (label = "File suffix", value = ".czi") suffix

#@ Boolean (label = "Run Rolling-ball subtraction?", value=true, persist=false) option_subtraction
#@ Boolean (label = "Run Despeckle?", value=true, persist=false) option_despeckle

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, dir_mg, dir_CD68, dir_MBP,dir_DAPI, suffix, list[i]);
}


// Runs analysis on each file in input folder with correct extension
function processFile(input, dir_mg, dir_CD68, dir_MBP,dir_DAPI,suffix, file) {
	// Do the processing here by adding your own code.
	// print("Processing: " + file);
	path = input + File.separator + file;
	print(file);
	// Run the coloc function
	zmax(path,dir_mg, dir_CD68, dir_MBP,dir_DAPI);
	
}

function zmax(path,dir_mg, dir_CD68, dir_MBP,dir_DAPI) {
close("*");
open(path); // open the file
stack_name = File.getName(path);
stack_name_nosuff = File.getNameWithoutExtension(path);
selectWindow(stack_name);
run("Z Project...", "projection=[Max Intensity]");
selectWindow(stack_name);
run("Z Project...", "projection=[Average Intensity]");

// Run background correction on Max projected images, save all images for colocalization analysis 
selectWindow("MAX_" + stack_name);
if (option_subtraction == true){
	run("Subtract Background...", "rolling=50 stack");
	print("Ran Background Subtraction");
}
if (option_despeckle == true){
	run("Despeckle","stack");
	print("Ran Despeckle");
}
getDimensions(width, height, channels, slices, frames);
if (channels > 1){
run("Split Channels");
CD68_channel = "C1-MAX_"+stack_name;
MBP_channel = "C2-MAX_"+stack_name;
DAPI_channel = "C3-MAX_" + stack_name;
Mg_channel = "C4-MAX_"+stack_name;
}
selectWindow(CD68_channel);
saveAs("tiff", dir_CD68 + File.separator + "MAX_"+stack_name_nosuff+"_CD68");
selectWindow(MBP_channel);
saveAs("tiff", dir_MBP + File.separator + "MAX_"+stack_name_nosuff+"_MBP");
selectWindow(DAPI_channel);
saveAs("tiff", dir_DAPI + File.separator + "MAX_"+stack_name_nosuff+"_DAPI");
selectWindow(Mg_channel);
saveAs("tiff", dir_mg + File.separator + "MAX_"+stack_name_nosuff+"_Mg");

run("Close All");
print("done");

}


 
