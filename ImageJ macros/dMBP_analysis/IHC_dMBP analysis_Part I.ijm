// Open raw images to generate 2D average intensity projections

// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "Raw images directory", style = "directory") input
#@ File (label = "Microglia Output directory", style = "directory") dir_mg
#@ File (label = "dMBP Output directory", style = "directory") dir_MBP
#@ File (label = "DAPI Output directory", style = "directory") dir_DAPI

#@ String (label = "File suffix", value = ".czi") suffix

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, dir_mg, dir_MBP,dir_DAPI, suffix, list[i]);
}


// Runs analysis on each file in input folder with correct extension
function processFile(input, dir_mg, dir_MBP,dir_DAPI,suffix, file) {
	// Do the processing here by adding your own code.
	// print("Processing: " + file);
	path = input + File.separator + file;
	print(file);
	// Run the avg function
	avg(path,dir_mg, dir_MBP,dir_DAPI);
	
}

function avg(path,dir_mg, dir_MBP,dir_DAPI) {
close("*");
open(path); // open the file
stack_name = File.getName(path);
stack_name_nosuff = File.getNameWithoutExtension(path);
selectWindow(stack_name);
run("Z Project...", "projection=[Average Intensity]");

// Save average intensity images for intensity comparison
selectWindow("AVG_" + stack_name);
getDimensions(width, height, channels, slices, frames);
if (channels > 1){
run("Split Channels");
MBP_channel = "C2-AVG_"+stack_name;
DAPI_channel = "C3-AVG_" + stack_name;
Mg_channel = "C1-AVG_"+stack_name;
}

selectWindow(MBP_channel);
saveAs("tiff", dir_MBP + File.separator + "AVG_"+stack_name_nosuff+"_dMBP");
selectWindow(DAPI_channel);
saveAs("tiff", dir_DAPI + File.separator + "AVG_"+stack_name_nosuff+"_DAPI");
selectWindow(Mg_channel);
saveAs("tiff", dir_mg + File.separator + "AVG_"+stack_name_nosuff+"_Mg");

run("Close All");
print("done");

}


 
