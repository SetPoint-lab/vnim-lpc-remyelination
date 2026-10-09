// Measurement of how much MBP inclusion in microglial CD68 at lesion core and lesion rim, as area fraction of Iba1+CD68+

// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "MBP input directory", style = "directory") input_1
#@ File (label = "Microglia input directory", style = "directory") input_2
#@ File (label = "CD68 input directory", style = "directory") input_3
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
			processFile(input_1, input_2, input_3, dir_out, dir_ROI, suffix, list[i]);
	
}


// Runs analysis on each file in input folder with correct extension
function processFile(input_1, input_2, input_3, dir_out, dir_ROI, suffix, file) {
	// Do the processing here by adding your own code.
	// print("Processing: " + file);
	path = input_1 + File.separator + file;
	print(file);
	// Run the Coloc function
	Coloc(path,input_2, input_3, dir_out, dir_ROI);
	
}

function Coloc(path, input_2, input_3, dir_out, dir_ROI) {
close("*");
run("Clear Results");
roiManager("reset");
open(path); // open the file
MBP_name = File.getName(path);
MBP_name_nosuff = File.getNameWithoutExtension(path);
ROIset_name = replace(MBP_name_nosuff, "MAX_", "");
ROIset_name = replace(ROIset_name, "MBP", "_ROIset.zip");
Mg_name = replace(MBP_name, "MBP", "Mg");
CD68_name = replace(MBP_name, "MBP", "CD68");
open(input_2 + File.separator + Mg_name);
open(input_3 + File.separator + CD68_name);

// Make lesion rim by first shrinking the lesion 15% of its radius to make the lesion core. The lesion rim is total lesion - lesion core, which will be calculated in Excel with ImageJ output below. 
roiManager("Open", dir_ROI + File.separator+ ROIset_name);
count= roiManager("count");
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
run("Clear Results");

//Threshold all channels
run("Set Measurements...", "area area_fraction redirect=None decimal=3");
selectWindow(CD68_name);
run("Remove Overlay");
roiManager("Show All");
roiManager("Show None");
resetThreshold;
setAutoThreshold("Otsu dark");
setOption("BlackBackground", true);
run("Convert to Mask");

wait(300);

selectWindow(Mg_name);
run("Remove Overlay");
roiManager("Show All");
roiManager("Show None");
resetThreshold;
setAutoThreshold("Otsu dark");
setOption("BlackBackground", true);
run("Convert to Mask");

wait(300);

selectWindow(MBP_name);
run("Remove Overlay");
run("Gaussian Blur...", "sigma=0.5");
run("Subtract Background...", "rolling=20");
roiManager("Show All");
roiManager("Show None");
resetThreshold;
setAutoThreshold("Moments dark");
setOption("BlackBackground", true);
run("Convert to Mask");

// Make binarized colocalization image
imageCalculator("Multiply create",Mg_name , CD68_name);
Mg_CD68 = "Result of "+ Mg_name;
imageCalculator("Multiply create", MBP_name, Mg_CD68);


//Measure Iba1 and CD68 overlap within lesion core and at lesion rim. Measure MBP within microglial CD68 at lesion rim and within lesion core
selectWindow(Mg_name);
for (a = 0; a < count; a++) {
resultcounter = getValue("results.count");
roiManager("select", a);
ROIname = Roi.getName();
run("Measure");
setResult("ImageName",resultcounter,Mg_name);
setResult("ROI",resultcounter,ROIname);
updateResults();
}

selectWindow(Mg_CD68);
for (a = 0; a < count; a++) {
resultcounter = getValue("results.count");
roiManager("select", a);
ROIname = Roi.getName();
run("Measure");
setResult("ImageName",resultcounter,Mg_CD68);
setResult("ROI",resultcounter,ROIname);
updateResults();
}

selectWindow("Result of "+MBP_name);
for (a = 0; a < count; a++) {
resultcounter = getValue("results.count");
roiManager("select", a);
ROIname = Roi.getName();
run("Measure");
setResult("ImageName",resultcounter,"Result of "+MBP_name);
setResult("ROI",resultcounter,ROIname);
updateResults();}

selectWindow("Results"); 
result_name = replace(MBP_name_nosuff, "_MBP", "");
saveAs("Results", dir_out + File.separator + result_name+".csv");
run("Clear Results");

run("Close All");
print("done");


}
