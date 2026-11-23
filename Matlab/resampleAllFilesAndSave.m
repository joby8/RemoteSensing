init;

days = 7:7;

inc = 1+4:78-4;

for day = days
    % Init struct that contains all data of a day
    cdffiles = day_indices(1,day):day_indices(2,day);     
    DataOfDay = struct( ...
    'Tbfilt',[], ...
    'Latitude',[],...
    'Longitude',[], ...
    'lsm',[], ...
    'u10',[],...
    'v10',[], ...
    't2m',[], ...
    'siconc',[], ...
    'sst',[], ...
    'tcw',[], ...
    'tcwv',[], ...
    'incidence',[]); 

    % Read all data from one day
    for j = cdffiles
        filename = fullfile(projectdir, dinfo(j).name);
        Data = readNetCDFStruct(filename);

        % Tbfilt = filterTb(Data);
        Tbfilt = Data.variables.brightness_temperature_filtered.data;
        DataOfDay.Tbfilt = cat(2, DataOfDay.Tbfilt, Tbfilt(inc,:),NaN(length(inc),2));
        DataOfDay.Latitude = cat(2, DataOfDay.Latitude, Data.variables.Latitude.data(inc,:),NaN(length(inc),2));
        DataOfDay.Longitude = cat(2, DataOfDay.Longitude, Data.variables.Longitude.data(inc,:),NaN(length(inc),2));
        DataOfDay.lsm = cat(2, DataOfDay.lsm, Data.variables.lsm.data(inc,:),NaN(length(inc),2));
        DataOfDay.u10 = cat(2, DataOfDay.u10, Data.variables.u10.data(inc,:),NaN(length(inc),2));
        DataOfDay.v10 = cat(2, DataOfDay.v10, Data.variables.v10.data(inc,:),NaN(length(inc),2));
        DataOfDay.t2m = cat(2, DataOfDay.t2m, Data.variables.t2m.data(inc,:),NaN(length(inc),2));
        DataOfDay.siconc = cat(2, DataOfDay.siconc, Data.variables.siconc.data(inc,:),NaN(length(inc),2));
        DataOfDay.sst = cat(2, DataOfDay.sst, Data.variables.sst.data(inc,:),NaN(length(inc),2));
        DataOfDay.tcw = cat(2, DataOfDay.tcw, Data.variables.tcw.data(inc,:),NaN(length(inc),2));
        DataOfDay.tcwv = cat(2, DataOfDay.tcwv, Data.variables.tcwv.data(inc,:),NaN(length(inc),2));
        DataOfDay.incidence = cat(2, DataOfDay.incidence, repmat(spos2ia(inc)', [1,Data.dimensions.Time]),NaN(length(inc),2));
    end
    
    % Resample Data
    % DataOfDay = resampleGaussian(DataOfDay, [0.2, 0.2], 0.2);
    % DataOfDay = resampleNearest(DataOfDay, [0.3, 0.3], 0.6);
    name = join(["DataOfDay",day,],'');
    save(name,"DataOfDay");
    fprintf("Completed Day %.0f \n",day)
end