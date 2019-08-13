classdef STFTData < MainPDVData
    properties(Access = private)
        sampleFreq = 2.5E10;
        handles
    end
    properties(Access = public)
        ScopeTime
        ScopeVolt
    end
    properties(Access = protected)
        Velocity
        TimeAxis
    end
    methods
        function obj = STFTData(handles)
            obj.handles = handles;
        end
        
    end
    methods(Access = protected)
        function Readtxt(obj,idx)
            [obj.ScopeTime,obj.ScopeVolt]=Readtxt@MainPDVData(obj,idx);
        end
    end
    
    
end