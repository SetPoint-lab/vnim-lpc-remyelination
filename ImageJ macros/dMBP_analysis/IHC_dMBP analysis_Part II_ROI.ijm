// Create lesion ROI for intensity analysis  

// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "dMBP input directory", style = "directory") input_1
#@ File (label = "DAPI input directory", style = "directory") input_2
#@ File (label = "Microglia input directory", style = "directory") input_3
#@ File (label = "ROI output directory", style = "directory") dir_ROI

#@ String (label = "File suffix", value=".tif") suffix


processFolder(input_1);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input_1) {
	list = getFileList(input_1);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input_1 + File.separator + list[i]))
			processFolder(input_1 + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input_1, input_2, input_3, dir_ROI, suffix, list[i]);
	}


// Runs analysis on each file in input folder with correct extension
function processFile(input_1, input_2, input_3, dir_ROI, suffix, file) {
	// Do the processing here by adding your own code.
	// print("Processing: " + file);
	path = input_1 + File.separator + file;
	print(file);
	// Run the ROIset function
	ROIset(path,input_2, input_3, dir_ROI);
	
}

function ROIset(path,input_2, input_3, dir_ROI) {
close("*");
open(path); // open the file
image_name = File.getName(path);
image_name_nosuff = File.getNameWithoutExtension(path);
ROIset_name = replace(image_name_nosuff, "AVG_", "");
ROIset_name = replace(ROIset_name, "dMBP", "_ROIset.zip");
DAPI_name = replace(image_name, "dMBP", "DAPI");
open(input_2 + File.separator + DAPI_name);
Mg_name = replace(image_name, "dMBP", "Mg");
open(input_3 + File.separator + Mg_name);

selectWindow(image_name);
roiManager("reset");

setOption("Show All", true);
setTool("polygon");
waitForUser("Outline lesion area and add to ROI manager (press 't')");
roiManager("Save", dir_ROI + File.separator+ ROIset_name);



run("Remove Overlay");
run("Close All");
print("done");

}
