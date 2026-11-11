%% Leave-One-Out Cross-Validation LOOCV
clear all; 
close all; 
clc;
load('DatabaseNum.mat')
rng(42);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = Database1;
data(:, 15) = []; 

%%%%%%%%%%%%%% Necrosis samples %%%%%%%%%%%%%%%%
% The 20 samples with necrosis/hemorrhage >= 5% are already excluded: DatabaseNum.mat contains only the 51 samples used
colM=64; % column that contains the sample number


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_features = size(data, 2) - 2;
feature_names = arrayfun(@(x) sprintf('Feature%d', x), 1:num_features, 'UniformOutput', false);
column_names = [feature_names, {'Label'}, {'Sample'}];
tbl = array2table(data, 'VariableNames', column_names);
valid_labels = (tbl.Label == 1 | tbl.Label == 2);
tbl = tbl(valid_labels, :);
tbl.Label = categorical(tbl.Label, [1, 2], {'NoTumor', 'Tumor'});

num_obs = height(tbl);

%% Models configuration 
options = statset('UseParallel', false);  
models = {
    % 1. Bagged Trees (standard)
    struct('name', 'Bagged_Trees', 'fun', @(X,y) fitcensemble(X, y, 'Method', 'Bag', ...
               'Learners', templateTree('Reproducible', true), ...
               'NumLearningCycles', 400, 'Options', options)), ...
    
    % 3. Random Forest
    struct('name', 'Random_Forest', 'fun', @(X,y) TreeBagger(100, X, y, ...
           'Method', 'classification', 'Options', options)), ...
    
    % 5. AdaBoost (Boosting with trees)
    struct('name', 'AdaBoost', 'fun', @(X,y) fitcensemble(X, y, 'Method', 'AdaBoostM1', ...
           'Learners', templateTree('MaxNumSplits', 1, 'Reproducible', true), ... %10
           'NumLearningCycles', 50, 'LearnRate', 0.1))
};

% Initialize containers for global predictions
num_models = length(models);
all_predictions = categorical(zeros(num_obs, num_models));
all_labels = tbl.Label;
sample_ids = tbl.Sample;

fprintf('Starting Leave-One-Out CV for %d observations...\n', num_obs);

results = struct();

for i = 1:num_obs
    % Leave-One-Out split: i is the test index, the rest is used for training
    trainData = tbl([1:i-1, i+1:end], :);
    testData = tbl(i, :);
    
    X_train = trainData(:, 1:end-2);
    y_train = trainData.Label;
    X_test = testData(:, 1:end-2);
    
    for m = 1:num_models
        % Train model
        model = models{m}.fun(X_train, y_train);
        
        % Predict the single held-out sample
        y_pred = predict(model, X_test);
        
        % Output handling for TreeBagger (returns a cell array)
        all_predictions(i, m) = categorical(y_pred);
        
    end
    
    if mod(i, 10) == 0, fprintf('Processed sample %d/%d\n', i, num_obs); end
end




for m = 1:num_models
    model_name = models{m}.name;
    y_pred_model = all_predictions(:, m);
    
    % Global confusion matrix
    cm = confusionmat(all_labels, y_pred_model);
    TP = cm(1,1); % NoTumor
    TN = cm(2,2); % Tumor
    FP = cm(2,1);
    FN = cm(1,2);
    
    accuracy = (TP + TN) / sum(cm(:));
    precision = TP / (TP + FP);
    recall = TP / (TP + FN);
    f1_score = 2 * (precision * recall) / (precision + recall);


    
    fprintf('\nModel: %s\n', model_name);
    fprintf('  Accuracy:  %.2f%%\n', accuracy * 100);
    fprintf('  Precision: %.2f%%\n', precision * 100);
    fprintf('  Recall:    %.2f%%\n', recall * 100);
    fprintf('  F1-score:  %.2f%%\n', f1_score * 100);
    
    % Identify misclassified samples
    misclassified_idx = find(y_pred_model ~= all_labels);
    if ~isempty(misclassified_idx)
        fprintf('  Misclassified samples (ID): ');
        fprintf('%d ', sample_ids(misclassified_idx));
        fprintf('\n');
    end
    
    % Visualization
    figure;
    confusionchart(all_labels, y_pred_model);
    title(sprintf('%s - LOOCV Results', model_name));
end

