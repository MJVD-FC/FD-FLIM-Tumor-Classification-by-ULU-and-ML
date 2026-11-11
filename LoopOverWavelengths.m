function [data,dataBG] = LoopOverWavelengths(LocalFeatures, titleL, refined_mask_closed, test, mark, wavelengths,channels_375,channels_445, x_pixels, y_pixels,SW)
    addpath(fullfile(appRoot, 'Database'));
    lengthFeatures=length(channels_375)*length(LocalFeatures)+length(channels_445)*length(LocalFeatures);
    data = zeros(x_pixels, y_pixels,lengthFeatures);  

    % Initialize a counter for the third dimension
    counter = 0;
    % Loop over the wavelengths
    for k = 1:length(LocalFeatures)
        for i = 1:length(wavelengths)
            % Determine the channels for the current wavelength
            if wavelengths(i) == 375
                channels = channels_375;
            else
                channels = channels_445;
            end
            for j = 1:length(channels)
                % Loop over the channels

                % Loop over the features

                % Construct the path to the current feature
                path = sprintf('/Calibrated Data/Channel %d/%d/%s', channels(j), wavelengths(i), LocalFeatures{k});
                
                % Read the data from the current feature
                feature_data = h5read(titleL, path);
                
                switch test
                    % All features
                    case 1
                        if k==5 || k==7 || k==9
                            feature_data=wrapTo2Pi(feature_data);
                        elseif k==1
                            %feature_data=feature_data/1e7;
                            if SW==0  
                                feature_data=feature_data/5e7; %5e7
                            else
                                feature_data=feature_data/1e8; %1e2
                            end
                        end
                    % Intensity
                    case 2
                        if k==1
                            feature_data=feature_data/1e7;
                        end
                    % Modulation
                    case 3
                    % Phase
                    case 4
                        feature_data=wrapTo2Pi(feature_data);
                    otherwise
                        if mark==1
                            feature_data=feature_data/1e7;
                        elseif mark==5 || mark==7 || mark==9
                            feature_data=wrapTo2Pi(feature_data);
                        end
                end
                  
                % Apply the FOV mask to the feature data
                feature_data_masked = feature_data .* refined_mask_closed;

                % Background
                feature_data_masked2 = feature_data .* ~refined_mask_closed;

                % Increment the counter
                counter = counter + 1;

                % Store the masked feature data in the 3D array
                data(:, :, counter) = feature_data_masked;
                dataBG(:, :, counter) = feature_data_masked2;
            end
        end
    end
end