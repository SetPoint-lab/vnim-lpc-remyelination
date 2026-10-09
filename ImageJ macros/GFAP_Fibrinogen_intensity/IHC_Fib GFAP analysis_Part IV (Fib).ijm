// Fibrinogen intensity measurement 


// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "Fib_AVG Input directory", style = "directory") Fib_AVG
#@ File (label = "Fib_MAX Input directory", style = "directory") dir_Fib_MAX
#@ File (label = "Lesion ROI directory", style = "directory") dir_ROI

#@ String (label = "File suffix", value = ".tif") suffix



processFolder(Fib_AVG);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(Fib_AVG) {
	list = getFileList(Fib_AVG);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(Fib_AVG + File.separator + list[i]))
			processFolder(Fib_AVG + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(Fib_AVG,  dir_Fib_MAX,dir_ROI, suffix, list[i]);
}

// Runs analysis on each file in Fib_AVG folder with correct extension
function processFile(Fib_AVG, dir_Fib_MAX,dir_ROI, suffix, file) {
	path = Fib_AVG + File.separator + file;
	print(file);
	// Run the intensity function
	intensity(path, dir_Fib_MAX,dir_ROI);
	
}

// Run the intensity function  
function intensity(path, dir_Fib_MAX,dir_ROI) {
close("*");
open(path); // open the file
Fib_AVG_channel = File.getName(path);
Fib_AVG_channel_nosuff = File.getNameWithoutExtension(path);

ROIset_name = replace(Fib_AVG_channel_nosuff, "AVG_", "");
ROIset_name = replace(ROIset_name, "Fib", "_ROIset.zip");

Fib_MAX_channel = replace(Fib_AVG_channel, "AVG", "MAX");
open(dir_Fib_MAX + File.separator + Fib_MAX_channel);

// Set threshold for blood vessels and convert to mask 
selectWindow(Fib_MAX_channel);
run("Remove Overlay");
run("Despeckle");
run("Subtract Background...", "rolling=50");
run("Threshold...");
setAutoThreshold("Otsu dark");
setOption("BlackBackground", true);
run("Convert to Mask", "method=Otsu background=Dark calculate black");
run("Make Binary", "method=Otsu background=Default black");

roiManager("Reset");
// Confine the area of analysis to the lesion area
roiManager("Open", dir_ROI + File.separator+ ROIset_name);
roiManager("Sort");
roiManager("select", 0);
setBackgroundColor(0, 0, 0);
run("Clear Outside");
roiManager("Reset");
selectWindow(Fib_MAX_channel);
run("Analyze Particles...", "size=0-infinity circularity=0-0.3 show=Nothing add stack");
roiManager("Deselect");

run("Set Measurements...", "area mean integrated area_fraction redirect=None decimal=3");
// Measure the area of the entire vasculature within the lesion
selectWindow(Fib_AVG_channel);
run("Remove Overlay");
roiManager("Combine");
roiManager("Add");
count= roiManager("count");
roiManager("select", count-1);
roiManager("Rename", "Blood vessels");
setColor(0,0,0);
roiManager("Fill");

resultcounter = getValue("results.count");
roiManager("select", count-1);
ROIname = Roi.getName();
run("Measure");
setResult("ImageName",resultcounter,Fib_AVG_channel_nosuff);
setResult("ROI",resultcounter,ROIname);
updateResults();

// Measure the intensity of Fibrinogen leakage surrounding the blood vasculature 
roiManager("Reset");
roiManager("Open", dir_ROI + File.separator+ ROIset_name);
roiManager("Sort");
selectWindow(Fib_AVG_channel);
resultcounter = getValue("results.count");
roiManager("select", 0);
ROIname = Roi.getName();
run("Measure");
setResult("ImageName",resultcounter,Fib_AVG_channel_nosuff);
setResult("ROI",resultcounter,ROIname);
updateResults();


run("Close All");
print("done");

}
