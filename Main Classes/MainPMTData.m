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
    end
    properties(Access = public)
        fileNames;
        filePath;
    end
    methods
        function obj = MainPMTData(mainFig)
            obj.mainFig = mainFig;
            obj.handles = guidata(obj.mainFig);
            obj.fileNames = obj.handles.PMTfileNames;
            obj.filePath = obj.handles.PMTfilePath;
            %Store Filter Matrix here, I didn't do it in the data object
            %because I don't want to keep opening and closing a text file
            %upon a data structure instance.
            [obj.eFilter,obj.cFilter] = obj.ReadFilterData('EmissionFilterData.txt'); 
            T = length(obj.fileNames);
            obj.DataStorage = cell(T,1);
        end
        function calcTemp(obj,idx)
            obj.DataStorage{idx}.Tolerance = str2double(get(obj.handles.ConfBound,'String'));
            obj.DataStorage{idx}.GrayBodyFit();
            obj.TempPlot(idx);
            obj.EmissivityPlot(idx);
        end
        function BinPMTData(obj,idx)
            if isempty(obj.UnitConv)
                obj.Calibrate();
            end
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
            FileData.Delay = obj.FindPeakDelay(Time,Volt);
            FileData.Time = Time - FileData.Delay;
            FileData.Volt = Volt;
            FileData.eFilt = obj.eFilter(:,eFiltidx);FileData.cFilt = obj.cFilter(:,cFiltidx);
            FileData.binRes = str2double(get(obj.handles.binRes,'String'));
            FileData.binStart = str2double(get(obj.handles.binStart,'String'));
            FileData.binEnd = str2double(get(obj.handles.binEnd,'String'));
            FileData.UnitConv = obj.UnitConv;
            FileData.binBool = ~(str2double(get(obj.handles.binRes,'String'))==0);
            obj.DataStorage{idx} = PMTData(FileData);
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
            semilogx(time,Radiance); xlim([1E-9,5E-7]);
            text = sprintf('Radiance Plot of %s',obj.handles.PMTfileNames{idx});
            title(text);
        end
            function TempPlot(obj,idx)
                axes(obj.handles.TempAxis); hold off;
                Temp = obj.DataStorage{idx}.binGray.Temp;
                TempError = obj.DataStorage{idx}.binGray.TempError;
                time = obj.DataStorage{idx}.BinData(:,1);
                semilogx(time,Temp,'o'); hold on; errorbar(time,Temp,TempError,'LineStyle','none','Color','b');
                xlim([1E-9,2E-6]); ylim([0,max(Temp)+500]);
                text = sprintf('Temp Plot of %s',obj.handles.PMTfileNames{idx});
                title(text);
            end
            function EmissivityPlot(obj,idx)
                axes(obj.handles.EmissivityAxis); hold off;
                Emissivity = obj.DataStorage{idx}.binGray.Emissivity;
                EmissivityError = obj.DataStorage{idx}.binGray.EmissivityError;
                time = obj.DataStorage{idx}.BinData(:,1);
                semilogx(time,Emissivity,'o'); hold on; errorbar(time,Emissivity,EmissivityError,'LineStyle','none','Color','b');
                xlim([1E-9,2E-6]); ylim([0,max(Emissivity)+0.1]);
                text = sprintf('Emissivity Plot of %s',obj.handles.PMTfileNames{idx});
                title(text);
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