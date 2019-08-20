classdef MainPMTData < handle
    properties(Access = private)
        mainFig;
        cFilter;
        eFilter;
        handles;
        DataStorage;
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
            [obj.eFilter,obj.cFilter] = obj.ReadFilterData('EmissionFilterData.txt');
            T = length(obj.fileNames);
            obj.DataStorage = cell(T,1);
        end
        function BinPMTData(obj,idx)
            rawFile = convertTDMS(0,fullfile(obj.filePath,obj.fileNames{idx}));
            DataArray = rawFile.Data.MeasuredData;
            obj.DataStorage{idx} = PMTData(DataArray);
            obj.RadiancePlot(idx);
        end
        function RadiancePlot(obj,idx)
            axes(obj.handles.RadAxis);
            time = obj.DataStorage{idx}.Time;
            volt = obj.DataStorage{idx}.Volt;
            plot(time,volt); xlim([0,5E-7]);
        end
    end
    methods(Access = private)
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