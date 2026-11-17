
function [DataOut] = getTiePoints2(Data)
% GETTIEPOINTS
% Extracts Arctic and Antarctic ice and ocean tie points
% based on Kolbe et al. (2024), Table 2.
%
% Input:
%   Data       Struct containing Tbfilt, Latitude, siconc,
%              sst and lsm.
%
% Output:
%   DataOut    Original struct extended by tie-point fields:
%              TbArcIce, TbArcOcean, TbAntIce, TbAntOcean
%              ArcIce, ArcOcean, AntIce, AntOcean
%              TPnames

    %% Preserve input structure
    DataOut = Data;

    DataOut.TPnames = ["ArcIce", "ArcOcean", ...
                       "AntIce", "AntOcean"];

    %% Read input variables
    Tb       = Data.Tbfilt;
    latFull  = Data.Latitude;
    sicFull  = Data.siconc;
    sstFull  = Data.sst;
    lsmFull  = Data.lsm;

    %% Crop variables to match filtered brightness temperature
    % filterTb removes the outer swath rows using 5:end-4.

    rows = 1:(size(sicFull,1));

    lat  = latFull(rows,:);
    sic  = sicFull(rows,:);
    sst  = sstFull(rows,:);
    lsm  = lsmFull(rows,:);

    %% Check dimensions
    if ~isequal(size(Tb), size(lat), size(sic), ...
                size(sst), size(lsm))

        error(['Dimension mismatch between Tbfilt, Latitude, ', ...
               'siconc, sst and lsm.']);
    end

    %% Calculate 5 x 5 mean SIC
    % A complete 5 x 5 neighborhood is required.
    % If one of the 25 SIC values is missing, the box mean
    % is considered invalid.

    boxSize = 5;
    kernel = ones(boxSize);

    validSIC = ~isnan(sicFull) & ~isinf(sicFull);

    sicForSum = sicFull;
    sicForSum(~validSIC) = 0;

    boxSum = conv2(sicForSum, kernel, 'same');
    boxCount = conv2(double(validSIC), kernel, 'same');

    boxMeanFull = boxSum ./ boxCount;

    % Require all 25 SIC values to be valid
    boxMeanFull(boxCount ~= 25) = NaN;

    % Crop to match Tbfilt
    boxMean = boxMeanFull(rows,:);

    %% Common validity masks
    validTb = ~isnan(Tb) & ~isinf(Tb);
    validLat = ~isnan(lat) & ~isinf(lat);
    validSIC = ~isnan(sic) & ~isinf(sic);
    validBox = ~isnan(boxMean) & ~isinf(boxMean);
    validSST = ~isnan(sst) & ~isinf(sst);
    validLSM = ~isnan(lsm) & ~isinf(lsm);

    % Exclude land and missing land-mask values.
    % The land-mask exclusion is an additional safeguard;
    % it is not explicitly listed as a criterion in Table 2.
    oceanSurface = validLSM & (lsm <= 0.1);

    %% Latitude regions
    arcticRegion = validLat & ...
                   lat > 50 & lat < 90;

    antarcticRegion = validLat & ...
                      lat > -90 & lat < -50;

    %% Arctic ice tie points
    ArcIceMask = validTb & ...
                 validSIC & ...
                 validBox & ...
                 oceanSurface & ...
                 arcticRegion & ...
                 sic > 0.8 & ...
                 boxMean > 0.8 & ...
                 Tb > 100 & Tb < 274;

    %% Arctic ocean tie points
    ArcOceanMask = validTb & ...
                   validSIC & ...
                   validBox & ...
                   validSST & ...
                   oceanSurface & ...
                   arcticRegion & ...
                   sic < 0.01 & ...
                   boxMean < 0.01 & ...
                   sst > 278 & ...
                   Tb > 90 & Tb < 180;

    %% Antarctic ice tie points
    AntIceMask = validTb & ...
                 validSIC & ...
                 validBox & ...
                 oceanSurface & ...
                 antarcticRegion & ...
                 sic > 0.8 & ...
                 boxMean > 0.8 & ...
                 Tb > 180 & Tb < 274;

    %% Antarctic ocean tie points
    AntOceanMask = validTb & ...
                   validSIC & ...
                   validBox & ...
                   validSST & ...
                   oceanSurface & ...
                   antarcticRegion & ...
                   sic < 0.01 & ...
                   boxMean < 0.01 & ...
                   sst > 278 & ...
                   Tb > 90 & Tb < 180;

    %% Create tie-point brightness temperature arrays
    ArcIce = NaN(size(Tb));
    ArcOcean = NaN(size(Tb));
    AntIce = NaN(size(Tb));
    AntOcean = NaN(size(Tb));

    ArcIce(ArcIceMask) = Tb(ArcIceMask);
    ArcOcean(ArcOceanMask) = Tb(ArcOceanMask);
    AntIce(AntIceMask) = Tb(AntIceMask);
    AntOcean(AntOceanMask) = Tb(AntOceanMask);

    AntIceMask = double(AntIceMask);
    AntIceMask(AntIceMask == 0) = NaN;
    AntOceanMask = double(AntOceanMask);
    AntOceanMask(AntOceanMask == 0) = NaN;
    ArcIceMask = double(ArcIceMask);
    ArcIceMask(ArcIceMask == 0) = NaN;
    ArcOceanMask = double(ArcOceanMask);
    ArcOceanMask(ArcOceanMask == 0) = NaN;
    
    %% Store results
    DataOut.TbArcIce = ArcIce;
    DataOut.TbArcOcean = ArcOcean;

    DataOut.TbAntIce = AntIce;
    DataOut.TbAntOcean = AntOcean;

    DataOut.ArcIce = ArcIceMask;
    DataOut.ArcOcean = ArcOceanMask;

    DataOut.AntIce = AntIceMask;
    DataOut.AntOcean = AntOceanMask;

end
