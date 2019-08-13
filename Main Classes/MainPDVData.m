classdef MainPDVData < handle
    %The main class that contains all types of PDV files (Either STFT or
    %fit peak data)
    properties(Access = private)
        mainFig;
        ScopeTime;
        ScopeVolt;
        Time_Params = Osc_Timing_Properties('PDVTimingParams.txt');
        %Window_Corrections = Window_Correction_Handle('WindowCorrectionDB.txt')
        %PeakFit_Data = PeakAlgData.empty;
        STFT_Data = STFTData.empty;
        handles; %data handle from main GUI data
        ProgBar;
        Progress;
    end
    properties(Access = protected)
    end
    methods
        function obj = MainPDVData(mainFig)
            %initialize
            obj.mainFig = mainFig;
            obj.handles = guidata(obj.mainFig);
            obj.ProgBar = obj.handles.ProgressBar;
            obj.ProgText = obj.handles.InfoText;
            obj.Prog=0; Progress(); T = length(obj.handles.fileNames);
            for i = 1:length(T)
                [obj.ScopeTime{i},obj.ScopeVolt{i}] = obj.Readtxt(i);
                obj.Prog = i/T; Progress();
            end

        end
        function PlotData(obj,idx)
            axes(obj.handles.WaveformAxis);
            plot(obj.ScopeTime{idx},obj.ScopeVolt{idx}(:,1))
        end
    end
    methods(Access = protected)
        function [ScopeTime,ScopeVolt] = Readtxt(obj,idx)
            name = obj.handles.fileNames{idx};
            name = strsplit(name,'Ch'); name = name{1};
            for i = 1:4
                channel_name=strcat(name,sprintf('Ch%d.txt',i));
                fid = fopen(fullfile(obj.handles.filePath,channel_name));
                textscan(fid,'%s',31);
                file = fscanf(fid,'%f',[2,1])';
                while ~feof(fid)
                    curr = fscanf(fid,'%f',[2,5000])';
                    if ~isempty(curr)
                        file = [file; curr];
                    end
                end 
                fclose(fid);
                if i==1
                    ScopeTime = file(:,1) + abs(file(1,1));
                end
                ScopeVolt(:,i) = file(:,2);
                clear file
            end
            function Progress(obj)
                Prog = obj.Prog;
                DisplayStatus(obj.ProgBar,obj.ProgText,Prog)
            end
    end
    end
        
end