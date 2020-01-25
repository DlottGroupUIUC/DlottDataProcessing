classdef PMTData < handle
    %PMT data storage structure
    properties(Access = public)
        BinData
        binRad
        binGray;
        Tolerance = 90;
    end
    properties(Access = private)
        DataArray
        FileData
        Delay
        Wavelength=[444.690000000000,454.630000000000,464.250000000000,473.440000000000,483.560000000000,492.750000000000,500.810000000000,...
            509.500000000000,518.880000000000,529,539.940000000000,551.880000000000,561.500000000000,568.380000000000,575.560000000000,...
            583.130000000000,591.060000000000,599.440000000000,608.250000000000,617.500000000000,627.310000000000,637.750000000000,648.810000000000,...
            660.560000000000,673.060000000000,686.380000000000,700.630000000000,715.940000000000,732.380000000000,750.060000000000,769.190000000000,789.880000000000]';
    end
    methods
        function obj = PMTData(FileData,bool)
            obj.FileData = FileData;
            switch bool
                case 1 
                    obj.TDMSshort()
                case 0 
            end
        end
        function GrayBodyFit(obj)
            obj.binGray = obj.TempFit();
        end
    end
    methods(Access = public)
        function [lambda] = GetWavelength(obj)
            lambda = obj.Wavelength;
        end
        function [Ybb,T,eT,E,eE] = FetchBBFit(obj,idx)
            grayData = obj.TempFitAtTime(idx);
            Ybb = grayData.Ybb; T = grayData.Temp;
            eT = grayData.TempError; E = grayData.Emissivity;
            eE = grayData.EmissivityError;
            
        end
    end
methods(Access = private) 
        function TDMSshort( obj )
            %Isolate time and flip voltage
            Res = obj.FileData.binRes;
            Time = obj.FileData.Time;
            Volt = obj.FileData.Volt;
            ExcChannels = str2double(obj.FileData.ExcChannels);
            %Baseline correction from the data in negative time
                for w=1:32
                    baseline=mean(Volt([1:length(Time)*.04],w));
                    Volt_baseline_corrected(:,w)=Volt(:,w)-baseline;
                end
                
            filter=obj.FileData.cFilt'/obj.FileData.eFilt';

            %Correct for the 1 data point offset of card 1
            tempcell=mat2cell(Volt_baseline_corrected,length(Time),[4 28]);
            tempcell{1,1}=[zeros(1,4);tempcell{1,1}];
            tempcell{1,1}(end,:)=[];
            cTime=[tempcell{1,1} tempcell{1,2}];
            %Remove negative data
            vector=cTime(Time>0,:);
            TimeVector=Time(Time>0);
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
                    %{
                    if isempty(find(q == ExcChannels,1))
                        binSpecRad(q,:)=binSpecRad(q,:).*obj.FileData.UnitConv'./filter./50;
                    else
                    %}
                        %binSpecRad(q,:) = NaN;
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
                obj.BinData = zeros(128,33);
                obj.BinData(1:length(binTime),1)=binTime;
                obj.BinData(1:length(binTime),[2:33])=binSpecRad;
                %sift columns for excluded channels
                if ~isnan(ExcChannels)
                    for i = 2:length(obj.BinData(1,:))
                      if ~isempty(find(i-1==ExcChannels))
                          obj.BinData(:,i) = NaN(length(obj.BinData(:,1)),1); 
                          %populate column with NaN
                      end
                    end
                end
                %Total Radiance
                obj.binRad = NaN(128,1);
                obj.binRad(1:length(binTime)) = sum(binSpecRad,2)*1e-9;
                %Once binning is done clear full vectors from memory. It is
                %no longer needed
                obj.FileData.Time = [];obj.FileData.Volt = [];
                
        end
        function grayData = TempFit(obj)
            grayData = struct();
            Tstart = 1500;
            W = obj.Wavelength.*1E-9;
            R = obj.BinData(:,2:33);
            s = fitoptions('Method','NonlinearLeastSquares',... %fit method
               'Lower',[0,1500],...   %lower bound for emissivity and temp
               'Upper',[1,1e4],...    %upper bound for emissivity and temp
               'Startpoint',[0.1 Tstart]);   %Starting point
             bb=fittype('E*2*6.63e-34*3e8^2/wavelength^5/(exp((6.63e-34*3e8)/(wavelength*1.38e-23*T))-1)',...
                'independent',{'wavelength'},'coefficients',{'E','T'},'options',s);  %blackbody fitting model
            for k = 1:size(R,1)
                Rad = R(k,:)';
                idxValid = ~isnan(Rad);
                fitteddata=fit(W(idxValid),Rad(idxValid),bb);  %fit results
                fit_coeffs=coeffvalues(fitteddata);
                grayData.Emissivity(k)=fit_coeffs(1);
                grayData.Temp(k)=fit_coeffs(2);

                %Get 95% confidence interval
                conf=confint(fitteddata);
                grayData.EmissivityError(k)=conf(2,1)-grayData.Emissivity(k);
                grayData.TempError(k)=conf(2,2)-grayData.Temp(k);
            end
                Bounds = (1-obj.Tolerance/100);
                grayData.Emissivity(grayData.TempError>Bounds*grayData.Temp)=NaN;
                grayData.Temp(grayData.TempError>Bounds*grayData.Temp)=NaN;
        end
        function grayData = TempFitAtTime(obj,idx)
            grayData = struct();
            Tstart = 1500;
            W = obj.Wavelength.*1E-9;
            R = obj.BinData(idx,2:33); %spectrum at particular time
            s = fitoptions('Method','NonlinearLeastSquares',... %fit method
               'Lower',[0,1500],...   %lower bound for emissivity and temp
               'Upper',[1,1e4],...    %upper bound for emissivity and temp
               'Startpoint',[0.1 Tstart]);   %Starting point
             bb=fittype('E*2*6.63e-34*3e8^2/wavelength^5/(exp((6.63e-34*3e8)/(wavelength*1.38e-23*T))-1)',...
                'independent',{'wavelength'},'coefficients',{'E','T'},'options',s);  %blackbody fitting model
                Rad = R(:);
                idxValid = ~isnan(Rad);
                fitteddata=fit(W(idxValid),Rad(idxValid),bb);  %fit results

                Ybb = feval(fitteddata, W);
                grayData.Ybb = Ybb;
                fit_coeffs=coeffvalues(fitteddata);
                grayData.Emissivity=fit_coeffs(1);
                grayData.Temp=fit_coeffs(2);

                %Get 95% confidence interval
                conf=confint(fitteddata);
                grayData.EmissivityError=conf(2,1)-grayData.Emissivity;
                grayData.TempError=conf(2,2)-grayData.Temp;
            end
        end
end

