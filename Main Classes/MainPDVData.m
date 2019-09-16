classdef MainPDVData < handle
    %The main class that contains all types of PDV files (Either STFT or
    %fit peak data)
    properties(Access = private)
        mainFig;
        ScopeTime;
        ScopeVolt;
        TimingParams = Osc_Timing_Properties('PDVTimingParams.txt');
        Toffset
        WindowCorrections 
        
        DataStorage; %Cell array with all derived results
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
            obj.WindowCorrections = obj.WindowCorrectionDB('WindowCorrectionDB.txt');
            obj.Prog=0; obj.ProgressBar(); T = length(obj.handles.fileNames);
            for i = 1:T
                [obj.ScopeTime{i},obj.ScopeVolt{i},obj.Toffset{i}] = obj.Readtxt(i);
                obj.Prog = i/T; obj.ProgressBar();
            end
            obj.DataStorage = cell(T,1);
            obj.FillParams();

        end
        function PlotData(obj,idx)
            axes(obj.handles.WaveformAxis); hold off;
            if ~isempty(obj.DataStorage{idx})
                switch(get(obj.handles.T0Switch,'Value'))
                    case 0
                        Offset = 0;
                    case 1
                        Offset = obj.DataStorage{idx}.T0;
                end
            else
                Offset = 0;
            end
            for i = 1:4
                if i ==3
                    continue
                else
                    plot(obj.ScopeTime{idx}-Offset,obj.ScopeVolt{idx}(:,i)); hold on;
                end
                legend('Ch. 1','Ch. 2','Ch. 4');
            end
            if ~isempty(obj.DataStorage{idx})
                axes(obj.handles.LineoutAxis); hold off;
                T = obj.DataStorage{idx}.VelTime;
                Vel = obj.DataStorage{idx}.Velocity;
                Names = get(obj.handles.FileList,'String');
                Name = Names{idx};
                
                for i = 1:length(Vel(1,:))
                    plot(T-Offset,Vel(:,i),'b.'); hold on;
                end
                title(Name);
                if strcmp(class(obj.DataStorage{idx}),'PeakFitData')
                    axes(obj.handles.WaveformAxis);
                    for i = 1:length(obj.TimingParams.ChList)
                        PeakVolt = obj.DataStorage{idx}.PeakVolt{i};
                        scatter(PeakVolt(:,1)-Offset,PeakVolt(:,2),50,'LineWidth',2);
                    end
                    legend('Ch. 1','Ch. 2','Ch. 4','Ch. 1 Pk','Ch. 2 Pk','Ch. 4 Pk');
                    
                end
            end
            %%Set up axis limits based on user input, if applicable
            xi = str2double(get(obj.handles.xiEdit,'String')); xf = str2double(get(obj.handles.xfEdit,'String'));
            xlim([xi,xf])
            linkaxes([obj.handles.WaveformAxis,obj.handles.LineoutAxis],'x');
        end
        function PlotSingleChannel(obj,idx)
            switch get(obj.handles.ChannelList,'Value')
                case 1
                    k = 1; j = 1;
                case 2
                    k = 2; j = 2;
                case 3
                    k = 3; j = 4;
            end
            axes(obj.handles.WaveformAxis); hold off;
            plot(obj.ScopeTime{idx},obj.ScopeVolt{idx}(:,j)); hold on;
            xi = str2double(get(obj.handles.xiEdit,'String')); xf = str2double(get(obj.handles.xfEdit,'String'));
            PeakVolt = obj.DataStorage{idx}.PeakVolt{k};
            plot(PeakVolt(:,1),PeakVolt(:,2),'o');
            xlim([xi,xf]);
            linkaxes([obj.handles.WaveformAxis,obj.handles.LineoutAxis],'x');
        end
        function AddPeak(obj)
            idx = get(obj.handles.FileList,'Value');
            obj.PlotSingleChannel(idx);
            [Xnew,~] = ginput(1);
            obj.DataStorage{idx}.AddPeak(Xnew,get(obj.handles.ChannelList,'Value'));
            obj.PlotData(idx);
            
        end
        function DeletePeak(obj)
            idx = get(obj.handles.FileList,'Value');
            obj.PlotSingleChannel(idx);
            [Xdel,~] = ginput(1);
            obj.DataStorage{idx}.DeletePeak(Xdel,get(obj.handles.ChannelList,'Value'));
            obj.PlotData(idx);
            
        end
        function Transform(obj,idx)
            ProgHandles = {obj.handles.ProgressBar,obj.handles.InfoText};
            STFTParams = {str2double(get(obj.handles.CutoffEdit,'String')),str2double(get(obj.handles.TransWindowEdit,'String')),obj.Toffset{idx}};
            obj.DataStorage{idx} = STFTData(obj.ScopeTime{idx},obj.ScopeVolt{idx},STFTParams,obj.TimingParams,ProgHandles);
            obj.ApplyWindowCorrection(idx);
            obj.PlotData(idx);
        end
        function PeakAlg(obj,idx)
            ProgHandles = {obj.handles.ProgressBar,obj.handles.InfoText};
            Thresh = str2double(get(obj.handles.ThreshEdit,'String'));
            obj.DataStorage{idx} = PeakFitData(obj.ScopeTime{idx},obj.ScopeVolt{idx},obj.TimingParams,ProgHandles,Thresh);
            obj.ApplyWindowCorrection(idx);
            obj.PlotData(idx);
        end
            
        function Vel2Text(obj)
            hdr1 = {}; hdr2 = {}; hdr3 = {};
            max_vector_size = [];
                for i=1:length(obj.DataStorage)
                    max_vector_size(i) = length(obj.DataStorage{i}.VelTime);
                end
                max_vector_size = max(max_vector_size);
            full_save = {};
            for i = 1:length(obj.DataStorage)
                curr_size = length(obj.DataStorage{i}.VelTime);
                save_data = [];
                save_data(1:max_vector_size,1:2) = NaN;
                hdr1 = [hdr1,'Time','Velocity'];
                hdr2 = [hdr2,'ns','km/s'];
                hdr3 = [hdr3, obj.handles.fileNames{i},obj.handles.fileNames{i}];
                save_data(1:curr_size,:) = [obj.DataStorage{i}.VelTime,obj.DataStorage{i}.Velocity];
                full_save{i} = save_data;
            end
            if ~isempty(full_save)
                work_dir = pwd;
                cd(obj.handles.filePath); filter = {'*.txt'};
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
                cd(work_dir);
                end
        end
        function ChangeWCFText(obj)
            Material = get(obj.handles.WindowCorrectionList,'String');
            Material = Material{get(obj.handles.WindowCorrectionList,'Value')};
            WCF = obj.WindowCorrections.(Material);
           set(obj.handles.WCFText,'String',WCF)
        end
        function AverageSelected(obj)
            FileList = get(obj.handles.FileList,'Value');
            [maxSize,maxidx] = obj.MaxDataSize(FileList);
            TimeMatrix(:,1) = obj.DataStorage{maxidx}.VelTime;
            DataMatrix = [];
            for i = 1:length(FileList)
                idx = FileList(i);
                DataMatrix(:,i) = resample(obj.DataStorage{idx}.Velocity,maxSize,length(obj.DataStorage{idx}.VelTime));
            end
            AvgMat = mean(DataMatrix,2);
            obj.DataStorage{end+1} = struct();
            %PLACEHOLDER CODE!!!
            obj.ScopeTime{end+1} = obj.ScopeTime{end};
            obj.ScopeVolt{end+1} = obj.ScopeVolt{end};
            %%
            obj.DataStorage{end}.Velocity = AvgMat;
            obj.DataStorage{end}.VelTime = TimeMatrix;
            obj.DataStorage{end}.T0 = obj.AvgT0(FileList);
            idx = length(obj.DataStorage);
            obj.handles.fileNames = [obj.handles.fileNames, {'AvgCalc'}];
            set(obj.handles.FileList,'String',obj.handles.fileNames');
            obj.PlotAvg(idx);
        end
    end
    methods(Access = private)
        function PlotAvg(obj,idx)
            
            axes(obj.handles.LineoutAxis); hold off;
            T = obj.DataStorage{idx}.VelTime;
            Vel = obj.DataStorage{idx}.Velocity;
                for i = 1:length(Vel(1,:))
                    plot(T,Vel(:,i),'r.'); hold on;
                end
        end
        function [ScopeTime,ScopeVolt,Toffset] = Readtxt(obj,idx)
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
            [maximum, maximum_index] = max(ScopeVolt(:,3));
            time_vector = ScopeTime(1:maximum_index);
            index90 = length(time_vector(time_vector<=maximum*0.9));
            time90 = ScopeTime(index90).*1e9;
            scope_offset = obj.TimingParams.TrigOffset;
            time_offset = -time90 + scope_offset;
            ScopeTime = ScopeTime.*1e9 + time_offset;
            Toffset = time_offset;

        end
        function ProgressBar(obj)
            DisplayStatus(obj.ProgBar,obj.ProgText,obj.Prog)
        end
        function FillParams(obj)
            set(obj.handles.Time0Text,'String',obj.TimingParams.TrigOffset);
            set(obj.handles.Time0Text2,'String',obj.TimingParams.TrigOffset);
            set(obj.handles.Time0Text,'Enable','Off');
            set(obj.handles.Time0Text2,'Enable','Off');
        end
        function ApplyWindowCorrection(obj,idx)
            Material = get(obj.handles.WindowCorrectionList,'String');
            Material = Material{get(obj.handles.WindowCorrectionList,'Value')};
            WCF = obj.WindowCorrections.(Material);
            obj.DataStorage{idx}.Velocity = obj.DataStorage{idx}.Velocity./WCF;
        end
        function [maxSize,maxidx] = MaxDataSize(obj,idx_list)
            %find max size of selected datastorage objects
            maxSize = 0;maxidx = 0;
            for i = 1:length(idx_list)
                k = idx_list(i);
                if length(obj.DataStorage{k}.Velocity)>maxSize
                    maxSize = length(obj.DataStorage{k}.Velocity);
                    maxidx = k;
                end
            end
        end
        function [AvgT0] = AvgT0(obj,idx_list)
            T0Mat = [];
            for i = 1:length(idx_list)
                k = idx_list(i);
                T0Mat(i) = obj.DataStorage{k}.T0;
            end
            AvgT0 = mean(T0Mat);
        end
            
    end
    methods(Static)
        function WindowDB = WindowCorrectionDB(txt)
            fileID = fopen(txt);
            textscan(fileID,'%s',34);
            WindowDB = struct(); 
            while ~feof(fileID)
                try
                    Name = textscan(fileID,'%s',1);
                    Name = Name{1}{1};
                    Val = textscan(fileID,'%f',1);
                    WindowDB.(Name) = Val{1};
                catch
                end
            end
            fclose(fileID);
        end
    end
        
        
end