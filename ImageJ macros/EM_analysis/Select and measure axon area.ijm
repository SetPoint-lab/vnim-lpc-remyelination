// Load the selected axons, trace the inner and outer perimeter of the axons and save the measurements.

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
 
run("Set Scale...", "distance=1 known=0.00539 unit=micron");

run("Set Measurements...", "area perimeter shape feret's redirect=None decimal=3");

selectWindow(image_name);
run("Remove Overlay");
roiManager("reset");
ROIset_name = image_name_nosuff+"_ROIset.zip";
setOption("Show All", true);
if (File.exists(dir_ROI + File.separator + ROIset_name)==1) {
roiManager("Open", dir_ROI + File.separator+ ROIset_name); 

// Delete all demyelinated axons as they will not be used in g-ratio analysis
for (i = roiManager("Count")-1; i >= 0; i--){ 
	roiManager("Select", i);
	name = Roi.getName;
		if(matches(name, ".*d.*")){
		 roiManager("Delete");
	}
}
roiManager("deselect");

// Transfer ROIs to overlays 
roiManager("Show All with labels");
run("From ROI Manager");
run("Show Overlay");

// Delete point map ROIs so we can make new ROIs with the axon perimeter later
roiManager("Show None");
count = roiManager("count");
array = newArray(count);
for (i=0; i<array.length; i++) {array[i] = i;}
roiManager("select", array);
roiManager("Delete");

// Draw axon inner and outer circumference 
roiManager("Show All without labels");
//setTool("freehand");
setTool("polygon"); // Or using the polygon drawing option if that is easier. 
waitForUser("Outline the inner and outer axon to ROI manager (press 't' each time), click OK once all done");
waitForUser("Rename each ROI as i or o for inner vs outer, click OK once all are renamed");

count = roiManager("count");
for (a = 0; a < count; a++) {
resultcounter = getValue("results.count");
roiManager("select", a);
ROIname = Roi.getName();
run("Measure");
setResult("Image",resultcounter, image_name);
setResult("ROI",resultcounter,ROIname);
updateResults();
}

// Save axonal circumference ROIs
roiManager("deselect");
ROIset_name = image_name_nosuff+"_ROIset_axonC.zip";
roiManager("Save", dir_ROI + File.separator+ ROIset_name); 


run("Select None");
run("Close All");
print("done");
} 
else {print("Image did not pass QC, was not processed");}

}
