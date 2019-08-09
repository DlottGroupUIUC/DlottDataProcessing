classdef Osc_Timing_Properties < handle
    %Data structure for PDV timing parameters
   properties (Access = private)
       fName;
   end
   properties (Access = protected)
   end
   properties (Access = public)
       TrigOffset;
       ChList;
   end
   
   methods
       function obj = Osc_Timing_Properties(fName)
           obj.fName = fName;
           [obj.TrigOffset,obj.ChList] = ReadTiming(fName);
       end
       
   end
   methods (Access = private)
       function [Offset, List] = ReadTiming(fName)
           fileID = fopen('PDVTimingParams.txt');
            textscan(fileID,'%s',34)
            Offset = textscan(fileID,'%f',1);
            Offset = double(A{1});
            textscan(fileID,'%s',7);
            List = textscan(fileID,'%f,%f,%f',1);
            List = [B{1}   B{2}    B{3}];
            fclose(fileID);
       end
   end
end