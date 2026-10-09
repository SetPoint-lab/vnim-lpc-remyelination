// Load and select ROI 

// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "Image input directory", style = "directory") input
#@ File (label = "ROI output directory", style = "directory") dir_ROI

#@ String (label = "File suffix", value=".tif") suffix


processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input,dir_ROI, suffix, list[i]);
	
}


// Runs analysis on each file in input folder with correct extension
function processFile(input, dir_ROI, suffix, file) {
	// Do the processing here by adding your own code.
	// print("Processing: " + file);
	path = input + File.separator + file;
	print(file);
	// Run the ROIset function
	ROIset(path,dir_ROI);
	
}

function ROIset(path,dir_ROI) {
close("*");
open(path); // open the file
image_name = File.getName(path);
image_name_nosuff = File.getNameWithoutExtension(path);
 
run("Set Scale...", "distance=1 known=0.757578182 unit=micron"); // Keyence 10x scale

run("Set Measurements...", "area redirect=None decimal=3");

selectWindow(image_name);
run("Remove Overlay");
roiManager("reset");
ROIset_name = image_name_nosuff+"_ROIset.zip";
setOption("Show All", true);
setTool("freehand");
waitForUser("Outline the lesion and add to ROI manager (press 't')");
roiManager("Save", dir_ROI + File.separator+ ROIset_name); 
roiManager("reset");
}
