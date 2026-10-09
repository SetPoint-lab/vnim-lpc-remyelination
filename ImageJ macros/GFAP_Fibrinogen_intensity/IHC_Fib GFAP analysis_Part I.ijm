// Open raw images to generate 2D average intensity projections


// Dialog box made using Script Parameters: https://imagej.net/Script_Parameters


#@ File (label = "Raw images directory", style = "directory") input
#@ File (label = "Astrocyte Output directory", style = "directory") dir_as
#@ File (label = "Fib Output directory", style = "directory") dir_Fib
#@ File (label = "DAPI Output directory", style = "directory") dir_DAPI

#@ String (label = "File suffix", value = ".czi") suffix

#@ Boolean (label = "Run Rolling-ball subtraction?", value=true, persist=false) option_subtraction

#@ Boolean (label = "Run Despeckle?", value=true, persist=false) option_despeckle


processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, dir_as, dir_Fib,dir_DAPI, suffix, list[i]);
}


// Runs analysis on each file in input folder with correct extension
function processFile(input, dir_as, dir_Fib,dir_DAPI,suffix, file) {
	// Do the processing here by adding your own code.
	// print("Processing: " + file);
	path = input + File.separator + file;
	print(file);
	// Run the coloc function
	coloc(path,dir_as, dir_Fib,dir_DAPI);
	
}

function coloc(path,dir_as, dir_Fib,dir_DAPI) {
close("*");
open(path); // open the file
stack_name = File.getName(path);
stack_name_nosuff = File.getNameWithoutExtension(path);
selectWindow(stack_name);
run("Z Project...", "projection=[Average Intensity]");
selectWindow(stack_name);
run("Z Project...", "projection=[Max Intensity]");

// Save average intensity images for intensity comparison 
selectWindow("AVG_" + stack_name);
getDimensions(width, height, channels, slices, frames);
if (channels > 1){
run("Split Channels");
Fib_channel = "C4-AVG_"+stack_name;
DAPI_channel = "C3-AVG_" + stack_name;
As_channel = "C2-AVG_"+stack_name;
}

selectWindow(Fib_channel);
saveAs("tiff", dir_Fib + File.separator + "AVG_"+stack_name_nosuff+"_Fib");
selectWindow(DAPI_channel);
saveAs("tiff", dir_DAPI + File.separator + "AVG_"+stack_name_nosuff+"_DAPI");
selectWindow(As_channel);
saveAs("tiff", dir_as + File.separator + "AVG_"+stack_name_nosuff+"_As");

// Save Max intensity images for Fibrinogen analysis later
selectWindow("MAX_" + stack_name);
if (option_subtraction == true){
	run("Subtract Background...", "rolling=50 stack");
	print("Ran Background Substraction");
}
getDimensions(width, height, channels, slices, frames);
if (channels > 1){
run("Split Channels");
Fib_channel = "C4-MAX_"+stack_name;
DAPI_channel = "C3-MAX_" + stack_name;
As_channel = "C2-MAX_"+stack_name;
}
selectWindow(Fib_channel);
saveAs("tiff", dir_Fib + File.separator + "MAX_"+stack_name_nosuff+"_Fib");
selectWindow(DAPI_channel);
saveAs("tiff", dir_DAPI + File.separator + "MAX_"+stack_name_nosuff+"_DAPI");
selectWindow(As_channel);
saveAs("tiff", dir_as + File.separator + "MAX_"+stack_name_nosuff+"_As");

run("Close All");
print("done");

}