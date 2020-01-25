function [AVG_Spec_Rad, AVG_Rad] = AVG_Data(Short_Radiance_Matrix)
%This version specifically for higher bin resolution data (i.e ~30).
%Load files to analyze

N = size(Short_Radiance_Matrix); N = N(3); %int number of files
for q=1:N
    
    data=Short_Radiance_Matrix(:,:,q); %pull individual matrix out
    
    while size(data,1)>134 %generalize for more binning params
        
        data(1,:)=[];
        
    end
        
    data_3d(:,:,q)=data;
end

time=data_3d(:,1,:);
t=permute(time,[1,3,2]);

AVG_Spec_Rad=mean(data_3d,3);
idxValid = ~isnan(AVG_Spec_Rad(2,:));
Corr_Spec_Rad = AVG_Spec_Rad(:,idxValid);
AVG_Rad = sum(Corr_Spec_Rad,2)*1e-9;