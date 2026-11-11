function [Results,A1,P1,Z] = SegFLIM(i,Fini,C,Ny,Nx,TitleDatabase,features,mark,wavelengths,channels_375,channels_445,x_pixels,y_pixels,P1,A1,analysisType,iter,Diagnostic)                   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterative algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 3;
FlagCont = 0;

Results = []; % Classification results
P1Res = []; % End-member results
Zh1Res = []; % Features

% New mask for noise based on end-members
[mask,Z,~,K,I,Ny,Nx,~,Zo] = MaskNoise(i,C,Ny,Nx,TitleDatabase,features,mark,wavelengths,channels_375,channels_445,x_pixels,y_pixels,P1,A1);

ClassesStore = zeros(4);
iter=iter+1;

% First iteration with the new mask
[P1,A1,~,Zh1,~,W1,CT,~,method,~,Classes]=ComputeLinearUnmixing(Ny,Nx,analysisType,N,Z,mask,I,K,Fini);
ClassesStore(N-1,1:length(Classes)) = Classes;  
FlagCont=checkIter(Classes,iter-1,P1);
% Stop condition and show results
if FlagCont==1
    [P1,A1,~,Zh1,~,W1,~,~,method,~,Classes]=ComputeLinearUnmixing(Ny,Nx,analysisType,N-1,Z,mask,I,K,Fini);
    ClassesStore(N-2,1:length(Classes)) = Classes;
    [~,EstimationError] = ShowResult(method,N-1,Zh1,Z,Nx,Ny,analysisType,A1,W1,I,K,Zo,i,iter,1,P1,TitleDatabase,Diagnostic);
    Results=[Results; Classorder(N-1,CT,EstimationError,ClassesStore(N-2,:))];
else
    [~,EstimationError] = ShowResult(method,N,Zh1,Z,Nx,Ny,analysisType,A1,W1,I,K,Zo,i,iter,1,P1,TitleDatabase,Diagnostic);
    Results=[Results; Classorder(N-1,CT,EstimationError,ClassesStore(N-1,:))];
end

fprintf('Sample %d segmented\n', i);

%[~,~] = ShowResult(method,N,Zh1,Z,Nx,Ny,analysisType,A1,W1,I,K,Zo,i,iter,1,P1,TitleDatabase,Diagnostic);