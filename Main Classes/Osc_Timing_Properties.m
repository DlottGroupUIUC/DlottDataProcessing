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
           [obj.TrigOffset,obj.ChList] = obj.ReadTiming();
       end
       
   end
   methods (Access = private)
       function [Offset, List] = ReadTiming(obj)
           fileID = fopen(sprintf(obj.fName));
            textscan(fileID,'%s',34);
            Offset = textscan(fileID,'%f',1);
            Offset = double(Offset{1});
            textscan(fileID,'%s',7);
            List = textscan(fileID,'%f,%f,%f',1);
            List = [List{1}   List{2}    List{3}];
            fclose(fileID);
       end
   end
end