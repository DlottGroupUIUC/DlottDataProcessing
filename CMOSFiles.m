classdef CMOSFiles < handle
    %CMOS superclass, all CMOS file types share these methods
    properties
        FileNames
        FilePath
        Initialized = 0;
    end
    properties(Access = protected)
        CDelayVect %Camera delay value Vector, in ns
        FDelay %Flyer plate delay value, in ns
        ImageMatrix %Image tensor, (xval,yval,imageindex)
        handles %Mainfigure handle. Used to Acess and NOT write data from the UI.
    end
    methods 
        function obj = CMOSFiles(handles)
            obj.handles = handles;
        end
        function [imMatrix,FDelay,CDelay] = ExtractMatrix(obj,idx)
            %extracts vector and relevant delays to give to controller
            %structure given an index.
            imMatrix = obj.ImageMatrix(:,:,idx);
            FDelay = 0;CDelay = 0;
            %FDelay = obj.FDelay; CDelay = obj.CDelayVect(idx);
        end
    end
    
end