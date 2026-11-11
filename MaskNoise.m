function [mask,Z,L,K,I,Ny,Nx,Nz,Zo] = MaskNoise(i,C,Ny,Nx,TitleDatabase,LocalFeatures,mark,wavelengths,channels_375,channels_445,x_pixels,y_pixels,P1,A1)

% Previous mask
Nmask=reshape(C,Ny,Nx);

Indicator = size(P1,2);

if Indicator == 3
    disp('--------------------------------------------MASK NOISE INDICATOR 3');
    MeanInt1 = mean(P1(1:7,1));
    MeanFt1 = mean(P1(22:end,1));
    MeanInt2 = mean(P1(1:7,2));
    MeanFt2 = mean(P1(22:end,2));
    
    markedEM = 0;
    if MeanInt1<0.1 && MeanFt1>0.02
        markedEM = 1;
    elseif MeanInt2<0.1 && MeanFt2>0.02
        markedEM = 2;
    else
        markedEM = 3;
    end
    
    MaxSum = 0;
    for ii=1:size(A1,1)
        if ii~=markedEM
            MaxTemp = sum(A1(ii,:));
            if MaxTemp>MaxSum
                MaxSum = MaxTemp;
            end
        end
    end
    
    if MaxSum == sum(A1(1,:))
        Class_Omit = 1;
    elseif MaxSum == sum(A1(2,:))
        Class_Omit = 2;
    else
        Class_Omit = 3;
    end
    
    for ii=1:size(Nmask,1)
        for jj=1:size(Nmask,2)
            if Nmask(ii,jj)~=Class_Omit || Nmask(ii,jj)==markedEM% ==1
                Nmask(ii,jj)=0;
            else
                Nmask(ii,jj)=1;
            end
        end
    end

else
    MeanInt1 = mean(P1(1:7,1));
    MeanInt2 = mean(P1(1:7,2));

    if MeanInt1>MeanInt2 
        Class_Omit = 1;
        Route= fullfile(appRoot, 'BackgroundData');                 
        Noisefile = ['BackgroundEndMember_', num2str(i), '.mat'];
        file = fullfile(Route, Noisefile);
        BGnoise = P1(:,2);
        if ~exist(Route, 'dir') mkdir(Route); end
        save(file,"BGnoise")
    else
        Class_Omit = 2;
        Route= fullfile(appRoot, 'BackgroundData');                
        Noisefile = ['BackgroundEndMember_', num2str(i), '.mat'];
        file = fullfile(Route, Noisefile);
        BGnoise = P1(:,1);
        if ~exist(Route, 'dir') mkdir(Route); end
        save(file,"BGnoise")
    end

    for ii=1:size(Nmask,1)
        for jj=1:size(Nmask,2)
            if Nmask(ii,jj)~=Class_Omit % ==1
                Nmask(ii,jj)=0;
            else
                Nmask(ii,jj)=1;
            end
        end
    end
end

refined_mask_closed = logical(Nmask);

% Apply morphological operations to refine the mask
se = strel('disk',8);
% binary_mask_closed = imerode(refined_mask_closed, se);
binary_mask_closed = imopen(refined_mask_closed, se);
refined_mask_closed = binary_mask_closed;

[data,dataBG] = LoopOverWavelengths(LocalFeatures, TitleDatabase, refined_mask_closed, 1, mark, wavelengths, channels_375, channels_445, x_pixels, y_pixels,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Omit the mask from the dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Ny,Nx,Nz]=size(data);
mask=refined_mask_closed;
maskV=reshape(mask,Ny*Nx,1);
Zo=reshape(data,Ny*Nx,Nz)';
I=find(maskV==1);
Z=Zo(:,I);
[L,K]=size(Z);

% Save background data for classification
Zo2=reshape(dataBG,Ny*Nx,Nz)';
IB=find(maskV==0);
ZB=Zo2(:,IB);

Route = fullfile(appRoot, 'BackgroundData');
Bfile = ['BackgroundData_', num2str(i), '.mat'];
fileB = fullfile(Route, Bfile);
if ~exist(Route, 'dir') mkdir(Route); end
save(fileB, "ZB")
