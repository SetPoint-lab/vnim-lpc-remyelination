// Intensity measurement of astrocytes and Fibrinogen in lesion core and lesion rim


// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "Astrocyte input directory", style = "directory") input_1
#@ File (label = "Fibrinogen input directory", style = "directory") input_2
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
	// Run the Intensity function
	Intensity(path, input_2, dir_out, dir_ROI);
	
}

function Intensity(path, input_2, dir_out, dir_ROI) {
close("*");
roiManager("reset");
open(path); // open the file
As_name = File.getName(path);
As_name_nosuff = File.getNameWithoutExtension(path);
ROIset_name = replace(As_name_nosuff, "AVG_", "");
ROIset_name = replace(ROIset_name, "As", "_ROIset.zip");

Fib_name = replace(As_name, "As", "Fib");
open(input_2 + File.separator + Fib_name);

// Make lesion rim by first shrinking the lesion 15% of its radius to make the lesion core. The lesion rim is total lesion - lesion core
roiManager("Open", dir_ROI + File.separator+ ROIset_name);
count= roiManager("count");
if (count >= 1){
roiManager("Select", 0);
run("Set Measurements...", "perimeter redirect=None decimal=3");
run("Measure");
Lesion_perimeter = getResult("Perim.", 0);
Lesion_rim_size = (Lesion_perimeter/6.3)/6.7; //15% of average lesion radius 
run("Enlarge...", "enlarge=-"+Lesion_rim_size);
roiManager("add");
count= roiManager("count");
roiManager("select", count-1);
roiManager("Rename", "LesionRim");
roiManager("Sort");
run("Clear Results");}
else {print("No lesion to make lesion rim");}

//Measure As intensity
run("Set Measurements...", "area mean min integrated redirect=None decimal=3");
selectWindow(As_name);
run("Remove Overlay");
for (a = 0; a < count; a++) {
resultcounter = getValue("results.count");
roiManager("select", a);
ROIname = Roi.getName();
run("Measure");
setResult("ImageName",resultcounter,As_name);
setResult("ROI",resultcounter,ROIname);
updateResults();
}

selectWindow("Results"); 
result_name = replace(As_name_nosuff, "_As", "");
saveAs("Results", dir_out + File.separator + result_name+".csv");
run("Clear Results");

run("Close All");
print("done");


}
