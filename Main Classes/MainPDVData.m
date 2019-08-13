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
            obj.STFTWaveForm = cell(T,1);
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
            linkaxes([obj.handles.WaveformAxis,obj.handles.LineoutAxis],'x');
        end
        function Transform(obj,idx)
            ProgHandles = {obj.handles.ProgressBar,obj.handles.InfoText};
            obj.STFTWaveForm{idx} = STFTData(obj.ScopeTime{idx},obj.ScopeVolt{idx},0.25,obj.TimingParams,ProgHandles);
            obj.PlotData(idx);
        end
        function Vel2Text()
            hdr1 = {}; hdr2 = {}; hdr3 = {};
            max_vector_size = [];
                for i=1:handles.file_count
                    max_vector_size(i) = length(handles.lineout_time{i});
                end
                max_vector_size = max(max_vector_size);
            full_save = {};
            for i = 1:handles.file_count
                curr_size = length(handles.lineout_time{i});
                save_data = [];
                save_data(1:max_vector_size,1:2) = NaN;
                hdr1 = [hdr1,'Time','Velocity'];
                hdr2 = [hdr2,'ns','km/s'];
                hdr3 = [hdr3, handles.fnames{i},handles.fnames{i}];
                save_data(1:curr_size,:) = [handles.lineout_time{i},handles.velocity{i}];
                full_save{i} = save_data;
            end
            if ~isempty(full_save)
                work_dir = pwd;
                cd(handles.fpath); filter = {'*.txt'};
                [save,save_path] = uiputfile(filter,'Save PDV file');
                if save_path ==0
                    cd(work_dir);
                    error('SaveFunc:CancelInput','Save Cancelled');
                end
                fmt = repmat('%s\t ', 1, length(hdr1));
                fmt(end:end+1) = '\n';
                %open save file and write headers
                fid = fopen(fullfile(save_path,save), 'w');
                fprintf(fid, fmt, hdr1{:});
                fprintf(fid,fmt, hdr2{:});
                fprintf(fid,fmt, hdr3{:});
                fclose(fid);
                %now insert data vector
                dlmwrite(fullfile(save_path,save),full_save,'-append','delimiter','\t');

                end
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