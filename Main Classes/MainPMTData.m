classdef MainPMTData < handle
    properties(Access = private)
        mainFig;
        cFilter;
        eFilter;
        handles;
        DataStorage;
        CalData;
        LampVal=[1607100,1840100,2074400,2336200,2636200,2875600,3114400,3375000,...
            3656800,3958800,4308200,4657000,4955000,5153500,5360400,5555400,...
            5748400,5993800,6234000,6468600,6641900,6941500,7205900,7461800,...
            7714100,7978300,8233400,8433400,8606600,8900800,9093900,9239500]';
        UnitConv;
        PDVData;
    end
    properties(Access = public)
        fileNames;
        filePath;
        selectedFiles;
    end
    methods
        function obj = MainPMTData(mainFig,varargin)
            obj.mainFig = mainFig;
            obj.handles = guidata(obj.mainFig);
            if length(varargin)
                obj.PDVData = varargin{1};
                set(obj.handles.PDVFileList,'String',varargin{2});
                set(obj.handles.PDVPlot_Box,'Enable','on');
                %set(obj.handles.PDVFileList,'Enable','on');
            end
            %Store Filter Matrix here, I didn't do it in the data object
            %because I don't want to keep opening and closing a text file
            %upon a data structure instance.
            [obj.eFilter,obj.cFilter] = obj.ReadFilterData('EmissionFilterData_Interpolated.txt'); 
        end
        function LoadRoutine(obj)
            [fNames,fPath] = uigetfile('*.tdms','Load PMT Files','multiselect','on');
            if strcmp(string(fPath),'0')
                error('LoadData:NoData',...
                    'No file input')
            end
            if ischar(fNames)
                fNames = {fNames};
            end
            T = length(fNames);
            Label = {'FileName','Delay (ns)'};
            data = [fNames',string(zeros(length(fNames),1))];
            data = cellstr(data);
            set(obj.handles.FileList,'Data',data);
            set(obj.handles.FileList,'ColumnName',Label);
            obj.UnitConv = [];
            obj.DataStorage = cell(T,1);
            set(obj.handles.runGray,'Enable','off');
            set(obj.handles.runTempAll,'Enable','off');
            obj.fileNames = fNames; obj.filePath = fPath;
        end
        function calcTemp(obj,idx)
            obj.DataStorage{idx}.Tolerance = str2double(get(obj.handles.ConfBound,'String'));
            obj.DataStorage{idx}.GrayBodyFit();
            obj.TempPlot(idx);
            obj.EmissivityPlot(idx);
            obj.SpectrumPlot(idx);
        end
        function calcTempAll(obj)
                for i = 1:length(obj.fileNames)
                    obj.calcTemp(i);
                end
        end
        function TempAverage(obj,Files)
            for i = 1:length(Files)
                Data(:,:,i) = obj.DataStorage{Files(i)}.BinData;
                Delay(i) = obj.DataStorage{Files(i)}.Delay;
            end
            idx = find(contains(obj.fileNames,'Averaged Data'));
            TableData = get(obj.handles.FileList,'data');
            if ~isempty(idx)
                Index = idx;
            else
                Index = length(obj.fileNames)+1;
                obj.fileNames{Index} = 'Averaged Data';
                TableData(end+1,1) = {obj.fileNames{Index}};
                Index = length(TableData(:,1));
            end
            FileData.Delay = mean(Delay);
            FileData.binRes = str2double(get(obj.handles.binRes,'String'));
            FileData.binStart = str2double(get(obj.handles.binStart,'String'));
            FileData.binEnd = str2double(get(obj.handles.binEnd,'String'));
            obj.DataStorage{Index} = PMTData(FileData,0);
            [obj.DataStorage{Index}.BinData,obj.DataStorage{Index}.binRad] = AVG_Data(Data);
            TableData(Index,2) = {uint16(FileData.Delay.*1E9)};
            set(obj.handles.FileList,'data',TableData);
        end
        function NewCalibration(obj)
            %Load New Cal file in case you need different calibrations for
            %different files in one batdch
            obj.UnitConv = []; %clear current calibration data
            obj.Calibrate(); %populate new calibartion data
        end    
        function BinPMTData(obj,idx,ManualDelay)
            if isempty(obj.UnitConv)
                obj.Calibrate();
            end
            ExcChannels = get(obj.handles.ExcChannelEdit,'String');
            ExcChannels = strsplit(ExcChannels,',');
            rawFile = convertTDMS(0,fullfile(obj.filePath,obj.fileNames{idx}));
            %grab parameters to make individual datafile measurement
            
            cFiltidx = get(obj.handles.calFiltList,'Value');
            eFiltidx = get(obj.handles.expFiltList,'Value');
            %% Make a structure of the file data this instance of PMT (i.e this PMT file) will be using for conversion
            %%File data is used in the PMTData program, and has the
            %%following fields:
            % Data: (Measured Data Array From tdms conversion) - Note to
            %   self, should probably just put this in the front end of the
            %   object instance.
            % eFilt: desired emission filter selection based on gui input
            % cFilt: desired calibration filter
            % binStart,binEnd,Thresh: start decade, end decade and theshold
            %       for peak/rise time determination
            % UnitConv: Normalizing to calibration source, in this case the
            %       integrating sphere
            % Target: Target time to set feature at
            % binBool: Determines whether or not to bin (not yet
            % implemented)
            % This data is fed to DataStorage which provides an instance of
            % a datafile, in this case a PMT file where the only public variables are binData 
            % (binned time and binned spec rad),binRad,binTemp and binPhi.
            FileData = struct;
            DataArray = extractfield(rawFile.Data.MeasuredData,'Data');
            DataArray = reshape(DataArray,length(DataArray)/33,33);
            Time = DataArray(:,5); Volt = DataArray.*-1;
            Volt(:,5) = [];
            switch ManualDelay
                case 0 %called from an automated setting
                    FileData.Delay = obj.FindPeakDelay(Time,Volt);
                case 1 %manually input
                    delayData = get(obj.handles.FileList,'data');
                    delay = delayData{idx,2};

                    switch class(delay)
                        case 'char'
                            delay = convertCharsToStrings(delay);
                            delay = str2double(delay);
                        otherwise
                            delay = double(delay);
                    end
                    FileData.Delay = delay.*1E-9; %convert to s
                case 2 %found from ginput
                    delayData = get(obj.handles.FileList,'data');
                    delay = delayData{idx,2};
                    offset = ginput(1); offset = offset(1)*1E9;
                    delay = delay + offset;
                    FileData.Delay = double(delay).*1E-9; %convert to s
            end
                    
            delayData = get(obj.handles.FileList,'data');
            delayData{idx,2} = uint16(FileData.Delay*1E9);
            set(obj.handles.FileList,'data',delayData);
            FileData.Time = Time - FileData.Delay;
            FileData.Volt = Volt;
            FileData.ExcChannels = ExcChannels;
            
            switch eFiltidx
                case 5
                    FileData.eFilt = obj.eFilter(:,2).*obj.eFilter(:,4);
                case 6
                    FileData.eFilt = obj.eFilter(:,3).*obj.eFilter(:,4);
                case 7
                    FileData.eFilt = obj.eFilter(:,2).*obj.eFilter(:,3).*obj.eFilter(:,4);
                otherwise
                    FileData.eFilt = obj.eFilter(:,eFiltidx);
            end
            
            FileData.cFilt = obj.cFilter(:,cFiltidx);
            FileData.binRes = str2double(get(obj.handles.binRes,'String'));
            FileData.binStart = str2double(get(obj.handles.binStart,'String'));
            FileData.binEnd = str2double(get(obj.handles.binEnd,'String'));
            FileData.UnitConv = obj.UnitConv;
            FileData.binBool = ~(str2double(get(obj.handles.binRes,'String'))==0);
            obj.DataStorage{idx} = PMTData(FileData,1);
            obj.RadianceSemiLogPlot(idx);
            set(obj.handles.runGray,'Enable','on');
            set(obj.handles.runTempAll,'Enable','on');
        end
        function RadiancePlot(obj,idx)
            axes(obj.handles.RadAxis);
            time = obj.DataStorage{idx}.BinData(:,1);
            Radiance = obj.DataStorage{idx}.binRad;
            plot(time,Radiance); xlim([0,5E-7]);
        end
        function RadianceSemiLogPlot(obj,idx)
            axes(obj.handles.RadAxis);
            time = obj.DataStorage{idx}.BinData(:,1);
            Radiance = obj.DataStorage{idx}.binRad;
            yyaxis left; Ax = gca; set(Ax.YAxis,'Color','k');
            xmax = str2num(obj.handles.GraphEndDecadeEdit.String);
            semilogx(time,Radiance,'linewidth',3,'Color','r'); xlim([1E-9,xmax]);
            ylim([0,max(Radiance)*1.05])
            ylabel('total radiance (W/sr-m^2)','Color','r'); xlabel('time (s)')
            text = sprintf('Radiance Plot of %s',obj.fileNames{idx});
            title(text);
            obj.PlotPDV();
        end
            function TempPlot(obj,idx)
                axes(obj.handles.TempAxis);
                yyaxis left; hold off;
                Temp = obj.DataStorage{idx}.binGray.Temp;
                TempError = obj.DataStorage{idx}.binGray.TempError;
                time = obj.DataStorage{idx}.BinData(:,1);
                xmax = str2num(obj.handles.GraphEndDecadeEdit.String);
                semilogx(time,Temp,'o'); hold on; errorbar(time,Temp,TempError,'LineStyle','none','Color','b');
                xlim([1E-9,xmax]); ylim([0,max(Temp)+500]);
                text = sprintf('Temp Plot of %s',obj.fileNames{idx});
                title(text);
            end
            function EmissivityPlot(obj,idx)
                axes(obj.handles.EmissivityAxis); hold off;
                Emissivity = obj.DataStorage{idx}.binGray.Emissivity;
                EmissivityError = obj.DataStorage{idx}.binGray.EmissivityError;
                time = obj.DataStorage{idx}.BinData(:,1);
                semilogx(time,Emissivity,'o'); hold on; errorbar(time,Emissivity,EmissivityError,'LineStyle','none','Color','b');
                xmax = str2num(obj.handles.GraphEndDecadeEdit.String);
                xlim([1E-9,xmax]); ylim([0,max(Emissivity)+0.1]);
                text = sprintf('Emissivity Plot of %s',obj.fileNames{idx});
                title(text);
            end
            function SpectrumPlot(obj,idx)
                axes(obj.handles.axes5); hold off;
                Radiance = obj.DataStorage{idx}.binRad;
                Temp = obj.DataStorage{idx}.binGray.Temp;
                TempError = obj.DataStorage{idx}.binGray.TempError;
                time = obj.DataStorage{idx}.BinData(:,1);
                xmax = str2num(obj.handles.GraphEndDecadeEdit.String);
                xlim([1E-9,xmax]); ylim([0,max(Temp)+500]);
                yyaxis left; hold off;
                semilogx(time,Temp,'o'); hold on; errorbar(time,Temp,TempError,'LineStyle','none','Color','b');
                yyaxis right; hold off;
                semilogx(time,Radiance,'k'); ylim([0,max(Radiance)]);
                xlabel('time (ns)'); ylabel('Temperature'); hold off;
                yyaxis left;
                obj.handles.axes5.ButtonDownFcn = @obj.FindCoordinates;
            end
            function PlotPDV(obj)
                
                
                if get(obj.handles.PDVPlot_Box,'Value')
                    try
                       Ridx = min(obj.selectedFiles);
                       PDVNames = get(obj.handles.PDVFileList,'String');
                       A = cellfun(@(x) split(x,'_'),PDVNames,'UniformOutput',false);
                       A = cellfun(@(x) x{1},A,'UniformOutput',false);
                       B = split(obj.fileNames{Ridx},'.');B = B{1};
                       try
                            Pidx = find(strcmp(A,B));
                            set(obj.handles.PDVFileList,'Value',Pidx);
                       catch
                           Pidx = get(obj.handles.PDVFileList,'Value');
                           Pidx = min(Pidx);
                       end
                       Delay = obj.DataStorage{Ridx}.Delay;
                       
                    catch
                        Delay = 0;
                    end
                    %}
                    %%Plot on Radiance
                    axes(obj.handles.RadAxis); yyaxis right;
                    hold off;
                    PDV_Data = obj.PDVData{Pidx};
                    
                    Time = PDV_Data.VelTime.*1E-9 - Delay; Velocity = PDV_Data.Velocity;
                    Time = Time(Time<5E-7); Velocity = Velocity(Time<5E-7);
                    Velocity(Velocity > 4.5) = NaN;
                    semilogx(Time,Velocity,'linewidth',2,'Color','k');
                    xmax = double(obj.handles.GraphEndDecadeEdit.String);
                    xlim([1E-9,~]); ylim([0,4.5]);
                    ylabel('velocity (km/s)');
                    
                    %%Plot on Temperature
                    axes(obj.handles.TempAxis); yyaxis right;
                    hold off;
                    PDV_Data = obj.PDVData{Pidx};
                    Time = PDV_Data.VelTime.*1E-9 - Delay; Velocity = PDV_Data.Velocity;
                    Time = Time(Time<5E-8); Velocity = Velocity(Time<5E-8);
                    Velocity(Velocity > 4.5) = NaN;
                    semilogx(Time,Velocity,'linewidth',2,'Color','k');
                    xlim([1E-9,5E-7]); ylim([0,4.5]);
                    ylabel('velocity (km/s)');
                else
                    yyaxis right;
                    plot(NaN,NaN);
                    axes(obj.handles.RadAxis); yyaxis right;
                    plot(NaN,NaN);
                end
            end
            function FindCoordinates(obj,~,eventdata)
                coordinates = eventdata.IntersectionPoint(1:2);
                x = coordinates(1); y = coordinates(2);
                idx = min(obj.selectedFiles);
                time = obj.DataStorage{idx}.BinData(:,1);
                axes(obj.handles.axes5); hold off;
                [~,t_idx] = min(abs(x-time));
                children = get(gca,'children');
                if length(children) > 2
                    delete(children(1));
                end
                try
                xline(time(t_idx)); hold off;
                catch
                end
                axes(obj.handles.SpectrumAxis); hold off;
                Spectrum = obj.DataStorage{idx}.BinData(t_idx,2:end);
                lambda = obj.DataStorage{idx}.GetWavelength();
                plot(lambda,Spectrum,'ok'); hold on
                [Ybb,T,eT,E,eE] = obj.DataStorage{idx}.FetchBBFit(t_idx);
                plot(lambda,Ybb,'r');
                Text = sprintf('time = %2.0f \n Temp = %2.0f +/- %2.0f \n E = %2.3f +/- %2.3f',time(t_idx).*1E9,T,eT,E,eE);
                legend({'Data',Text},'Position',[0.175,0.80,0,0]); hold off;
                ylabel('spectral radiance');
                
            end
            function SaveAsTxt(obj)
                saveSettings = struct();
                switch get(obj.handles.RadSave,'Checked')
                    case 'on'
                        saveSettings.Rad = 1;
                    case 'off'
                        saveSettings.Rad = 0;
                end
                switch get(obj.handles.TempSave,'Checked')
                    case 'on'
                        saveSettings.Temp = 1;
                    case 'off'
                        saveSettings.Temp = 0;
                end
                switch get(obj.handles.EmissivitySave,'Checked')
                    case 'on'
                        saveSettings.Emissivity = 1;
                    case 'off'
                        saveSettings.Emissivity = 0;
                end
                switch get(obj.handles.SpectrumSave,'Checked')
                    case 'on'
                        saveSettings.Spectrum = 1;
                    case 'off'
                        saveSettings.Spectrum = 0;
                end
                switch get(obj.handles.VelocitySave,'Checked')
                    case 'on'
                        saveSettings.PDV = 1;
                    case 'off'
                        saveSettings.PDV = 0;
                end
                WD = pwd();
                cd(obj.filePath);
                [SaveFile,SavePath] = uiputfile('*.txt','Select Save File Destination');
                cd(WD); 
                if saveSettings.Rad
                    obj.SaveRad(SaveFile,SavePath);
                end
                if saveSettings.Temp
                    obj.SaveTemp(SaveFile,SavePath);
                end
                if saveSettings.Emissivity
                    obj.SaveEmissivity(SaveFile,SavePath);
                end
                if saveSettings.Spectrum
                    for idx = 1:length(obj.fileNames)
                        obj.SaveSpecRad(SavePath,idx);
                    end
                end
                if saveSettings.PDV
                    obj.PDVData.Vel2Text(SavePath);
                end
            end
            function AddPDVData(obj,Data,Names)
                obj.PDVData = Data;
                set(obj.handles.PDVFileList,'String',Names);
            end
            function BinAll(obj)
                    for i = 1:length(obj.fileNames)
                        obj.BinPMTData(i,get(obj.handles.ManualDelay,'Value'));
                    end
            end
            
            

    end
    methods(Access = private)
        function Calibrate(obj)
            [calName,calPath] = uigetfile('*.tdms','Load Calibration File');
            rawFile = convertTDMS(0,fullfile(calPath,calName));
            calMat = extractfield(rawFile.Data.MeasuredData,'Data');
            calMat = reshape(calMat,length(calMat)/33,33);
            Time = calMat(:,5) + calMat(1,5); calMat(:,5) = [];
            Volt = calMat*-1;
            Current = Volt*1e-6;
            AvgCurrent = mean(Current,1)';
            obj.UnitConv = obj.LampVal./AvgCurrent;
            
        end
        function [delay] = FindPeakDelay(obj,Time,Volt)
            %Function finds when delay should be applied, based on Ch. 20
            %unless manually specified
            Target = str2double(get(obj.handles.delayTarget,'String'));
            Target = Target.*1E-9;
            Thresh = str2double(get(obj.handles.ThreshEdit,'String'));
            Volt = Volt(:,15);
            Volt = Volt(Time<2e-6);
            rms = sqrt(mean(Volt(1:250).^2));
            if get(obj.handles.peakButton,'Value')
                [~,locs] = findpeaks(Volt,'MinPeakHeight',Thresh*rms,...
                    'MinPeakDistance',50E-9);
                [~, maxLoc] = max(Volt(locs(1:5)));
                delay = Time(locs(maxLoc))-Target;
            elseif get(obj.handles.riseButton,'Value')
                [Loc] = find(Volt > Thresh*rms,1,'first');
                delay = Time(Loc) - Target;
            else
                delay = 1E-7;
            end
            
        end
        function SaveRad(obj,sName,sPath)
            sName = strsplit(sName,'.txt'); sName = sName{1};
            sName = sprintf('%s_radiance.txt',sName);
                hdr1 = {}; hdr2 = {}; hdr3 = {};
                for i = 1:length(obj.fileNames)
                    hdr1 = [hdr1,'time','radiance'];
                    hdr2 = [hdr2,'ns','(W/sr-m^2)'];
                    hdr3 = [hdr3, obj.fileNames{i},obj.fileNames{i}];
                    save_data = [obj.DataStorage{i}.BinData(:,1).*1E9,obj.DataStorage{i}.binRad];
                    full_save{i} = save_data;
                end
                fmt = repmat('%s\t ', 1, length(hdr1));
                fmt(end:end+1) = '\n';
                %open save file and write headers
                fid = fopen(fullfile(sPath,sName), 'w');
                fprintf(fid, fmt, hdr1{:});
                fprintf(fid,fmt, hdr2{:});
                fprintf(fid,fmt, hdr3{:});
                fclose(fid);
                %now insert data vector
                dlmwrite(fullfile(sPath,sName),full_save,'-append','delimiter','\t');
        end
        function SaveTemp(obj,sName,sPath)
                hdr1 = {}; hdr2 = {}; hdr3 = {};
                sName = strsplit(sName,'.txt'); sName = sName{1};
                sName = sprintf('%s_grayTemp.txt',sName);
                for i = 1:length(obj.fileNames)
                    hdr1 = [hdr1,'time','temperature','error'];
                    hdr2 = [hdr2,'ns','K','k'];
                    hdr3 = [hdr3, obj.fileNames{i},obj.fileNames{i},obj.fileNames{i}];
                    save_data = [obj.DataStorage{i}.BinData(:,1).*1E9,obj.DataStorage{i}.binGray.Temp',obj.DataStorage{i}.binGray.TempError'];
                    full_save{i} = save_data;
                end
                fmt = repmat('%s\t ', 1, length(hdr1));
                fmt(end:end+1) = '\n';
                %open save file and write headers
                fid = fopen(fullfile(sPath,sName), 'w');
                fprintf(fid, fmt, hdr1{:});
                fprintf(fid,fmt, hdr2{:});
                fprintf(fid,fmt, hdr3{:});
                fclose(fid);
                %now insert data vector
                dlmwrite(fullfile(sPath,sName),full_save,'-append','delimiter','\t');
        end
        function SaveEmissivity(obj,sName,sPath)
                hdr1 = {}; hdr2 = {}; hdr3 = {};
                sName = strsplit(sName,'.txt'); sName = sName{1};
                sName = sprintf('%s_grayPhi.txt',sName);
                for i = 1:length(obj.fileNames)
                    hdr1 = [hdr1,'time','Phi','error'];
                    hdr2 = [hdr2,'ns','ratio','ratio'];
                    hdr3 = [hdr3, obj.fileNames{i},obj.fileNames{i},obj.fileNames{i}];
                    save_data = [obj.DataStorage{i}.BinData(:,1).*1E9,obj.DataStorage{i}.binGray.Emissivity',obj.DataStorage{i}.binGray.EmissivityError'];
                    full_save{i} = save_data;
                end
                fmt = repmat('%s\t ', 1, length(hdr1));
                fmt(end:end+1) = '\n';
                %open save file and write headers
                fid = fopen(fullfile(sPath,sName), 'w');
                fprintf(fid, fmt, hdr1{:});
                fprintf(fid,fmt, hdr2{:});
                fprintf(fid,fmt, hdr3{:});
                fclose(fid);
                %now insert data vector
                dlmwrite(fullfile(sPath,sName),full_save,'-append','delimiter','\t');
        end
        function SaveSpecRad(obj,sPath,idx)
            %specific to index file, since composite save cannot be done
            %yet
            %create the name, intention to be 'filename_SpecRad.txt'
            sName = strsplit(obj.fileNames{idx},'.tdms'); sName = sName{1};
            sName = sprintf('%s_SpecRad.txt',sName);
            time = obj.DataStorage{idx}.BinData(:,1).*1E9;
            lambda = obj.DataStorage{idx}.GetWavelength();
            specrad = obj.DataStorage{idx}.BinData(:,2:end);
                hdr1 = {}; hdr2 = {}; hdr3 = {};
                hdr1 = [hdr1,'wavelength']; hdr2 = [hdr2,'nm'];
                hdr3 = [hdr3, sName];
                full_save{1} = lambda;
                for i = 2:length(time)
                    hdr1 = [hdr1,'spectral radiance'];
                    hdr2 = [hdr2,'W/sr-m^3'];
                    hdr3 = [hdr3, sprintf('%f ns',time(i))];
                    save_data = [specrad(i,:)]';
                    full_save{i} = save_data;
                end
                fmt = repmat('%s\t ', 1, length(hdr1));
                fmt(end:end+1) = '\n';
                %open save file and write headers
                fid = fopen(fullfile(sPath,sName), 'w');
                fprintf(fid, fmt, hdr1{:});
                fprintf(fid,fmt, hdr2{:});
                fprintf(fid,fmt, hdr3{:});
                fclose(fid);
                %now insert data vector
                dlmwrite(fullfile(sPath,sName),full_save,'-append','delimiter','\t');
        end
        function Vel2Text(obj,sPath)
            hdr1 = {}; hdr2 = {}; hdr3 = {};
            max_vector_size = [];
                for i=1:length(obj.DataStorage)
                    max_vector_size(i) = length(obj.DataStorage{i}.VelTime);
                end
                max_vector_size = max(max_vector_size);
            full_save = {};
            
            for i = 1:length(obj.DataStorage)
                Offset = obj.DataStorage{i}.Delay.*1E9;
                curr_size = length(obj.PDVData.VelTime);
                save_data = [];
                save_data(1:max_vector_size,1:2) = NaN;
                hdr1 = [hdr1,'Time','Velocity'];
                hdr2 = [hdr2,'ns','km/s'];
                hdr3 = [hdr3, obj.PDVData.fileNames{i},obj.PDVData.fileNames{i}];
                save_data(1:curr_size,:) = [obj.DataStorage{i}.VelTime-Offset,obj.DataStorage{i}.Velocity];
                full_save{i} = save_data;
            end
        end

    end
    methods(Static)
                function [eFilt,cFilt] = ReadFilterData(txt)
                    fileID = fopen(txt);
                    textscan(fileID,'%s',19);
                    fspec = '[%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f]';
                    eFilt = ones(32,8);
                    cFilt = ones(32,5);
                    for i = 1:8
                        textscan(fileID,'%f',1);
                        tempMat = textscan(fileID,fspec,1);
                        tempMat = cell2mat(tempMat);
                        eFilt(:,i) = tempMat';
                    end

                    textscan(fileID,'%s',9);
                    for i = 1:5
                        textscan(fileID,'%f',1);
                        tempMat = textscan(fileID,fspec,1);
                        tempMat = cell2mat(tempMat);
                        cFilt(:,i) = tempMat';
                    end
                end
    
    end
end 