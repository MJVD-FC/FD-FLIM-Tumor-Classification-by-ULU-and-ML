function [C, EstimationError] = ShowResult(method,N,Zh1,Z,Nx,Ny,analysisType,A1,W1,I,K,Zo,i,iter,j,P1,TitleDatabase,Diagnostic)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SHow Performance Metric and Plot Results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    EstimationError = norm(Zh1-Z,'fro')/norm(Z,'fro');
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp(['Unmixing with ' num2str(N) ' End-members']);
    disp(['Method: ' method]);
    
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    disp(['Estimation error = ' num2str(EstimationError)]);
    %
    A=[];
    C=zeros(Ny*Nx,1);
    Classes=zeros(1,N);
    EndMember=[];
    if analysisType ~= 2
        [~,C(I)]=max(A1,[],1);
    else
        [~,C(I)]=max(W1,[],1);
    end
    for ii=1:N
        Ao=zeros(Ny*Nx,1);
%         if iter~=1
%             Classes(ii)=sum(C==ii)/(K-nnz(C));
%         else
            Classes(ii)=sum(C==ii)/K;
%         end
        if analysisType ~= 2
            Ao(I)=A1(ii,:);
        else
            Ao(I)=W1(ii,:);
        end
        A=[A reshape(Ao,Ny,Nx) ones(Ny,5)];
        EndMember=[EndMember ' EM ' num2str(ii) ',  '];
    end 
    disp('Classification Percentages (%)');
    disp(EndMember)
    disp(100*Classes)
    
    legendP={}; legendPP=[];
    for ii=1:N, str=['' num2str(ii)]; legendP(ii)={str}; legendPP=[legendPP str ', ']; end
    
    titleL = TitleDatabase;
    diagnostics = num2str(Diagnostic);
    diagnosisLabels = '(TT), (NN), (NH), (NT)';
    Classes = round(Classes,2);

    f=figure;
    subplot(1,4,1);
    semilogy(P1,'-*','linewidth',0.5);
    xlabel('features'); grid on;
    ylabel('Norm amp'); title('EM'); legend(legendP);
    title({titleL(14:23), diagnosisLabels, diagnostics});
    subplot(1,4,2);
    imagesc(A,[0,1]);
    colorbar('southoutside');
    title({[method '-> A'], legendPP});
    subplot(1,4,3);
    imagesc(reshape(C,Ny,Nx),[0,N]);
    colorbar('southoutside');
    title({'Classification map', num2str(100*Classes)});
    orient('portrait')
    subplot(1,4,4);
    imagesc(reshape(sum(abs(Zo(1:21,:)),1),Ny,Nx))
    colorbar('southoutside');
    title('Avg Data');
    orient('portrait')



    if iter==1
        iterName = 'FirstIter';
        
    else
        iterName = 'LastIter';
    end
    
    
    RouteI = fullfile(appRoot, 'ImagesSegmentation');
    Rfile = ['Sample', num2str(i), method, '_', iterName, '_Ft', num2str(j), '.png'];
    file = fullfile(RouteI, Rfile);
    if ~exist(RouteI, 'dir') mkdir(RouteI); end
    exportgraphics(f, file, 'Resolution', 600)

    close(f)

end