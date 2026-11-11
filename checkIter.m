%% Stop conditions
function FlagCont=checkIter(Classes,firstIter,P1)

    errorEndMember = 0;
    
    if firstIter ~= 0
        % Spatial contribution
        for ii = 1:length(Classes)
            if Classes(ii)<0.05 % If the spatial contribution is less than 5%
                errorEndMember=1;
                disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                disp('Threshold for abundances')
                disp(['Spatial contribution (%) = ' num2str(100*Classes(ii))]);
                disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                fprintf('\n')
                break;
            end
        end
        
        % Spectral Angle Map (SAM)
        % https://step.esa.int/main/wp-content/help/versions/9.0.0/snap-toolboxes/org.esa.s2tbx.s2tbx.spectral.angle.mapper.ui/sam/SAMProcessor.html
        if errorEndMember~=1
            thresholdTheta = 10; %10
            % x = spectral signature vector of an image pixel
            % y = spectral signature vector of training area
            % n = number of image bands
            % theta = SAM
            
            norms = sqrt(sum(P1.^2, 1));
            P1_norm = P1 ./ norms;
            
            cos_matrix = P1_norm' * P1_norm;
            cos_matrix = min(max(cos_matrix, -1), 1);
            
            angle_matrix = acos(cos_matrix);
            angle_matrix = triu(angle_matrix);
            
            angle_matrix = rad2deg(angle_matrix);   

            for i = 1:size(angle_matrix,1)
                for j = 1:size(angle_matrix,2)
                    if angle_matrix(i,j)<thresholdTheta && angle_matrix(i,j)~=0 && i~=j
                         errorEndMember=1;
                        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                        disp('Threshold for end-members')
                        disp(['Spectral Angle (Deg) EM' num2str(i) '-EM' num2str(j) ' = ' num2str(angle_matrix(i,j))]);
                        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
                        fprintf('\n')
                    end
                end
            end
        end     
    end
    
    % Stop flag
    if errorEndMember~=1
        FlagCont = 0;
    else
        FlagCont = 1;
    end
end