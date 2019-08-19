classdef MainPMTData < handles
    properties(Access = private)
        mainFig;
    end
    properties(Access = public)
    end
    methods
        function obj = MainPMTData(mainFig)
            obj.mainFig = mainFig;
            obj.handles = guidata(obj.mainFig);
            obj.DataStorage = cell(T,1);
            obj.fileNames = obj.handles
        end
    end
    
end