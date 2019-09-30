classdef mainCMOScontroller < handle
    %Main CMOS data handle to control GUI and access data structures
    properties
        CMOSData
    end
    properties(Access = private)
        handles %figure handle structure
        
    end
    methods
        function obj = mainCMOSdata(FigHandle)
            obj.handles = guidata(FigHandle);
        end
        function LoadSif()
            obj.CMOSData = [];
            obj.CMOSData = SifFile(obj.handles);
        end
    end
end