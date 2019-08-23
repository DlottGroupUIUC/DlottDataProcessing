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
        function BinPMTData(obj,idx)
            if isempty(obj.UnitConv)
                obj.Calibrate();
            end
            rawFile = convertTDMS(0,fullfile(obj.filePath,obj.fileNames{idx}));
            %grab parameters to make individual datafile measurement
            cFiltidx = get(obj.handles.calFiltList,'Value');
            eFiltidx = get(obj.handles.expFiltList,'Value');
            FileData = struct;
            FileData.Data = rawFile.Data.MeasuredData;
            FileData.eFilt = obj.eFilter(:,eFiltidx);FileData.cFilt = obj.cFilter(:,cFiltidx);
            FileData.binRes = str2double(get(obj.handles.binRes,'String'));
            FileData.binStart = str2double(get(obj.handles.binStart,'String'));
            FileData.binEnd = str2double(get(obj.handles.binEnd,'String'));
            FileData.UnitConv = obj.UnitConv;
            obj.DataStorage{idx} = PMTData(FileData);
            obj.RadianceSemiLogPlot(idx);
        end
        
        function RadiancePlot(obj,idx)
            axes(obj.handles.RadAxis);
            time = obj.DataStorage{idx}.BinData(:,1);
            volt = obj.DataStorage{idx}.BinData(:,3);
            plot(time,volt); xlim([0,5E-7]);
        end
        function RadianceSemiLogPlot(obj,idx)
            axes(obj.handles.RadAxis);
            time = obj.DataStorage{idx}.BinData(:,1);
            volt = obj.DataStorage{idx}.BinData(:,3);
            semilogx(time,volt); xlim([1E-9,5E-7]);
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
        function [delay] = FindPeakDelay(obj)
            %Function finds when delay should be applied, based on Ch. 20
            Target = str2double(get(obj.handles.delayTarget,'String'));
            Thresh = str2double(get(obj.handles.ThreshEdit));
            Time = obj.Scopetime;
            Volt = obj.ScopeVolt(:,20); Volt = Volt(Time<1e-7);
            rms = sqrt(meaq(Volt(1:250).^2));
            [~,locs] = findpeaks(Volt,'MinPeakHeight',Thresh*rms,...
                'MinPeakDistance',50E-9);
            [~, maxLoc] = max(Volt(locs(1:5)));
            delay = Time(maxLoc)-Target;
            
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