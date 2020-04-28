%Create stitched temperature map with 2 separate color images:
classdef PyroFrame < handle
    properties
        RedFrame %Undoctored image of Red filter
        BlueFrame %Undoctored image of Blue filter
        Lambda;
        Temperature;
    end
    properties(Access = private)
        h = 6.63E-34; %m2kg/s
        c = 3.0E8; %m/s
        k = 1.38E-23; %m2kg/s2K
        %manual constants
        Temp0 = 6000; %K
        Emissivity0 = 0.5;
        PhiB;
        PhiR;
        Rfilt;
        Bfilt;
    end
    methods
        function obj = PyroFrame(Im_R,Im_B)
            fR = open(Im_R);
            obj.RedFrame = getimage(fR);
            obj.RedFrame = circshift(obj.RedFrame,[0,-100]);
            close(fR);
            fB = open(Im_B);
            obj.BlueFrame = getimage(fB);
            [obj.Rfilt,obj.Bfilt,obj.Lambda] = obj.FetchFilter();
            obj.Temperature = linspace(1500,6000,1000);
        end
        function TempImage = GetTemperature(obj)
            %derive constants
            C1 = 2*obj.h*obj.c^2;
            C2 = obj.h*obj.c/obj.k;
            S0R = trapz(obj.Lambda,obj.Emissivity0.*C1.*obj.Rfilt.*exp(-C2./(obj.Lambda.*obj.Temp0))./(obj.Lambda).^5); %before integration: camera responsefunction * filter tansmission function * graybody spectral radience
            %S0R = trapz(obj.Lambda,rflR); %integration
            S0B = trapz(obj.Lambda,obj.Emissivity0.*C1.*obj.Bfilt.*exp(-C2./(obj.Lambda.*obj.Temp0))./(obj.Lambda).^5); %before integration: camera responsefunction * filter tansmission function * graybody spectral radience
            %S0B = trapz(obj.Lambda,rflB); %integration
            %calculate instrument constanct Phi
            obj.PhiR = max(max(obj.RedFrame))/S0R;%Phi of red camera.
            obj.PhiB = max(max(obj.BlueFrame))/S0B;%Phi of blue camera.
            tic %begin counting
            Ratio = @(T) trapz(obj.Lambda,obj.PhiB.*obj.Bfilt.*(obj.Lambda.^-5).*exp((-C2)./(obj.Lambda.*T)))...
                ./trapz(obj.Lambda,obj.PhiR.*obj.Rfilt.*(obj.Lambda.^-5).*exp((-C2)./(obj.Lambda.*T))); %anonymous function for ratio as a function of temp (Blue/Red)
            for i =1:length(obj.Temperature)
                L_Ratio(i) = Ratio(obj.Temperature(i)); %Populate a vector of ratio as a function of temp
            end
            V = (obj.PhiB.*obj.BlueFrame)./(obj.PhiR.*obj.RedFrame);
            
            V = V.*(max(L_Ratio))./(max(max(V)));
            for i = 1:length(V(:,1))
                for j = 1:length(V(1,:))
                    [~,idx] = min(abs(L_Ratio-V(i,j))); %find nearest neighbor term of each intensity to temperature
                    TempImage(i,j) = obj.Temperature(idx);
                end
            end
            toc %end counting
    end
    end
    methods(Access = private)
        function [Rfilt,Bfilt,Lambda] = FetchFilter(obj)
            C1 = 2*obj.h*obj.c^2;
            C2 = obj.h*obj.c/obj.k;
            camfilterR = 'NotchSPRedTubeQE.txt'; % this is the function for CameraResponse*notch*940SP*tubelens*redfilter
            data = readtable(camfilterR);%includes camera response function and filter transmission functions
            wavelength = data(:,1);%wavelength in nm
            Lambda = wavelength{:,:};%convert table to matrix
            Lambda = Lambda.*1E-9; %Convert to m
            RespTransR = data(:,2);
            Rfilt = RespTransR{:,:};
            camfilterB = 'NotchSPBlueTubeQE.txt';% this is the function for CameraResponse*notch*940SP*tubelens*bluefilter
            data = readtable(camfilterB);%includes camera response function and filters
            RespTransB = data(:,2);% first column is wavelength, should be same as the file for red color so don't repeat here
            Bfilt = RespTransB{:,:};

        end
    end
end