function [P1,A1,S1,Zh1,V1,W1,CT,PESN,method,EndMember,Classes,C]=ComputeLinearUnmixing(Ny,Nx,analysisType,N,Z,mask,I,K,rho)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % EBEAE Parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %rho=rho;                 % Weight on Regularization Term  >= 0   0.1
    lambda=0.1;              % Weight on Entropy of Abundances \in [0,1)    0.1
    epsilon=1e-3;            % Threshold for convergence
    maxiter=50;              % Maximum number of iteration in alternated least squares approach
    parallel=0;              % Parallelization in abundance estimation process
    display_iter=0;          % Display results of iterative optimization
    initcond=6;              % 6
    downsampling=0;
    lambdaTV=1e-4;
    lm=0.05;
    tau=0.1;
    nu=100;
    nRow=Ny;
    nCol=Nx;
    paramvec1=[initcond,rho,lambda,lm,epsilon,maxiter,downsampling,parallel,display_iter];
    paramvec2=[initcond,rho,lambda,epsilon,maxiter,downsampling,parallel,display_iter];
    paramvec3=[initcond,rho,lambdaTV,tau,nu,nRow,nCol,epsilon,maxiter,parallel,display_iter];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute Linear Unmixing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    tic;
    if analysisType==0
        [P1,A1,S1,Zh1]=EBEAE(Z, N,paramvec2);
        V1=0;
        W1=0;
        method='EBEAE';
    elseif analysisType==1
        [P1,A1,S1,Zh1,V1]=EBEAESN2(Z,N,paramvec1);
        W1=0;
        method='EBEAE-SN';
    elseif analysisType==2
        [P1,A1,W1,S1,Zh1]=EBEAETV_Mask(Z,N,paramvec3,mask);
        V1=0;
        method='EBEAE-TV';
    end
    TimeC=toc;
    
    % Results
    CT = TimeC;
    if analysisType==2
        PESN = num2str(norm(V1,'fro')/norm(Z,'fro'));
    else
        PESN =num2str(0);
    end
    
    A=[];
    C=zeros(Ny*Nx,1);
    Classes=zeros(1,N);
    EndMember=[];
    if analysisType ~= 2
        [~,C(I)]=max(A1,[],1);
    else
        [~,C(I)]=max(W1,[],1);
    end
    for i=1:N
        Ao=zeros(Ny*Nx,1);
        Classes(i)=sum(C==i)/K;
        if analysisType ~= 2
            Ao(I)=A1(i,:);
        else
            Ao(I)=W1(i,:);
        end
        A=[A reshape(Ao,Ny,Nx) ones(Ny,5)];
        EndMember=[EndMember ' EM ' num2str(i) ',  '];
    end 
end
