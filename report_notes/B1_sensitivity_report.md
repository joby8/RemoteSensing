## **Sensitivity Study**

## Intro

### 1. methods

The correction that we are making with RTM is based of multiple inputs from ERA5. Each input has an influence on the total correction of the output values. this influence is the sensitivity.

To find out which ERA5 inputs truly drive the correction we look at 2 complementery approaches.

### (a)

First we look at the RTM alone and sweep each parameter in order to see how big each effect can be on the correction. For this one input is varies over its physical range while the other inputs stay at their Feburar 1973 mean of the tie-point clusters. One exeption is L. L is set to L = 0 in the V, W, Ts and Ti sweeps. (talked about this). we do this because L would have an infuence on the others since we dont have true vlaues for L. The L sweep keeps the other values at the mean. To also have a look at different incidance angels we plot at θ = 0°, 30°, 50° for water (c = 0) and ice (c = 1). 

### (b)

Within the plot we also mark the +-1σ per parameter with a dotted line. At these x-coordinates we look at the 50° incidence angle for Ice and water. these numbers are also shown in table X. converted from detla Tb to SIC in %. (corrected tie points?)

### (c)

Then we rerun the RTM without one factor at a time in order to see their effects on the real data of 1973, this is the exclusion test. We compare the the daily std fot the open water SIC with the full correction.  so we see the infulence of our data in real.

### (d)

to test the influence of L dependet of which value to use for it we do a small study on it. Therefore we do 2 tests with each 2 iterations for RTM. Difference is that the seccond iteration of the seccond test usees the L per pixel instead of the mean. al other iterations use the L mean. then we compare the std of the SIC. this way we also test this desicion made in the paper kolbe et al. 

### 2.1 results (looking at model)

The results for the RTM sweep show that all effects are nearly linear over the observed range. 

the wind curve for water flattens towards large windspeeds. This i s caused by the roughness cap: σ² ≤ 0.07 above ≈ 19.5 m/s.

The water vapour V wind speed W and cloud liquid (water curves) all show somewhat similar type of results. the effect on the water is biggest and gets bigger with the incidence angle θ. The factor is about 1 .5–2 from 0° to 50°. The reason is the longer path 1/cos θ, and the lower H-pol emissivity is reflecting more sky.

the effect of these changes in Tb are bigger or smaller on the SIC in arctic and antarcitc depended on each ice-water contrast. The effects on the ice are in general smaller than the ones on water. and the factor with the biggest effect is ht eice temperature Ti. The sea surface temperature SST does not have a notable impact on the SIC, on water it is about 0.2%.

| Input | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
| --- | --- | --- | --- | --- |
| V | +8.2 % (1σ = 5.5 kg/m²) | +10.2 % (6.1 kg/m²) | +0.3 % | +0.5 % |
| W | +4.5 % (4.6 m/s) | +4.1 % (3.7 m/s) | 0 | 0 |
| L (not corr.) | +10.5 % (0.32 kg/m²) | +12.0 % (0.32 kg/m²) | +0.3 % | +0.5 % |
| Ts | −0.2 % (1.6 K) | −0.2 % (1.6 K) | 0 | 0 |
| Ti | 0 | 0 | +2.8 % (2.6 K) | +1.6 % (1.4 K) |

in total the effect of L is largest, seccond is V then W and Ts has a rather small influence and Ti only over ice.

### 2.2 results (looking at data- exclusion test)

looking at the real pixels these findings can be confirmed. 

|  | Arctic water | Antarctic water | Arctic ice | Antarctic ice |
| --- | --- | --- | --- | --- |
| full correction | 7.05 | 9.34 | 10.86 | 23.70 |
| without V | +1.20 | **+1.85** | +0.17 | +0.53 |
| without W | **+1.40** | +0.57 | −0.02 | +0.09 |
| without Ts | +0.01 | −0.02 | −0.04 | −0.12 |
| without Ti | +0.08 | +0.09 | **+1.51** | +0.34 |
| no correction | +2.56 | +2.54 | +1.67 | +0.87 |

in the graph it can be seen that v and w are the factors that have the biggest impact. while on ice the Ti has the biggest impact and Ts not really beeing relevant. the effect of it is &lt;= +0.01.

### 2.3 results (real pixels vs. model)

in the figure are all points seen are open water, so their SIC is 0%. All the deviation is error. X is ERA5 input of the pixel and Y is the computed SIC. 

The black line is the uncorrected error. it should be a flat line at 0% if there was no error. 

the orange line is the the RTMs input so what the model predicts. and the Blue line is the corrected version. 

for V and W the data follows the RTM line. resulting in good correction. For L the model lovershoots the correction a lot. The model alone therefore would suggest that L has the largest effect. 

The Ts small effects really come from moist air not water temp itself. 

fore the ice: 

this is the same plot as x but for ice. 

in the arctic the model has a correction on the ice. but in the antarcic summer melt and wet snow change the emissivity. The model does not handle this well, this is a limiitation. 

V and L have a rather small influence over sea ice. 

The Ti over water ist estimated by RTM with no effect but the data showes 2.3/ 4.0 percent per std. this is because Ti comes from air tpem which is correclated to V. looking at the two lines we see that it exits but not accounted is for by the model. 

the wind over ice is also not accounted for in the RTM but in the antarctic it has an effect with a drop of -1.7% per std. this could be caused by openings in the ice. these could be opened by strong winds. 

ts over ice has no information and is therefore left out. 

### 2.4 results L study

the results of the correction with L per pixel show a large effect. But this effect actually is in the worse direction so not a better model but a worse one. 

the mean of the daily std of sic over the month:

|  | uncorrected | mean L | per-pixel L |
| --- | --- | --- | --- |
| Arctic water | 9.61 | **7.05** | 9.99 |
| Antarctic water | 11.88 | **9.34** | 13.61 |
| Arctic ice | 12.53 | 10.86 | 10.85 |
| Antarctic ice | 24.57 | 23.70 | 23.65 |

Over water the mean is better than the per pixel value on all days. in the mean open water SIC in L the uncorrected version rises with L from -4% to 9%. with the correction of mean L it stays around +-2%. with the correction L per pixel it drops to -14% arctic and -19% antarctic at L =0.8 and and could free pixels get a +4…6% correction. so ERA5 could liquid does not match the clouds which were seen by ESMR.

Over ice the effect is close to 0. L hardly changes the ice Tb. this is also seen in sweep test. 

the mean L ist therefore the better choice. 

### 3. Discussion

in conclusion the model and the data agreee. the effect of V is biggest followed by W and then smaller effects can be seen by ts over water while Ti has an effect over ice. the direct view of the data in b1f confims the sizes of these effects. 

the remaining noise source in the correction is caused by L. In the model L is larger than V but in the real data it is less than half as large b1f. it is not corrected because the era5 coulds do not match the 1973 scenes per pixel. the per pixel L makes the correction worse.  

the SST Ts is unsuable with the only one 19 ghz channel. for a good sst correction we would need another lower frequency. 

the ice temperature ti does some improvement on the ice side in the arctic with 1.54 % when left out.

 the antarctic summer with melting ice, wet snow and water vapour over the ice edge is a complex problem in this data. therefore the ice data in antarctica should not be overinterpretet since the ice noise is around 24%.

the angle dependence is especially big for w, V, L(if it was corrected)

(ich denke zu where it maters on the map sollte man hier nix schreiben; hier geht es nur um sensitivity study)