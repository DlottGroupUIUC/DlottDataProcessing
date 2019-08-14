classdef STFTData
   properties
       ScopeTime;
       ScopeVolt;
       STFTParams;
       Velocity;
       VelTime;
       TParams;
       ProgHandles;
       Prog;
   end
   properties(Access = private)

   end
   methods
       function obj = STFTData(T,V,STFTParams,TParams,ProgHandles)
           obj.ScopeTime = T;
           obj.ScopeVolt = V;
           obj.TParams = TParams;
           obj.STFTParams = STFTParams;
           obj.ProgHandles = ProgHandles;
           [obj.VelTime,obj.Velocity] = obj.Transform();
       end
       function [VelTime,Velocity] = Transform(obj)
            SampleSpacing = obj.ScopeTime(2) - obj.ScopeTime(1);
            SampleFreq = (SampleSpacing*1E-9)^(-1);
            TimeWindow = obj.STFTParams{2};
            r = round(SampleFreq.*(TimeWindow*1E-9));
            SampleRate = 0.08;
            test = round(SampleRate/SampleSpacing);
            if test ==0
                test = 1;
            end
            obj.Prog = 0;
            for i = 1:4
                if i==3
                    continue
                end
                [STFT,f,t] = spectrogram(obj.ScopeVolt(:,i),hamming(r),r-test,10*r,SampleFreq);
                %%
                obj.Prog = (2*i)/12;
                obj.ProgressBar()
                %%
                if i == 1
                    STFT_tot = abs(STFT);
                else
                    STFT_tot = STFT_tot + abs(STFT);
                end
            end
            %%
            obj.Prog = 9/12; obj.ProgressBar();
            %%
            STFT_tot = STFT_tot./3;
            velocity_axis = f.*0.775./1e9;
            VelTime = (t*1e9)';
            %%
            obj.Prog = 10/12; obj.ProgressBar();
            %%
            Vcut = obj.STFTParams{1};
            if Vcut > 0
                filter = length(velocity_axis(velocity_axis<Vcut));
                STFT_tot(1:filter,:)=0;
                clear filter
            end
            [mx locs]=max(STFT_tot,[],1);
            velocity_lineout=velocity_axis(locs);
            obj.Prog = 11/12; obj.ProgressBar();
            % Fit the FFT at each time step to better resolve the velocity. I use a
            % polynomial since this is much, much less computationally expensive then a
            % gaussian fit. 
            velocity_lineout_fit = velocity_lineout;
            for i=1:length(velocity_lineout)
                if velocity_lineout(i) > 0.1 && (locs(i)+2)<length(velocity_axis)
                    p = polyfit(velocity_axis((locs(i)-2):(locs(i)+2)),STFT_tot((locs(i)-2):(locs(i)+2),i),2);
                    peakPosition = -p(2)./(p(1)*2);
                    velocity_lineout_fit(i) = peakPosition;
                else
                    velocity_lineout_fit(i) = 0;
                end
            end
            Velocity = velocity_lineout_fit;
            obj.Prog = 1; obj.ProgressBar();
            %{
            displacement = [];
            for i = 1:length(lineout_time)
                if lineout_time(i) < handles.time{n}(handles.t0{n})
                    displacement(i) = 0;
                elseif lineout_time(i) < handles.time{n}(minimum_index)&& lineout_time(i)>handles.time{n}(handles.t0{n})
                    displacement(i) = displacement(i-1)+trapz(lineout_time(i-1:i),velocity_lineout_fit(i-1:i));
                elseif lineout_time(i) > handles.time{n}(minimum_index)
                    displacement(i) = displacement(i-1)-trapz(lineout_time(i-1:i),velocity_lineout_fit(i-1:i));
                end
            end
            %}
            %{
            for i=1:length(lineout_time)
                if i==1
                    velocity_lineout_fit(i) = velocity_lineout_fit(i);
                elseif lineout_time(i)<time(minimum_index)
                    velocity_lineout_fit(i) = velocity_lineout_fit(i);
                else
                    velocity_lineout_fit(i) = -1*velocity_lineout_fit(i);
                end
            %}
       end
       function ProgressBar(obj)
            DisplayStatus(obj.ProgHandles{1},obj.ProgHandles{2},obj.Prog);
            drawnow;
        end
       end
end
       