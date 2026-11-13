# Explainer video: narration script

Voice: en-US-AndrewMultilingualNeural (edge-tts), rate −5 %.
Format: `## <scene id> | <step label> | <title>` starts a scene. Each line `{cue} text` is one sentence clip;
the cue starts the matching animation in `video/player.html` when the clip starts.
All numbers come from `output/video/video_data.js` (`src/matlab/video_export.m`): orbit 5 Feb 1973 09:59 UTC, Northern Hemisphere.

## intro | Overview | From brightness temperature to corrected sea ice concentration
{title} This video walks through our processing pipeline, one step at a time.
{flow} There are nine steps, from the raw satellite data to the corrected sea ice concentration and the sensitivity study.
{orbit} Every step is shown on real data: one orbit of the ESMR instrument on the fifth of February, nineteen seventy-three.

## data | Step 1 · Data | One ESMR orbit
{globe} This is the orbit. The satellite circles the Earth from pole to pole, and the scanner sweeps across the track.
{swath} Each scan line has seventy-eight positions. This orbit has about sixteen hundred scan lines.
{tb} The colour is the measured brightness temperature at nineteen gigahertz, horizontal polarisation.
{contrast} Open water is radiometrically cold, around one hundred and forty five kelvin. Sea ice is warm, around two hundred and twenty five kelvin.
{era5} For every pixel, the file also contains ERA5 weather data, interpolated to the same time and place.

## inputs | Step 2 · Inputs | Weather at every pixel
{V} From ERA5 we take five inputs for the radiative transfer model. First, the water vapour V.
{W} Second, the wind speed W, computed from the two wind components.
{L} Third, the cloud liquid water L: total column water minus water vapour.
{Ts} Fourth, the sea surface temperature T s.
{Ti} And fifth, the temperature of the ice's emitting layer, T i, estimated from the two metre air temperature with equation fifteen.
{theta} The incidence angle theta comes from the scan position. It grows from zero in the middle to sixty-four degrees at the edges.

## filters | Step 3 · Filters | Which pixels we keep
{all} We start with all pixels of the orbit.
{eq1} Equation one removes brightness temperatures below ninety or above two hundred seventy three kelvin. These are mostly land and bad values.
{edge} Next, we drop the four outermost scan positions on each side. They have the largest angles.
{lat} Then we keep only latitudes poleward of fifty degrees, as agreed with our supervisor.
{land} Finally, pixels without sea surface temperature are land in ERA5. They are removed as well.
{left} What is left is the open ocean and the sea ice we work with.

## clusters | Step 4 · Tie-point clusters | Pure water and pure ice
{water} Among these pixels we select two clusters. The water cluster: ERA5 says no ice, the water is warmer than two hundred seventy eight kelvin, and the brightness temperature is between ninety and one hundred eighty.
{ice} The ice cluster: ERA5 ice concentration above eighty percent, and brightness temperature between one hundred and two hundred seventy four kelvin.
{count} Over the whole day, in the north, that gives about fifteen thousand water pixels and eighty three thousand ice pixels.

## rawsic | Step 5 · Raw SIC | Tie points and equation sixteen
{hist} Here are the brightness temperatures of both clusters.
{tp} The mean of each cluster is its tie point. Water: about one hundred forty seven kelvin. Ice: about two hundred twenty five.
{eq16} Equation sixteen places every pixel on a line between the two tie points. Water is zero percent, ice is one hundred percent.
{map} This is the raw sea ice concentration of our orbit.
{noise} Over open water it should be zero everywhere. But it is noisy. The standard deviation over the water cluster is about eleven percent.
{why} The reason is the weather. Water vapour, wind and clouds make the water look warmer, and so it looks like ice.

## rtm | Step 6 · RTM correction | One pixel through the model
{pick} Let's follow one water pixel, south of Iceland, in a storm.
{raw} Its brightness temperature is one hundred fifty nine kelvin, so the raw ice concentration is fifteen percent. That is wrong: there is no ice here.
{inputs} Its weather is extreme. Twenty seven kilograms of water vapour per square metre, and a wind of sixteen and a half metres per second.
{ref} The reference is the mean weather of the clusters, mixed by the ice fraction c. Here c is zero, so it is just the mean of the water cluster.
{run} The radiative transfer model is run twice. With the reference weather it gives one hundred forty two kelvin. With the pixel's own weather, about one hundred fifty three.
{dtb} The difference, minus twelve kelvin, is the correction. This is equation fourteen.
{lnote} Note that the cloud liquid water is not corrected. Both runs use the mean value, because the ERA5 clouds do not match the clouds of nineteen seventy-three.
{tbc} Adding the correction gives a corrected brightness temperature of one hundred forty seven kelvin. Equation thirteen.
{sicc} With the corrected tie points, the ice concentration of this pixel is now zero percent.

## orbitcorr | Step 6 · RTM correction | The whole orbit
{dtbmap} We do the same for every valid ocean pixel. This is the correction map. Blue pixels are made colder, red pixels warmer.
{storm} The large corrections follow the weather systems over the open ocean.
{compare} Here is the raw ice concentration, and here the corrected one. The noise over open water is clearly reduced.

## iterate | Step 7 · Iteration | The ice fraction c
{problem} One problem remains. The model needs the ice fraction c as input, but c is what we want to compute.
{c0} So in the first iteration, we use the ERA5 ice concentration.
{c1} After the first correction, we have our own ice concentration. We clip it to zero to one hundred percent, set values below fifteen percent to zero, and run the correction again.
{tps} The tie points change a little with each iteration.
{std} And the noise over water drops: from eleven point three percent, to nine point three after the first iteration, to eight point three after the second.
{stop} A third iteration changes almost nothing, so we stop after two, as in the paper.

## result | Step 8 · Task 1 | Result for February 1973
{histo} This is the distribution of the ice concentration over open water on this day, before and after the correction.
{narrow} The mean stays at zero, but the distribution becomes narrower.
{month} Over all days of February, the standard deviation over water drops by about twenty three percent, in the north and in the south.
{ice} Over sea ice the improvement is smaller, because there only the ice temperature matters.

## sens | Step 9 · Task 2 | Which weather input matters most?
{setup} For the sensitivity study, we start from the mean weather of the clusters and increase one input at a time by one standard deviation.
{sweep} Then we sweep the incidence angle from zero to sixty four degrees.
{water} Over water, the water vapour gives the largest change that we correct, about seven kelvin at fifty degrees. Wind follows with three kelvin. The sea surface temperature hardly matters.
{cloud} Clouds would be even larger, but they are not corrected. They are the main remaining noise.
{angle} All water terms grow with the angle: the path through the atmosphere gets longer.
{iceside} Over ice, only the ice temperature matters, about four kelvin, almost independent of the angle.

## outro | Summary | The pipeline in one view
{all} To sum up: filter the data, select pure water and pure ice, correct every pixel with the radiative transfer model towards the mean weather, iterate the ice fraction, and compute the ice concentration with corrected tie points.
{numbers} On open water, this reduces the noise by about one quarter.
{next} The next step is Task 3: how the noise depends on the incidence angle.
