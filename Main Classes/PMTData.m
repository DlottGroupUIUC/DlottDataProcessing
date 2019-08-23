classdef PMTData < handle
    %PMT data storage structure
    properties(Access = public)
        BinData
        binRad
    end
    properties(Access = private)
        DataArray
        FileData
        Time
        Delay
    end
    methods
        function obj = PMTData(FileData)
            obj.FileData = FileData;
            obj.DataArray = extractfield(FileData.Data,'Data');
            obj.DataArray = reshape(obj.DataArray,length(obj.DataArray)/33,33);
            obj.TDMSshort()
        end
    end
methods(Access = private) 
            function [delay] = FindPeakDelay(obj)
                %Function finds when delay should be applied, based on Ch. 20
                Volt = obj.DataArray(:,15);
                Volt = Volt(obj.Time<2E-6);
                Volt = Volt.*-1;
                Time = obj.Time(obj.Time<2E-6);
                rms = sqrt(mean(Volt(1:250).^2));
                [~,locs] = findpeaks(Volt,'MinPeakHeight',obj.FileData.Thresh*rms,...
                    'MinPeakDistance',50E-9);
                [~, maxLoc] = max(Volt(locs(1:5)));
                delay = Time(locs(maxLoc))-obj.FileData.Target*1E-9;
            end
        function TDMSshort( obj )
            %Isolate time and flip voltage
            obj.Time = obj.DataArray(:,5);
            Volt=obj.DataArray.*-1;
            Res = obj.FileData.binRes;
            %Baseline correction from the data in negative time
                for w=1:32
                    baseline=mean(Volt([1:length(obj.Time)*.04],w));
                    Volt_baseline_corrected(:,w)=Volt(:,w)-baseline;
                end
                
            filter=obj.FileData.cFilt'/obj.FileData.eFilt';

            %Correct for the 1 data point offset of card 1
            tempcell=mat2cell(Volt_baseline_corrected,length(obj.Time),[4 28]);
            tempcell{1,1}=[zeros(1,4);tempcell{1,1}];
            tempcell{1,1}(end,:)=[];
            cTime=[tempcell{1,1} tempcell{1,2}];
            obj.Delay = obj.FindPeakDelay();
            %Apply delays
            %Apply delay later
            %time=time-delay;
            obj.Time = obj.Time-obj.Delay;
            %Remove negative data
            vector=cTime(obj.Time>0,:);
            TimeVector=obj.Time(obj.Time>0);
            
            %Begin data binning at 10 ns
            binSpecRad=vector(find(TimeVector>0,1,'first'):find(TimeVector<1*10^obj.FileData.binStart,1,'last'),:);
            binTime=TimeVector(find(TimeVector>0,1,'first'):find(TimeVector<1*10^obj.FileData.binStart,1,'last'));

            %Generate time range for each iteration
            w=0;
            for dec=obj.FileData.binStart:obj.FileData.binEnd
                TimeRange(1+w*Res:(w+1)*Res)=logspace(dec,dec+1,Res);
                w=w+1;
            end

            %Kill time range beyond the limits of our data
            TimeRange=TimeRange(TimeRange<max(TimeVector));


            %Remove duplicates from the logtime generation
            switch abs(obj.FileData.binStart)-abs(obj.FileData.binEnd)
                case 6
            TimeRange(Res)=[];TimeRange(2*Res-1)=[];TimeRange(3*Res-2)=[];TimeRange(4*Res-3)=[];TimeRange(5*Res-4)=[];TimeRange(6*Res-5)=[];
                case 5
            TimeRange(Res)=[];TimeRange(2*Res-1)=[];TimeRange(3*Res-2)=[];TimeRange(4*Res-3)=[];TimeRange(5*Res-4)=[];
                case 4
            TimeRange(Res)=[];TimeRange(2*Res-1)=[];TimeRange(3*Res-2)=[];TimeRange(4*Res-3)=[];
                case 3
            TimeRange(Res)=[];TimeRange(2*Res-1)=[];TimeRange(3*Res-2)=[];
                case 2
            TimeRange(Res)=[];TimeRange(2*Res-1)=[];
            end

                %Generate vector of the indexes for binning ranges
                for logidx=1:length(TimeRange)
                    index_vector(logidx)=find(TimeVector>=TimeRange(logidx),1,'first');
                end

                %Generate temporary vector and build on output vectors
                for q=1:length(index_vector)-1
                    tempvector=vector(index_vector(q):index_vector(q+1),:);
                    binSpecRad(end+1,:)=mean(tempvector);
                    temptime=TimeVector(index_vector(q):index_vector(q+1));
                    binTime(end+1)=mean(temptime);
                end

                %Radiance calibration, filter, and voltage to amps conversions
                for q=1:size(binSpecRad,1)
                    binSpecRad(q,:)=binSpecRad(q,:).*obj.FileData.UnitConv'./filter./50;
                end
            %{
                if supressed_channels ~=0
            %Supress relevant channels
            binSpecRad(:,supressed_channels)=1e-9;
                end
                %}

                    %Remove very small data
                if binTime(1,1)<1e-9
                    binTime(1)=[];
                    binSpecRad(1,:)=[];
                end

                    %Condense output vectors
                obj.BinData(:,1)=binTime;
                obj.BinData(:,[2:33])=binSpecRad;
                %Total Radiance
                obj.binRad = sum(binSpecRad,2)*1e-9;
                
        end
end

end