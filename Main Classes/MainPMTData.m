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
            obj.fileNames = obj.handles;
        end
    end
    methods(Access = private)
        function [binTime,binRad] = TDMS_Shorten()
            
        end
        function [EmissionFilterLibrary,CalFilterLibrary] = ReadFilterData(txt)
            fileID = fopen(sprintf(obj.fName));
            textscan(fileID,'%s',34);
            Offset = textscan(fileID,'%f',1);
            Offset = double(Offset{1});
            textscan(fileID,'%s',7);
            List = textscan(fileID,'%f,%f,%f',1);
            fclose(fileID);
        end
    end
    
end