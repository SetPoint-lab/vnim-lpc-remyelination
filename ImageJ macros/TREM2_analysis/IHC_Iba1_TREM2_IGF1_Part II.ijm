// 


// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "TREM2 directory", style = "directory") input
#@ File (label = "Iba1 input directory", style = "directory") dir_Iba1
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
			processFile(input, dir_Iba1,suffix, list[i]);
}


// Runs analysis on each file in input folder with correct extension
function processFile(input, dir_Iba1, suffix, file) {
	// Do the processing here by adding your own code.
	// print("Processing: " + file);
	path = input + File.separator + file;
	print(file);
	// Run the intensity_analysis function
	intensity_analysis(path, dir_Iba1);
	
}

function intensity_analysis(path,dir_Iba1) {
close("*");
roiManager("reset");
open(path); // open the file
stack_name = File.getName(path);
stack_name_nosuff = File.getNameWithoutExtension(path);
Iba1_avg = replace(stack_name, "TREM2", "Iba1");
Iba1_max = replace(Iba1_avg, "AVG", "MAX");

//Threhold to make Iba1 ROI, then invert the selection and calculate mean intensity for background.
open(dir_Iba1+ File.separator + Iba1_max);
selectWindow(Iba1_max);
run("Subtract Background...", "rolling=500");
run("Threshold...");
setAutoThreshold("Huang dark");
setOption("BlackBackground", true);
run("Convert to Mask");
for (a=0; a<2; a++) {run("Dilate");}
run("Analyze Particles...", "size=0-infinity show=Nothing add");
roiManager("Deselect");
roiManager("Combine");
roiManager("Add");
count = roiManager("count");
roiManager("select", count-1);
run("Make Inverse");
roiManager("Add");

// Measure TREM2 intensity
run("Set Measurements...", "area mean redirect=None decimal=3");
selectWindow(stack_name);
count = roiManager("Count");
roiManager("Select", count-1);
run("Measure");
roiManager("Deselect");
selectWindow(stack_name);
run("Select None");
run("Subtract...", "value="+getResult("Mean", 0));
run("Clear Results");
selectWindow(stack_name);
roiManager("select", count-2);
run("Enlarge...", "enlarge=-1");
roiManager("Add");
count = roiManager("count");
roiManager("select", count-1);
run("Measure");
selectWindow("Results"); 
saveAs("Results", input + File.separator + stack_name +".csv");
run("Clear Results");

// Measure Iba1 intensity
open(dir_Iba1+ File.separator + Iba1_avg);
selectWindow(Iba1_avg);
roiManager("Select", count-2);
run("Measure");
roiManager("Deselect");
selectWindow(Iba1_avg);
run("Select None");
run("Subtract...", "value="+getResult("Mean", 0));
run("Clear Results");
selectWindow(Iba1_avg);
roiManager("select", count-1);
run("Measure");
selectWindow("Results"); 
saveAs("Results", dir_Iba1 + File.separator + Iba1_avg +".csv");
run("Clear Results");


run("Close All");
print("done");

}
