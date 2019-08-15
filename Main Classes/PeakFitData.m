classdef PeakFitData
   properties
       Velocity;
       VelTime;
       PeakVolt;
       
   end
   properties(Access = private)
       ScopeTime;
       ScopeVolt;
       Thresh
       TParams;
       ProgHandles;
       Prog;
   end
   methods
       function obj = PeakFitData(T,V,TParams,ProgHandles,Thresh)
           obj.ScopeTime = T;
           obj.ScopeVolt = V;
           obj.TParams = TParams;
           obj.ProgHandles = ProgHandles;
           obj.Thresh = Thresh;
           [obj.VelTime,obj.Velocity,obj.PeakVolt] = obj.PeakDet4();
       end
   end
   methods(Access = private)
       function [VelTime,Velocity,PeakVolt] = PeakDet4(obj)
           k = 1;
           x0 = 5000;
           ChList = obj.TParams.ChList;
           for j = 1:length(ChList)
                 i = ChList(j);
                 sAmp(:,k) = smooth(obj.ScopeVolt(:,i),5);
                 rMS(k) = obj.fRMS(obj.ScopeTime,obj.ScopeVolt(:,i));
                 [high{k},low{k}] = obj.peakdet(sAmp(x0-0.001*length(obj.ScopeTime):end,k),(rMS(k)*obj.Thresh),obj.ScopeTime(x0-0.001*length(obj.ScopeTime):end));
                 peakPositions{k} = sortrows([obj.ScopeTime(x0),obj.ScopeVolt(x0,i);high{k}(:,1),high{k}(:,2);low{k}(:,1),low{k}(:,2)]);
                 [sAmp_test] = obj.fSmoothData2(obj.ScopeTime,obj.ScopeVolt(:,i),peakPositions{k},0.1);
                 if length(sAmp_test) == length(obj.ScopeTime)
                    sAmp(:,k) = sAmp_test;
                 end
                 [high{k},low{k}] = obj.peakdet(sAmp(x0:end,k),(rMS(k)*obj.Thresh),obj.ScopeTime(x0:end));
                 peakPositions{k} = sortrows([obj.ScopeTime(x0),obj.ScopeVolt(x0,i);high{k}(:,1),high{k}(:,2);low{k}(:,1),low{k}(:,2)]);
                 %Call the fitting program that uses a third 2nd order polynomial to fit the
                 %data about each peak found above. This gives the most precise position for
                 %each max or min.
                 [high{k},low{k}] = obj.fFitPeaks(obj.ScopeTime,obj.ScopeVolt(:,i),high{k},low{k});
                 peakPositions{k} = sortrows([obj.ScopeTime(x0),obj.ScopeVolt(x0,i);high{k}(:,1),high{k}(:,2);low{k}(:,1),low{k}(:,2)]);
                 xyPeaks{k}=sortrows([obj.ScopeTime(x0),sAmp(x0,k);high{k}(:,1),high{k}(:,2);low{k}(:,1),low{k}(:,2)]);
                 idx_0 = length(xyPeaks{k}(xyPeaks{k}(:,1)<=obj.ScopeTime(x0),1));
                 velocity{k}=0.3875./diff(xyPeaks{k}(idx_0+1:end,1));
                 xPeaks{k}=xyPeaks{k}(idx_0+1:end,1);xPeaks{k}(length(velocity{k}))=[];
                 k = k+1;
          end 
                velocity0 = 0;
                XYMAT=sortrows([xPeaks{1},velocity{1};xPeaks{2},velocity{2};xPeaks{3},velocity{3};obj.ScopeTime(x0),velocity0]);
                velocityTime=XYMAT(:,1);
                velocity_final=XYMAT(:,2);
                x = smooth(velocity_final(3:end),3);
                velocity_final(3:end) = x;
                lineout_time = XYMAT(:,1);
                new_time = obj.ScopeTime-velocityTime(1,1);
                VelTime = lineout_time;
                Velocity = velocity_final;
                PeakVolt = xyPeaks;
                %{
            for k = 1:3
                peakPositions1{k}(:,1) = peakPositions{k}(:,1)-velocityTime(1,1);
                xPeaks{k} = xPeaks{k};
            end
                %}

            
               
       end
   end
   methods(Static)
       function [rMS] = fRMS(time,rVolts1)
            s=0;
            for i=1:(0.02*length(time))
                s=s+rVolts1(i,1)^2;
                i=i+1;
            end
            rMS=sqrt(s/(0.02*length(time)));
       end
       function [sVolts] = fSmoothData2(rTime,rVolts1,peakPositions,num)
            peakPositionsIndex = [];
            for i=1:length(peakPositions(:,1))
                peakIndex = find(rTime >= peakPositions(i,1),1,'first');
                peakPositionsIndex = [peakPositionsIndex;peakIndex];
            end

            indexDifference = [peakPositionsIndex(1);diff(peakPositionsIndex)];


            sVolts = smooth(rVolts1(1:peakPositionsIndex(1)),(indexDifference(1)*num));

            smoothDistance = round((indexDifference(2)*num));
            z = 2;

            while smoothDistance<1
                smoothDistance = round((indexDifference(z+1)*num));
                z = z+1;
            end

            for i = 2:(length(peakPositions(:,1))-10)
                if round((indexDifference(i)*num)) > (1+1/4)*smoothDistance
                    smoothDistance = round((1+1/4)*smoothDistance);
                elseif round((indexDifference(i)*num)) < (1-1/4)*smoothDistance
                    smoothDistance = round((1-1/4)*smoothDistance);
                else
                    smoothDistance = round((indexDifference(i)*num));
                end
                if i==length(peakPositions(:,1))
                    disp('here')
                end
                test = smooth(rVolts1((peakPositionsIndex(i-1)-smoothDistance):(peakPositionsIndex(i)+smoothDistance)),smoothDistance);
                sVolts = [sVolts;test(smoothDistance+1:end-smoothDistance-1)];
            end
            test = smooth(rVolts1((peakPositionsIndex(end)+1)-100:end),(50));
            sVolts = [sVolts;test(101:end)];
       end


            %%
       function [newHigh,newLow] = fFitPeaks(xData,yData,high,low)
            %Title: findPeaks
            %Author: Gino Giannetti & William Shaw

            %Date: 2014-6-10
            %Updated 2014-12-31

            %Purpose: find maximums and minimums of input data more accurately than
            %         peakdet method using curve fitting. For use in shock compression data.
            %         Note-uses peakdet in the process (Removed dependency 2014-12-31)

            %Input: high and low are previous max and min arrays found by peakdet. 
            %       xData and yData are the raw x and y data 
            %       indFirstMove is the index in the x and y data where the object in
            %       question first moves

            %Output: new maximum and minimum arrays of the data

            % Setting up while loop

            oldPeaks = sortrows([high(:,1),high(:,2);low(:,1),low(:,2)]);
            newHigh = [];
            newLow = [];
            a=0;
            b=0;
            k=1;

            warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
            while (k <= (length(oldPeaks(:,1))))

            % Finding section to curve fit
                switch k
                    case 1
                        a = ((oldPeaks(k,1)-oldPeaks(k+1,1)))/2 + oldPeaks(k,1);
                        b = ((oldPeaks(k+1,1)-oldPeaks(k,1)))/2 + oldPeaks(k,1); 
                    case length(oldPeaks(:,1))
                        a = ((oldPeaks(k,1)-oldPeaks(k-1,1)))/2 + oldPeaks(k-1,1);
                        b = ((oldPeaks(k,1)-oldPeaks(k-1,1)))/2 + oldPeaks(k,1);
                    otherwise
                        a = ((oldPeaks(k,1)-oldPeaks(k-1,1)))/2 + oldPeaks(k-1,1);
                        b = ((oldPeaks(k+1,1)-oldPeaks(k,1)))/2 + oldPeaks(k,1);

                end

                c=length(xData(xData<=a));
                d=length(xData(xData<=b));

                if c<0
                    c=1;
                end

                if(isempty(c) || isempty(d))
                    display('peak could not be found');
                end

                if c > length(xData) || d > length(xData)
                    k=k+1;
                else
                    xTemp = xData((c):(d));
                    yTemp = yData((c):(d));

                    % curve fitting polynomial 
                    p = polyfit(xTemp,yTemp,2);
                    peakPosition = -p(2)./(p(1)*2);
                    if peakPosition > xData(end)
                        peakIndex = 1;
                    else
                        peakIndex = find(xData >= peakPosition,1,'first');
                    end

                    % Don't allow peak positions to change by more than 1 ns
                    positionChange = peakPosition-oldPeaks(k,1);
                    if abs(positionChange) < 1
                        Temp = [peakPosition,yData(peakIndex)];
                    else
                        Temp = [oldPeaks(k,1), oldPeaks(k,2)];
                    end

                    %Assign high or low value.
                    if (p(1)<=0)
                        newHigh = [newHigh;Temp];
                    else 
                    newLow = [newLow;Temp];
                    end

                    k=k+1;
                end
            end
            warning('on','MATLAB:polyfit:RepeatedPointsOrRescale');
       end

            %% Peak determining routine
       function [maxtab, mintab]=peakdet(v, delta, x)
            %PEAKDET Detect peaks in a vector
            %        [MAXTAB, MINTAB] = PEAKDET(V, DELTA) finds the local
            %        maxima and minima ("peaks") in the vector V.
            %        MAXTAB and MINTAB consists of two columns. Column 1
            %        contains indices in V, and column 2 the found values.
            %      
            %        With [MAXTAB, MINTAB] = PEAKDET(V, DELTA, X) the indices
            %        in MAXTAB and MINTAB are replaced with the corresponding
            %        X-values.
            %
            %        A point is considered a maximum peak if it has the maximal
            %        value, and was preceded (to the left) by a value lower by
            %        DELTA.

            % Eli Billauer, 3.4.05 (Explicitly not copyrighted).
            % This function is released to the public domain; Any use is allowed.

            maxtab = [];
            mintab = [];

            v = v(:); % Just in case this wasn't a proper vector

            if nargin < 3
              x = (1:length(v))';
            else 
              x = x(:);
              if length(v)~= length(x)
                error('Input vectors v and x must have same length');
              end
            end

            if (length(delta(:)))>1
              error('Input argument DELTA must be a scalar');
            end

            if delta <= 0
              error('Input argument DELTA must be positive');
            end

            mn = Inf; mx = -Inf;
            mnpos = NaN; mxpos = NaN;

            lookformax = 1;

            for i=1:length(v)
              this = v(i);
              if this > mx, mx = this; mxpos = x(i); end
              if this < mn, mn = this; mnpos = x(i); end

              if lookformax
                if this < mx-delta
                  maxtab = [maxtab ; mxpos mx];
                  mn = this; mnpos = x(i);
                  lookformax = 0;
                end  
              else
                if this > mn+delta
                  mintab = [mintab ; mnpos mn];
                  mx = this; mxpos = x(i);
                  lookformax = 1;
                end
              end
            end
       end
   end
end
       