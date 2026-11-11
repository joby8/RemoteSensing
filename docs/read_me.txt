Getting started with the “Regional noise reduction in NIMBUS 5 ESMR microwave radiometer sea ice concentration data”
Here you will do regional noise reduction of the NIMBUS 5 ESMR s before computing the sea ice concentration. The correction method is described in the Kolbe_etal_essd-16-1247-2024 .pdf available on learn (Section 4.1). 
The data are available on:
https://drive.google.com/file/d/1HaEKintGNE1Ec5erYyWG8CNAseAZsSYV/view?usp=sharing

The first step is to read the data. The data is in NetCDF format and there is a list of variables in the dataset described in Kolbe_etal_essd-16-1247-2024 Appendix A1. Python has several libraries for reading NetCDF both netCDF4 and scipy.io. In the list of variables (Appendix A1) there are variables from the satellite (Time, Brightness_temperature, …) and variables from ERA5, which is an atmospheric reanalysis (u10, v10, t2m..). You will need variables from both the satellite and the reanalysis in your project.

You will have to build your own software. However, some things are provided for example the radiative transfer model called esmr_rtm either as a python or matlab script. 

One variable that you will need which is not is the dataset is the incidence angle. In the folder there is a text file called spos2ia which will help you converting the scan position across swath to an incidence angle. Negative and positive incidence angles correspond to left and right side of the swath, symmetrical around nadir.

I have also included a zip-folder resampling_example with python script examples for how to resample swath files into a predefined grid. This may or may not be useful for you.

I have included some literature “Microwave remote sensing of sea ice” ‘, “The Nimbus 5 Users guide” and “Kolbe et al. 2024”. Especially, Kolbe et al. is very important to read.

1.  Regional noise reduction in NIMBUS 5 ESMR microwave radiometer sea ice concentration data
Supervisor:	Rasmus Tonboe, B348, R120, e-mail: rtt@space.dtu.dk 

How do we achieve sea ice climate data record stability? When making sea ice climate data records (CDRs) using satellite observations (top of the atmosphere brightness temperatures, s) one of the most important requirements is stability. Here we use the term stability to describe how well we observe sea ice extent variability and trends without external influences not related to sea ice extent such as radiometer instrument drift plus the s and the sea ice extent estimate being influenced by atmospheric and surface noise (with own climatic trends). There are several steps in the processing of historical satellite data to achieve CDR stability and one of them is regional noise reduction of s, the topic of this study. In regional noise reduction we are using atmospheric re-analysis data and a radiative transfer model to "correct" the measured s for the influence of temperature, water vapor and clouds variability in the atmosphere and sea ice temperature and wind induced surface roughness on the ocean surface. The result after the noise reduction are s which are (almost) insensitive to these noise sources while still being sensitive to sea ice. The overall question to be answered here is: How effective is regional noise reduction of NIMBUS 5 ESMR data over open water?

Specific tasks
	•	Compute the mean and standard deviation of the open water sea ice concentration (SIC) for un-corrected and corrected s (the mean should be close to 0) using ERA5 data and a radiative transfer model (available in Matlab or Python).
	•	Evaluate by exclusion which re-analysis (ERA5) parameters are most important for the correction.
	•	Plot the un-corrected and corrected STD of the SIC as a function of incidence angle and discuss if certain angles should be avoided because of the noise level.
	•	Based on the results, give you recommendations for an ESMR  correction strategy.

It is a good idea when doing this project to know basic Matlab and/or python scripting such as basic plotting, reading data and looping through data files. However, models and algorithms will be provided.

