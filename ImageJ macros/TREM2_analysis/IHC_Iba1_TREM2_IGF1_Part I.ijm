// Open raw images to generate 2D average intensity projections


// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Iba1 Output directory", style = "directory") dir_Iba1
#@ File (label = "TREM2 Output directory", style = "directory") dir_TREM2

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
			processFile(input , dir_TREM2, dir_Iba1, suffix, list[i]);
}


// Runs analysis on each file in input folder with correct extension
function processFile(input , dir_TREM2, dir_Iba1,suffix, file) {
	// Do the processing here by adding your own code.
	// print("Processing: " + file);
	path = input + File.separator + file;
	print(file);
	// Run the average function
	average(path, dir_TREM2, dir_Iba1);
	
}

function average(path , dir_TREM2, dir_Iba1) {

close("*");
open(path); // open the file
stack_name = File.getName(path);
stack_name_nosuff = File.getNameWithoutExtension(path);
selectWindow(stack_name);

// Split channels
getDimensions(width, height, channels, slices, frames);
if (channels > 1){
run("Split Channels");
Iba1_channel = "C1-"+stack_name;
TREM2_channel = "C4-"+stack_name;
}


// Produce z-max images and save them
selectWindow(TREM2_channel);
run("Z Project...", "projection=[Average Intensity]");
saveAs("tiff", dir_TREM2 + File.separator + "AVG_"+stack_name_nosuff+"_TREM2"); // save MAX (or SUM if do intensity) projection as .tif 

selectWindow(Iba1_channel);
run("Z Project...", "projection=[Max Intensity]");
saveAs("tiff", dir_Iba1 + File.separator + "MAX_"+stack_name_nosuff+"_Iba1"); // save MAX projection as .tif
selectWindow(Iba1_channel);
run("Z Project...", "projection=[Average Intensity]");
saveAs("tiff", dir_Iba1 + File.separator + "AVG_"+stack_name_nosuff+"_Iba1"); // save MAX projection as .tif

run("Close All");
print("done");

}
