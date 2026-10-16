// Area fraction measurement of dMBP at lesion core and lesion rim

// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "MBP input directory", style = "directory") input_1
#@ File (label = "Microglia input directory", style = "directory") input_2
#@ File (label = "Output directory", style = "directory") dir_out
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
			processFile(input_1, input_2, dir_out, dir_ROI, suffix, list[i]);
	
}


// Runs analysis on each file in input folder with correct extension
function processFile(input_1, input_2, dir_out, dir_ROI, suffix, file) {
	// Do the processing here by adding your own code.
	// print("Processing: " + file);
	path = input_1 + File.separator + file;
	print(file);
	// Run the Area function
	Area(path,input_2, dir_out, dir_ROI);
	
}

function Area(path, input_2, dir_out, dir_ROI) {
close("*");
roiManager("reset");
open(path); // open the file
MBP_name = File.getName(path);
MBP_name_nosuff = File.getNameWithoutExtension(path);
ROIset_name = replace(MBP_name_nosuff, "MAX_", "");
ROIset_name = replace(ROIset_name, "dMBP", "_ROIset.zip");

roiManager("Open", dir_ROI + File.separator+ ROIset_name);
count= roiManager("count");

run("Set Measurements...", "area area_fraction limit redirect=None decimal=3");
selectWindow(MBP_name);
run("Remove Overlay");
run("Subtract Background...", "rolling=25"); 
resetThreshold;
setAutoThreshold("Triangle dark no-reset"); 
run("Convert to Mask");

resultcounter = getValue("results.count");
run("Set Measurements...", "area area_fraction limit redirect=None decimal=3");
selectWindow(MBP_name);
roiManager("select", 0);
ROIname = Roi.getName();
run("Measure");
setResult("ImageName",resultcounter, MBP_name_nosuff);
setResult("ROI",resultcounter,ROIname);

run("Close All");
print("done");


}
