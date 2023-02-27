//Auto_Projection.ijm
//
//This script was developed on Mac IOS, if you see error in Windows, please contact me - I will wish you good luck ;P
//This script will auto-perform z projection(max), split channels, merge channels of interest, add scale bar, and export to tif and jpeg for all images with LIF file.
//This script is NOT for processing images in folders
//You can adjust the coding slightly to fit your goal better
//
//Author: Iris Bao, Jingna Xue, jingna.xue@ucalgary.ca
//Jan 2023
//License: BSD3
//
//Copyright 2023 Iris Bao, Jingna Xue, University of Calgary
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//
//
//Open lif file
run("Bio-Formats Macro Extensions");
filePath = File.openDialog("Select a .lif file to work with");
Ext.setId(filePath);
Ext.getSeriesCount(seriesCount);
	//print("Total series: ", seriesCount);
seriesNamesList = newArray();
for (i=1; i<=seriesCount; i++) {
        Ext.setSeries(i-1);
        Ext.getSeriesName(seriesName);
        seriesNamesList = Array.concat(seriesNamesList, seriesName);
}
	//Array.print(seriesNamesList);

lif_fileName = File.getName(filePath);
folderName = File.getNameWithoutExtension(filePath);
localDir = getDirectory("Select a directory to create a folder");
savedLocation = localDir + File.separator + folderName;

//Chose the location to create a folder for saving images
File.makeDirectory(savedLocation);
	//print("New folder: ", savedLocation);

//Z-projection, split channels, merge channels, add scale bar for all images within the lif file
for (j=0; j<seriesNamesList.length; j++) {
	run("Bio-Formats", "open=filePath color_mode=Composite series_"+ (j+1));
	selectWindow(lif_fileName + " - " + seriesNamesList[j]);
	run("Z Project...", "projection=[Max Intensity]");
//Adjust scale bar size according to your needs (this is for each single channel image)
	run("Scale Bar...", "width=300 height=12 font=42 color=White background=None location=[Lower Right] bold hide overlay");
	run("Split Channels");
//Adjust the channel number to be merged according to your needs
	run("Merge Channels...", "c2=[C2-MAX_" + lif_fileName + " - " + seriesNamesList[j] + "] c3=[C3-MAX_" + lif_fileName + " - " + seriesNamesList[j] + "] c4=[C4-MAX_" + lif_fileName + " - " + seriesNamesList[j] + "] create keep");
//Adjust scale bar size according to your needs (this is for the merged image)
	run("Scale Bar...", "width=300 height=12 font=42 color=White background=None location=[Lower Right] bold hide overlay");
	
	subFolderName = File.getParent(seriesNamesList[j]);
	fileSavedLocation = savedLocation + File.separator + subFolderName;
	File.makeDirectory(fileSavedLocation);
	fileName = File.getName(seriesNamesList[j]);
	//print("New sub-folder: " + fileSavedLocation);
	//print("File name: " + fileName);
	
//Saving tiff and jpeg for merged images, and saving tiff for all single-channel images
//Adjust the coding if you have other wishes
//The script now is for 4 channels images, if you have less channels, please deleting the codes accordingly, such as line70-71
	saveAs("Tiff", fileSavedLocation + File.separator + fileName + ".tif");
	saveAs("Jpeg", fileSavedLocation + File.separator + fileName + ".jpg");
	selectWindow("C4-MAX_" + lif_fileName + " - " + seriesNamesList[j]);
	saveAs("Tiff", fileSavedLocation + File.separator + "C4-MAX_" + fileName + ".tif");
	selectWindow("C3-MAX_" + lif_fileName + " - " + seriesNamesList[j]);
	saveAs("Tiff", fileSavedLocation + File.separator + "C3-MAX_" + fileName + ".tif");
	selectWindow("C2-MAX_" + lif_fileName + " - " + seriesNamesList[j]);
	saveAs("Tiff", fileSavedLocation + File.separator + "C2-MAX_" + fileName + ".tif");
	selectWindow("C1-MAX_" + lif_fileName + " - " + seriesNamesList[j]);
	saveAs("Tiff", fileSavedLocation + File.separator + "C1-MAX_" + fileName + ".tif");
	
//The number of close file will need to adjusting if you change any number of merge/splited images
//Ohterwise errors may occur
//It usually can be fixed by deleting or adding the number of close()
	close();
	close();
	close();
	close();
	close();
	close();
}
