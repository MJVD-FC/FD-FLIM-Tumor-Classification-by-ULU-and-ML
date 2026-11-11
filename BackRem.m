function [Results,P1Res,Zh1Res,A1Res] = BackRem(N,rho_pre,rho_seg,i,features,x_pixels,y_pixels,wavelengths,channels_445,channels_375,feature_data,analysisType1,analysisType2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [Results,P1Res] = TrainAndClass(i,j,features,x_pixels,y_pixels,wavelengths,channels_445,channels_375,feature_data)
% Algorithm to configure the EBEAE algorithms and apply them to the sample image
%
% Input Arguments
%
%  i --> Sample selected for analysis
%  features --> Selected feature vector
%  x_pixels --> Size of the FLIM images on x-axis
%  y_pixels --> Size of the FLIM images on y-axis
%  wavelengths --> The two different wavelengths used during the test
%  channels_445 --> Data channels gathered from the 445nm wavelength
%  channels_375 --> Data channels gathered from the 375nm wavelength
%  feature_data --> Random sample from the database to begin the tissue masking process
%
% Output Arguments
%
%  Results --> Classification results
%  P1Res --> End-member results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(fullfile(appRoot, 'Database'));
Ini = rho_pre; % Initial rho for background end-members estimation
Fini = rho_seg; % Final rho for tissue end-members estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code includes the comparison between three different variants 
% of the EBEAE algorithm
%
% analysisType = 0  --> Extended Blind End-Member and Abundance
% Extraction (EBEAE)
% analysisType = 1  --> EBEAE with Sparse Noise Component
% analysisType = 2  --> EBEAE with Total Variation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initial mask covering the entire FLIM image
refined_mask_closed = true(length(feature_data)); 

% Flag to determine which iteration of the algorithm we are executing
iter=1;
mark = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial mask (background remove)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop over the wavelengths and get data size
[TitleDatabase, Diagnostic] = GetTitle(i);
[data,~] = LoopOverWavelengths(features, TitleDatabase, refined_mask_closed, 1, mark, wavelengths, channels_375, channels_445, x_pixels, y_pixels,0);

[Ny,Nx,Nz]=size(data);
mask=refined_mask_closed;
maskV=reshape(mask,Ny*Nx,1);
Zo=reshape(data,Ny*Nx,Nz)';
I=find(maskV==1);
Z=Zo(:,I);
[~,K]=size(Z);


% Separate background and tissue
[P1,A1,~,Zh1,~,W1,~,~,method,~,~,~]=ComputeLinearUnmixing(Ny,Nx,analysisType1,N,Z,mask,I,K,Ini);
% Show results and save figure
[C,~] = ShowResult(method,N,Zh1,Z,Nx,Ny,analysisType1,A1,W1,I,K,Zo,i,iter,1,P1,TitleDatabase,Diagnostic);


[Results,A1,P1,Z] = SegFLIM(i,Fini,C,Ny,Nx,TitleDatabase,features,mark,wavelengths,channels_375,channels_445,x_pixels,y_pixels,P1,A1,analysisType2,iter,Diagnostic);

P1Res = P1;
Zh1Res = Z;
A1Res = A1;

end