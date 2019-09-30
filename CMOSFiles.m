classdef CMOSFiles < handle
    %CMOS superclass, all CMOS file types share these methods
    properties
        FileNames
        FilePath
    end
    properties(Access = protected)
        CDelayVect %Camera delay value Vector, in ns
        FDelay %Flyer plate delay value, in ns
        ImageVector %Image tensor, (xval,yval,imageindex)
        handles %Mainfigure handle. Used to Acess and NOT write data from the UI.
    end
    methods 
        function obj = CMOSFiles(handles)
            obj.handles = handles;
        end
        function [imVector,FDelay,CDelay] = ExtractVector(idx)
            %extracts vector and relevant delays to give to controller
            %structure given an index.
            imVector = obj.ImageVector(:,:,idx);
            FDelay = obj.FDelay; CDelay = obj.CDelayVect(idx);
        end
    end
    
end