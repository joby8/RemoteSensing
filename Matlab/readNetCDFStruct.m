
function S = readNetCDFStruct(filename)
%READNETCDFSTRUCT Read all variables and metadata from a NetCDF file.
%
% INPUT:
%   filename : Path to the NetCDF (.nc) file
%
% OUTPUT:
%   S        : Structure containing all data and metadata
%
% ACCESS EXAMPLES:
%   S.variables.sst.data
%   S.variables.Latitude.data
%   S.variables.Brightness_temperature.data
%   S.globalAttributes.title
%
%   S.variables.sst.attributes.units
%   S.variables.sst.dimensions

    % Check whether file exists
    if ~isfile(filename)
        error('File not found: %s', filename);
    end

    % Get NetCDF file information
    info = ncinfo(filename);

    % Initialize output structure
    S = struct();

    S.filename = filename;

    %% 1. Read dimensions

    S.dimensions = struct();

    for i = 1:length(info.Dimensions)

        dimName = matlab.lang.makeValidName( ...
            info.Dimensions(i).Name);

        S.dimensions.(dimName) = info.Dimensions(i).Length;

    end

    %% 2. Read global attributes

    S.globalAttributes = struct();

    for i = 1:length(info.Attributes)

        attrName = matlab.lang.makeValidName( ...
            info.Attributes(i).Name);

        S.globalAttributes.(attrName) = ...
            info.Attributes(i).Value;

    end

    %% 3. Read all variables

    S.variables = struct();

    for i = 1:length(info.Variables)

        % Original variable name
        varName = info.Variables(i).Name;

        % MATLAB-compatible field name
        fieldName = matlab.lang.makeValidName(varName);

        % Read variable data
        S.variables.(fieldName).data = ...
            ncread(filename, varName);

        % Store original variable name
        S.variables.(fieldName).name = varName;

        % Store dimensions
        S.variables.(fieldName).dimensions = ...
            {info.Variables(i).Dimensions.Name};

        % Store datatype
        S.variables.(fieldName).datatype = ...
            info.Variables(i).Datatype;

        % Store variable size
        S.variables.(fieldName).size = ...
            info.Variables(i).Size;

        % Read variable attributes
        S.variables.(fieldName).attributes = struct();

        for j = 1:length(info.Variables(i).Attributes)

            attrName = matlab.lang.makeValidName( ...
                info.Variables(i).Attributes(j).Name);

            S.variables.(fieldName).attributes.(attrName) = ...
                info.Variables(i).Attributes(j).Value;

        end

    end

    fprintf('Successfully read NetCDF file: %s\n', filename);
    fprintf('Number of variables: %d\n', length(info.Variables));

end
