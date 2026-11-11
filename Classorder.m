function ResVec=Classorder(N,CT,EstimationError,Classes)
    ResVec = [CT EstimationError 0 0 0 0 0 N];
    vector = sort(Classes, 'descend');
    for i=1:length(vector)
        ResVec(i+2) = vector(i)*100;
    end    
end