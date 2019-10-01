classdef mainCMOScontroller < handle
    %Main CMOS data handle to control GUI and access data structures
    properties

    end
    properties(Access = private)
        handles %figure handle structure
        FigHandle;
        CMOSData;
        SelectedIndex;
    end
    methods
        function obj = mainCMOScontroller(FigHandle)
            obj.handles = guidata(FigHandle);
            obj.FigHandle = FigHandle;
        end
        function LoadSif(obj)
            obj.CMOSData = [];
            obj.CMOSData = SifFile(obj.handles); %Load and populate imagedata
            waitfor(obj.CMOSData.Initialized,'Value');
            obj.LoadRoutine();
        end
        function SelectImage(obj,idx)
            obj.SelectedIndex = idx; %write selected index to memory
            if ~isempty(obj.CMOSData.ExtractMatrix(idx))
                obj.ShowImage(idx)
            end
        end
        function Save2Tif(obj,varargin)
            idx = obj.SelectedIndex;
            if isempty(varargin)
                [Fpath] = uigetdir('Save Image Location');
            else
                [Fpath] = varargin{1};
            end
            filename = obj.CMOSData.FileNames{idx};
            filename = strsplit(filename,'.');
            Fname = filename{1}; Fname = sprintf('%s.tiff',Fname);
            [imMatrix,~,~] = obj.CMOSData.ExtractMatrix(idx);
            imMatrix = mat2gray(imMatrix,[0,3000]);
            imMatrix = uint16(round(imMatrix.*65535));
            t = Tiff(fullfile(Fpath,Fname),'w');
            tagstruct.ImageLength = size(imMatrix,1);
            tagstruct.ImageWidth = size(imMatrix,2);
            tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample = 16;
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Software = 'Matlab';
            setTag(t,tagstruct);
            write(t,imMatrix);
            close(t);
        end
        function Save2TifAll(obj)
            [Fpath] = uigetdir('Save Image Location');
            for i = 1:length(obj.CMOSData.FileNames)
                obj.SelectedIndex = i;
                obj.Save2Tif(Fpath);
            end
        end
    end
    methods(Access = private)
        function LoadRoutine(obj)
            Label = {'FileName'};
            data = obj.CMOSData.FileNames';
            set(obj.handles.FileTable,'Data',data);
            set(obj.handles.FileTable,'ColumnName',Label);
            obj.ShowImage(1);
        end
        function ShowImage(obj,idx)
            [imMatrix,~,~] = obj.CMOSData.ExtractMatrix(idx);
            axes(obj.handles.MainWindow);
            imagesc(imMatrix);set(obj.handles.TitleEdit,'String',obj.CMOSData.FileNames{idx});
            set(gca,'YTickLabel',[]);set(gca,'XTickLabel',[]);
            %load previous and next image
            if idx > 1
                axes(obj.handles.PreviousWindow);
                [Prev_imMatrix,~,~] = obj.CMOSData.ExtractMatrix(idx-1);
                imagesc(Prev_imMatrix);set(obj.handles.PrevFilename,'String',obj.CMOSData.FileNames{idx-1});
                set(gca,'YTickLabel',[]);set(gca,'XTickLabel',[]);
                set(gca,'YTick',[]);set(gca,'XTick',[]);
            else
                cla(obj.handles.PreviousWindow);
                set(obj.handles.PrevFilename,'String','');
            end
            if idx < length(obj.CMOSData.FileNames)
                axes(obj.handles.NextWindow);
                [Next_imMatrix,~,~] = obj.CMOSData.ExtractMatrix(idx+1);
                imagesc(Next_imMatrix);set(obj.handles.NextFilename,'String',obj.CMOSData.FileNames{idx+1});
                set(gca,'YTickLabel',[]);set(gca,'XTickLabel',[]);
                set(gca,'YTick',[]);set(gca,'XTick',[]);
            else
                cla(obj.handles.NextWindow);
                set(obj.handles.NextFilename,'String','');
            end
            [Gain,ExposureTime] = obj.CMOSData.FetchMetadata(idx);
            ExposureTime = round(str2double(ExposureTime)*100);
            set(obj.handles.GainEdit,'String',Gain);set(obj.handles.ExposureEdit,'String',ExposureTime);
        end
    end
end