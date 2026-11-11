function [EM1,EM2,EM3] = LabelPixelLevel(sample)
    
    load(fullfile(appRoot, 'PixelFeatures', ['PixelFeatures', num2str(sample), '.mat']))
    load(fullfile(appRoot, 'MaxAbundance', ['SegResMaxAbundance', num2str(sample), '.mat']))
    load(fullfile(appRoot, 'BackgroundData', ['BackgroundData_', num2str(sample), '.mat']))  
    
    % Assign each pixel to the end-member it corresponds to, through
    % the computed maximum abundance values
    [~, i_max] = max(Abundance, [], 1);
    
    Features = [];
    
    EM1 = [];
    EM2 = [];
    EM3 = [];
    
    for i=1:size(i_max,2)
        if i_max(i)==1
            EM1 = [EM1 FLIMfeatures(:,i)];
        elseif i_max(i)==2
            EM2 = [EM2 FLIMfeatures(:,i)];
        else
            EM3 = [EM3 FLIMfeatures(:,i)];
        end
    end
end