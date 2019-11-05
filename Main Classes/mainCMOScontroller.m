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
        function LoadB16(obj)
            obj.CMOSData = [];
            obj.CMOSData = CookeFiles(obj.handles);
            waitfor(obj.CMOSData.Initialized,'Value');
            obj.LoadRoutine();
        end
        function SelectImage(obj,idx)
            if any(idx)
                obj.SelectedIndex = idx; %write selected index to memory
            else
                idx = obj.SelectedIndex;
            end
            if ~isempty(obj.CMOSData.ExtractMatrix(idx))
                obj.ShowImage(idx)
            end
        end
        function SetDelay(obj)
            if ~isempty(obj.CMOSData)
                obj.CMOSData.UpdateFlyerLauch();
            end
            
        end
        function ChangeDelay(obj,idx)
            %Changes Camera Delay
            obj.CMOSData.ApplyDelay();
            obj.ShowImage(idx);
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
            [imMatrix,FDelay,CDelay] = obj.CMOSData.ExtractMatrix(idx);
            Imin = str2double(get(obj.handles.SaveIntensityZero,'String'));
            Imax = str2double(get(obj.handles.SaveIntensityMax,'String'));
            %cast to [0,1] grayscale digitization to impost intensity
            %scaling
            imMatrix = mat2gray(imMatrix,[Imin,Imax]);
            %recast to full 16 bit scale to save.
            imMatrix = obj.LabelImage(imMatrix,CDelay,FDelay,idx); %label image according to specifications
            imMatrix = uint16(round(imMatrix.*65535));
            t = Tiff(fullfile(Fpath,Fname),'w');
            tagstruct.ImageLength = size(imMatrix,1);
            tagstruct.ImageWidth = size(imMatrix,2);
            tagstruct.Photometric = Tiff.Photometric.RGB;
            tagstruct.BitsPerSample = 16;
            tagstruct.SamplesPerPixel = 3;
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
            Label = {'FileName','Camera Delay'};
            data = [obj.CMOSData.FileNames',string(zeros(length(obj.CMOSData.FileNames),1))];
            data = cellstr(data);
            set(obj.handles.FileTable,'Data',data);
            set(obj.handles.FileTable,'ColumnName',Label);
            obj.ShowImage(1);
        end
        function ShowImage(obj,idx)
            [imMatrix,FDelay,CDelay] = obj.CMOSData.ExtractMatrix(idx);
            Imin = str2double(get(obj.handles.SaveIntensityZero,'String'));
            Imax = str2double(get(obj.handles.SaveIntensityMax,'String'));
            ScaleStr = sprintf('Intensity 1 = %d Counts',Imax);
            set(obj.handles.ScaleEdit,'String',ScaleStr);
            imMatrix = mat2gray(imMatrix,[Imin,Imax]);
            imMatrix = obj.LabelImage(imMatrix,CDelay,FDelay,idx); %label image according to specifications
            axes(obj.handles.MainWindow);
            imshow(imMatrix);set(obj.handles.TitleEdit,'String',obj.CMOSData.FileNames{idx});
            set(gca,'YTickLabel',[]);set(gca,'XTickLabel',[]);
            colorbar
            %load previous and next image
            if idx > 1
                axes(obj.handles.PreviousWindow);
                [Prev_imMatrix,~,~] = obj.CMOSData.ExtractMatrix(idx-1);
                Prev_imMatrix = mat2gray(Prev_imMatrix,[Imin,Imax]);
                imshow(Prev_imMatrix);set(obj.handles.PrevFilename,'String',obj.CMOSData.FileNames{idx-1});
                set(gca,'YTickLabel',[]);set(gca,'XTickLabel',[]);
                set(gca,'YTick',[]);set(gca,'XTick',[]);
                colorbar
            else
                cla(obj.handles.PreviousWindow);
                set(obj.handles.PrevFilename,'String','');
            end
            if idx < length(obj.CMOSData.FileNames)
                axes(obj.handles.NextWindow);
                [Next_imMatrix,~,~] = obj.CMOSData.ExtractMatrix(idx+1);
                Next_imMatrix = mat2gray(Next_imMatrix,[Imin,Imax]);
                imshow(Next_imMatrix);set(obj.handles.NextFilename,'String',obj.CMOSData.FileNames{idx+1});
                set(gca,'YTickLabel',[]);set(gca,'XTickLabel',[]);
                set(gca,'YTick',[]);set(gca,'XTick',[]);
                colorbar;
            else
                cla(obj.handles.NextWindow);
                set(obj.handles.NextFilename,'String','');
            end
            [Gain,ExposureTime] = obj.CMOSData.FetchMetadata(idx);
            set(obj.handles.GainEdit,'String',Gain);set(obj.handles.ExposureEdit,'String',ExposureTime);
        end

        function NewImage = LabelImage(obj,Image,CDelay,FDelay,idx)
        [Gain,ExposureTime] = obj.CMOSData.FetchMetadata(idx);
            ExposureTime = round(str2double(ExposureTime)*100);
            Gain = str2double(Gain);
            if get(obj.handles.ParamLabel,'Value')
                switch class(obj.CMOSData)
                    case('SifFile')
                        DimMat = [1,2300];
                        ScalePos = [2200,50];
                        ScaleLength = 850; %px per 500 um
                        Font = 64;
                    case('CookeFiles')
                        DimMat = [1,1];
                        Font = 48;
                        Gain = 100; ExposureTime = 3;
                        ScalePos = [950,50];
                        ScaleLength = 240; %px per 500 um
                        
                end
                Imin = str2double(get(obj.handles.SaveIntensityZero,'String'));
                Imax = str2double(get(obj.handles.SaveIntensityMax,'String'));
                textLeft = sprintf('Scale = %d \n Gain = %d \n Exposure = %d ns',Imax,Gain,ExposureTime);
                Image1 = insertText(Image,DimMat,textLeft,'FontSize',Font,'BoxColor','blue','TextColor','white');
                Image1(ScalePos(1):ScalePos(1)+50, ScalePos(2):ScalePos(2) + ScaleLength,:) = [0.8];
                Image1 = insertText(Image1,[ScalePos(2),ScalePos(1)-100],'500 microns','FontSize',Font,'BoxColor','black','TextColor','white','BoxOpacity',0);
            else
                Image1 = Image;
            end
            if get(obj.handles.DelayLabel,'Value')
                switch class(obj.CMOSData)
                    case('SifFile')
                        DimMat = [1250,2350];
                        Font = 128;
                    case('CookeFiles')
                        DimMat = [750,1];
                        Font = 64;
                end
                delay = CDelay - FDelay;
                textRight = sprintf('Delay = %d ns',delay);
                NewImage = insertText(Image1,DimMat,textRight,'FontSize',Font,'BoxColor','blue','TextColor','white');
            else
                NewImage = Image1;
            end
        end
    end
end