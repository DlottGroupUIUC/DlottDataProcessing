classdef PMTData < handle
    %PMT data storage structure
    properties(Access = public)
        Time
        Volt
    end
    properties(Access = private)
        DataArray
    end
    methods
        function obj = PMTData(DataArray)
            obj.DataArray = DataArray;
            obj.Time = obj.DataArray(8).Data;
            obj.Volt = -obj.DataArray(3).Data;
        end
        
    end
    methods(Static)

        
    end
end