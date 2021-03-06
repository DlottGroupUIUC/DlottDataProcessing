classdef CMOSFiles < handle
    %CMOS superclass, all CMOS file types share these methods
    properties
        FileNames
        FilePath
        Initialized = 0;
        Cal10 %10X calibration (um/px)
        Cal4 %4X calibration (um/px)
    end
    properties(Access = protected)
        CDelayVect %Camera delay value Vector, in ns
        FDelay = 0; %Flyer plate delay value, in ns
        ImageMatrix %Image tensor, (xval,yval,imageindex)
        handles %Mainfigure handle. Used to Acess and NOT write data from the UI.
        Gain;
        ExposureTime; %Metadata available in certain image files, will default to NaN if not
    end
    methods 
        function obj = CMOSFiles(handles)
            obj.handles = handles;
            obj.UpdateFlyerLauch();
        end
        function [imMatrix,FDelay,CDelay] = ExtractMatrix(obj,idx)
            %extracts vector and relevant delays to give to controller
            %structure given an index.
            obj.ApplyDelay();
            imMatrix = obj.ImageMatrix(:,:,idx);
            FDelay = obj.FDelay;CDelay = obj.CDelayVect(idx);
            %FDelay = obj.FDelay; CDelay = obj.CDelayVect(idx);
        end
        function ApplyDelay(obj)
            CDelayVect = get(obj.handles.FileTable,'Data');
            CDelayVect = CDelayVect(:,2);
            obj.CDelayVect = str2double(string(CDelayVect));
        end
        function UpdateFlyerLauch(obj)
            obj.FDelay = str2double(get(obj.handles.FlyerLaunchEdit,'String'));
        end
        function [Gain,ExposureTime] = FetchMetadata(obj,idx)
            Gain = obj.Gain{idx};ExposureTime = obj.ExposureTime{idx};
        end

    end
    
end