# FEBio-Model2Figure
Standard Operating Procedure: FEBio Model2Figure Processing Suite

Version: v1.0 20210428 - Sameer Sajid

Background
FEBio is an open-source, finite element solver typically used for biomechanical applications. However, the FEBio software suite lacks developed analysis packages; the included results viewer PostView is only for qualitative examination. The following MATLAB software script package is used to analyze the results of FEBio simulations. The main features of this software are: 
-	Generating a set of .feb file with varied parameters as part of an experiment
-	Automatically running all .feb simulations  with a few clicks (Microsoft Windows only)
-	Interpolate 3D displacements into synthetic, 2D slices that simulate image acquisition
-	Calculation of in-plane strains from interpolated FE data
-	Modular statistical analysis and spatial heuristic testing
-	Generating figures directly from processed data
-	Correlation of varied parameters and desired analysis methods

Recommended System Requirements
-	MATLAB R2018a or later
-	FEBio 2.9.1 or later
-	Windows 10
-	16+ core CPU @ 4GHz+
-	64GB RAM

Minimum System Requirements
-	MATLAB R2014a or later (older versions can work with minor tweaks)
-	FEBio 2.5 or later
-	Quad-core CPU, 3GHz
-	16GB RAM

Simulation Requirements 
-	1 or 2 .feb files representative of base simulation cases (example: 1 file for defect models, 1 for intact models)
-	All models use tet4 OR hex8 meshes for main geometry. Any elements outside of theses configurations will be ignored
o	The script will also only use one element type at a time. Currently mixing elements is not supported, and may not work correctly. 
	Adding support for this will take some time! See Appendix for more information
o	To add more supported element types, see Appendix
-	Decide on a naming scheme for your files, for example
o	defect_model_E0.26_10
o	‘defect_model’ is the simulation name
o	‘E0.26’ could be the Young’s Modulus
o	‘10’ is a stickiness parameter
o	Your files can be named whatever you want, but it is highly recommended you follow a general format of simulation_name_var1_var2_var3, depending on your desired number of variables

Using the Software Package:

Broadly, usage comprises the following four scripts, run in this order. 
-	FEA_GenerateSims
-	FEA_Strains
-	FEA_Correlation
-	FEA_MakeImages

For first time use, please follow these instructions:

1.	Unzip Files, Prepare Directories, & Prepare MATLAB
a.	Create a new software directory for all the code
b.	Extract FEA_Suite.zip and SpatialAnalysis.zip into the soft directory
c.	Create a new folder inside this software directory called ‘FEA_cached’
i.	You can make a different name, but this name is strongly recommended 
d.	Create a new directory anywhere for your simulations, note the folder name
e.	Copy-paste your base simulation case into this new directory
i.	Your base simulation is the file with the lowest values for all your intended variables, and is named accordingly (see Simulation Requirements)
f.	When running these scripts, do NOT clear the workspace between each one. The scripts are dependent on global variables
i.	The author is aware that this is terrible coding practice, but this was the fastest way to make the scripts run while also being able to inspect the output
2.	FEA_GenerateSims (must be run at least once per set of simulations!)
a.	Open MATLAB and start a parallel pool of your desired size
i.	https://www.mathworks.com/help/parallel-computing/run-code-on-parallel-pools.html;jsessionid=fa7dd73916b6f4c5b7b8175e7085
b.	Open FEA_GenerateSims.m
c.	Using a text editor, add the <logfile> code in FEA_GenerateSims to the <OUTPUT> section of your base .feb file
d.	Modify the model variable to your desired simulation name
i.	Previous models run have used “defect_model” or “simple_model”, as an example
e.	Following the example in the code, create an elseif case which matches your desired parameters. Alter the following variables:
i.	n¬_pts_1
ii.	n¬_pts_2
iii.	fac (optional)
iv.	base_val (optional)
v.	range_var1
vi.	range_var2
1.	note: variables 1 and 2 are varied together in this code. To vary two separate variables, use var1 and var3!
vii.	range_var3
viii.	var1_ind
ix.	var2_ind
x.	var3_ind
xi.	root
f.	Find the comments that say FILE NAMING: and modify the code below it to your desired naming scheme
i.	Be sure to modify the folder and file names
g.	Find comments that say VARIABLE LINES:  and modify the code below it based on your desired variables
i.	This code will copy your base file, but replacing the appropriate lines with the formatting/variable shown
h.	Run the script
i.	Run all your simulations using the ‘run_all.bat’ file in your simulation folder
3.	FEA_Strains (must be run every time!)
a.	Open FEA_Strains.m
b.	Modify the model variable to the appropriate simulation set (whatever you’ve named it)
c.	Make an elseif case which matches your desired parameters, following previous elseif cases as examples. Modify the following variables:
i.	param_file
ii.	smoothing
iii.	im_size
iv.	slices
v.	soi
vi.	n_soi
vii.	plane
viii.	scale (optional)
ix.	noise (optional)
x.	noise_type (optional)
xi.	use_cache
xii.	msk_order
xiii.	msk_combine
xiv.	msk_cycles
xv.	override_1 (optional)
xvi.	override_2 (optional)
1.	it is highly recommended to use override_1 & override_2 to run the script on a single simulation to ensure the interpolation is running the way you want
2.	Depending on your chosen plane and scaling factor, you may need to tweak FEA_Import! See Appendix for more information.
d.	Run the script
i.	This part of the software package can take a long time. Depending on the model complexity, image parameters, and number of simulations you want to process, it can take anywhere from 5 minutes to 12 hours!
ii.	It is highly recommended to use override_1 and override_2 first to ensure the interpolation is running the way you want
4.	FEA_Correlation (must be run every time!)
a.	Open FEA_Correlation.m
b.	Make an elseif case which matches your desired parameters, following previous cases as examples. Modify the following variables
i.	test_msk
ii.	test_msk2 (optional)
iii.	n_test
iv.	test_name
v.	win
vi.	i_file (optional)
vii.	i_f1 (optional)
viii.	i_f3 (optional)
ix.	SA_cache
c.	Depending on which tests you want, you may need to be implement new analysis methods
i.	Not specifying a test method will simply return untreated data (good if you just want the std or mean of the ROI)
ii.	See SA_Helper in the Appendix
d.	Run the script!
i.	Depending on your analysis methods, this process can take anywhere from a few seconds to a few hours.
5.	FEA_MakeImages (optional, only for viewing results and making figures)
a.	Open FEA_MakeImages.m
b.	Leave the figure parameters as is
i.	Turn on at least 1-2 few figures in the to_show¬ variable so the figures can be checked through trial-and-error
c.	Make an elseif case which matches the model you’re trying to process. Modify the following variables either before running, or afterwards. Some variables are best set through trial-and-error based on what works for you
i.	rep_var1 
ii.	def_var1 
iii.	rep_var3
iv.	def_var3
v.	rep_soi
vi.	viz_soi
vii.	n_soi2
viii.	poi_1 (trial and error)
ix.	poi_2 (trial and error)
x.	line_factor (trial and error)
xi.	main_roi 
xii.	outline_strain (trial and error)
xiii.	lab_x_offset (trial and error)
xiv.	lab_y_offset (trial and error)
xv.	sub_figs
d.	Run script!
e.	Modify parameters in step 5c until figures look as intended. Re-run as needed
f.	Modify figure parameters until figures look as intended
i.	fontsize1
ii.	fontsize2
iii.	fontsize3
iv.	render1
v.	render2
vi.	fig_names
vii.	to_show
viii.	to_save
ix.	n_disp
x.	n_strain
xi.	s_name
g.	Once figures look as intended, enable saving through to_save and re-run script

 
Appendix

Supporting multiple element types within a single model

Starting with FileOptimizer, the processing suite creates a variable called ele_size which is used to create holders for element and nodal data. Currently, it is set to a single value for an entire simulation- changing this will require at least the following:

1.	FEA_FileOptimizer
a.	ele_size must be altered to be an array that stores the element size for every single element, not just once at the end
2.	FEA_ReadData2
a.	ele_size must not be included as a value within a struct, and must now be passed as a full array on its own (for speed)
b.	ele_size should be cached and saved per file as well as the rest of the element data
c.	Compute element displacements section must be altered to vary the inner loop size for every element
3.	FEA_Import4
a.	ele_size must now be passed as a variable, rather than part of struct opt
4.	FEA_InterpolateSlices4
a.	ele_size must now be passed as a variable, rather than part of struct opt
b.	Main parallel loop must be modified in many places to account for variable element size
5.	FEA_Strains
a.	ele_size should now be saved in the cache as an additional variable for every simulation

Additional unforeseen changes may be required; the above are a minimum and a general guide to the changes necessary. WARNING: Altering this code improperly can break element interpolation! Only implement these changes if you are very comfortable with MATLAB.

 
Supporting additional elements types for interpolation

The FEA processing suite relies on certain geometric transformations to interpolate 3D element geometry into 2D images. The current supported types are tet4 and hex8 meshes. To add support for new elements, do the following in the following files:

1.	FEA_FileOptimizer
a.	Line 113, add the desired elements using another strcmp (string compare) case
b.	You may need to also modify Line 135 to properly interpret the element type into the element size, the # of nodes per element
2.	FEA_ElementFaceNorm2
a.	Add an elseif case for the new element type in the Combination of Points section, creating these variables. Follow tet4 as an example
i.	comb
1.	the nodes making up each face
ii.	unused
1.	the nodes NOT used in each face
iii.	npf
1.	nodes per face
iv.	n_face
1.	number of faces

Modifying ElementFaceNorm2 may be tricky, but doesn’t require any special programming or MATLAB knowledge, just knowing how your mesh generator numbers its nodes. Incorrectly implementing your new elements will not break anything, only the interpolation of the new elements.
 
Zooming in with scaling factor in FEA_Import

When using a scaling factor greater than 1 (i.e. zooming in), you will want to specify where in your interpolated image you would like to zoom. This may also vary depending on the desired imaging plane. At the moment, this was hardcoded for the original author’s usage case. Perform the following:

1.	FEA_Import4
a.	Zoom center, Lines 54 and 55, alter variables:
i.	cntr_x
ii.	cntr_y
b.	Left/right flip, line 95, comment or uncomment to flip across vertical axis

Inspect your results manually using the override variables in FEA_Strain to ensure the data are interpolated the way you intended.
 
Adding new spatial analysis techniques with SA_Helper

Spatial analysis is performed through the SA_Helper function for improved test modularity. To add more tests, perform the following
	
1.	Create new MATLAB script(s) that performs your desired spatial analysis or image processing. Available inputs are from SA_Helper are:
a.	The image data, a 2D array
b.	A binary mask, a 2D array
c.	Window size, an integer
d.	The test name, a string
2.	SA_Helper
a.	Add an elseif case matching your desired test name which calls your new script(s) as needed
b.	Set lmap to equal the main output of the last step of your desired image processing
