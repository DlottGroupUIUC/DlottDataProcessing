classdef MainPDVData < handle
    %The main class that contains all types of PDV files (Either STFT or
    %fit peak data)
    properties(Access = private)
        mainFig;
        fileNames;
        Osc_Time;
        Osc_Voltage;
        Time_Params = Osc_Timing_Properties('PDVTimingParams.txt');
        Window_Corrections = Window_Correction_Handle('WindowCorrectionDB.txt')
        PeakFit_Data = PeakAlgData.empty;
        STFT_Data = STFTData.empty;
    end
    properties(Access = protected)
    end
    methods
        
        function obj = MainData(mainFig)
            %initialize
            obj.mainFig = mainFig;
        end
        
end