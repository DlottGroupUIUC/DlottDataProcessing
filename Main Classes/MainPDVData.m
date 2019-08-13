classdef MainPDVData < handle
    %The main class that contains all types of PDV files (Either STFT or
    %fit peak data)
    properties(Access = private)
        mainFig;
        ScopeTime;
        ScopeVolt;
        TimingParams = Osc_Timing_Properties('PDVTimingParams.txt');
        %Window_Corrections = Window_Correction_Handle('WindowCorrectionDB.txt')
        %PeakFit_Data = PeakAlgData.empty;
        STFTWaveForm;
        handles; %data handle from main GUI data
        ProgBar;
        ProgText;
        Prog;
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
            obj.Prog=0; obj.ProgressBar(); T = length(obj.handles.fileNames);
            for i = 1:T
                [obj.ScopeTime{i},obj.ScopeVolt{i}] = obj.Readtxt(i);
                obj.Prog = i/T; obj.ProgressBar();
            end
            obj.STFTWaveForm = cell(5,1);
            obj.FillParams();

        end
        function PlotData(obj,idx)
            axes(obj.handles.WaveformAxis); hold off;
            for i = 1:4
                if i ==3
                    continue
                else
                    plot(obj.ScopeTime{idx},obj.ScopeVolt{idx}(:,i)); hold on;
                end
            end
            if ~isempty(obj.STFTWaveForm{idx})
                axes(obj.handles.LineoutAxis); hold off;
                T = obj.STFTWaveForm{idx}.VelTime;
                Vel = obj.STFTWaveForm{idx}.Velocity;
                for i = 1:length(Vel(1,:))
                    plot(T,Vel(:,i)); hold on;
                end
            end
        end
        function Transform(obj,idx)
            ProgHandles = {obj.handles.ProgressBar,obj.handles.InfoText};
            obj.STFTWaveForm{idx} = STFTData(obj.ScopeTime{idx},obj.ScopeVolt{idx},0.25,obj.TimingParams,ProgHandles);
            obj.PlotData(idx);
        end
    end
    methods(Access = private)
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
            ScopeTime = ScopeTime.*1E9;
            
        end
        function ProgressBar(obj)
            DisplayStatus(obj.ProgBar,obj.ProgText,obj.Prog)
        end
        function FillParams(obj)
            set(obj.handles.Time0Text,'String',obj.TimingParams.TrigOffset);
            set(obj.handles.Time0Text,'Enable','Off');
        end
    end
        
end