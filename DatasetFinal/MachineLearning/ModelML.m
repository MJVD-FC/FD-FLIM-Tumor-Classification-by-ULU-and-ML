clear all;
close all; clc;
load('DatabaseNum.mat')
rng(42); %42


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = Database1;
data(:, 15) = [];

%%%%%%%%%%%%%% Necrosis samples %%%%%%%%%%%%%%%%


% The 20 samples with necrosis/hemorrhage >= 5% are already excluded: DatabaseNum.mat contains only the 51 samples used
colM=64; % column that contains the sample number


%%%%%%%%%%%%%%

num_features = size(data, 2) - 2;
feature_names = arrayfun(@(x) sprintf('Feature%d', x), 1:num_features, 'UniformOutput', false);
column_names = [feature_names, {'Label'}, {'Sample'}];
tbl = array2table(data, 'VariableNames', column_names);
valid_labels = (tbl.Label == 1 | tbl.Label == 2 );
tbl = tbl(valid_labels, :);

tbl.Label = categorical(tbl.Label, [1, 2], {'NoTumor', 'Tumor'});


num_obs = height(tbl);
rand_indices = randperm(num_obs)';
fold_size = floor(num_obs / 5);


for i = 1:5
    if i < 5
        fold_indices = rand_indices((i-1)*fold_size + 1 : i*fold_size);
    else
        fold_indices = rand_indices((i-1)*fold_size + 1 : end);
    end

    fold_name = sprintf('Fold%d', i);
    eval([fold_name ' = tbl(fold_indices, :);']); 
end

for i = 1:5
    fold_name = sprintf('Fold%d', i);
    current_fold = eval(fold_name);
    % save(sprintf('Fold%d.mat', i), fold_name); %Normal process
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for test_fold = 1:5
    % Determine which folds are used for training
    train_folds = setdiff(1:5, test_fold);

    % Initialize the empty training table
    dataset_train = table();

    % Concatenate the training folds
    for fold = train_folds
        fold_name = sprintf('Fold%d', fold);
        dataset_train = [dataset_train; eval(fold_name)];
    end

    % Create the dataset name
    dataset_name = sprintf('DatasetFold%d', test_fold);

    % Save both the training data and the test fold
    eval([dataset_name '.train = dataset_train;']);
    eval([dataset_name '.test = Fold' num2str(test_fold) ';']);

    % Display information
    fprintf('%s created:\n', dataset_name);
    fprintf('  - Training: %d observations\n', height(dataset_train));
    fprintf('  - Test: %d observations\n\n', height(eval(['Fold' num2str(test_fold)])));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Classification models setup
options = statset('UseParallel', false);


%1,3,5
models = {
    % 1. Bagged Trees (standard)
   struct('name', 'Bagged_Trees', 'fun', @(X,y) fitcensemble(X, y, 'Method', 'Bag', ...
   'Learners', templateTree('Reproducible', true), ...
   'NumLearningCycles', 400, 'Options', options)) ...

    %     % 2.*KNN (1 neighbor)
    %     struct('name', 'KNN', 'fun', @(X,y) fitcknn(X, y, ...
    %                'NumNeighbors', 1, 'Distance', 'euclidean', ...
    %                'Standardize', true)) ...
    %
    % 3. Random Forest
    struct('name', 'Random_Forest', 'fun', @(X,y) TreeBagger(100, X, y, ...
    'Method', 'classification', ...
    'OOBPrediction', 'off', ... %'MinLeafSize', 10, ...
    'Options', statset('UseParallel', false))) ...
    %
    %     % 4*Subspace (Discriminant)
    %     struct('name', 'Subspace_Discriminant', 'fun', @(X,y) fitcensemble(X, y, 'Method', 'Subspace', ...
    %                'Learners', 'discriminant', ...
    %                'NPredToSample', round(size(X,2)*0.7), ...  % 70% of features
    %                'NumLearningCycles', 30)) ...
    %
    % 5. AdaBoost (Boosting with trees)
    struct('name', 'AdaBoost', 'fun', @(X,y) fitcensemble(X, y, ...
    'Method', 'AdaBoostM1', ... %'Method', 'AdaBoostM1', ...
    'Learners', templateTree('MaxNumSplits', 1 ), ...  %10 -> Warning, 1
    'NumLearningCycles', 50, ...
    'LearnRate', 0.1)) ... %0.1

    };

% 1. Bagged Trees (standard)
%    struct('name', 'Bagged_Trees', 'fun', @(X,y) fitcensemble(X, y, 'Method', 'Bag', ...
%    'Learners', templateTree('Reproducible', true), ...
%    'NumLearningCycles', 400, 'Options', options)) ...

    % 3. Random Forest
%    struct('name', 'Random_Forest', 'fun', @(X,y) TreeBagger(100, X, y, ...
%    'Method', 'classification', ...
%    'OOBPrediction', 'off', ...
%    'MinLeafSize', 10, ...
%    'Options', statset('UseParallel', true))) ...

%FOR ORIGINAL AdaBoost
%'Learners', templateTree('MaxNumSplits', 10, 'Reproducible', true), 
%'Learners', templateTree('MaxNumSplits', 10)
%'LearnRate', 0.1

results = struct();

% Initialize variables to store results
accuracy_results = zeros(5,1);
misclassified_samples = cell(5,1);

% Process each DatasetFold
for i = 1:5
    dataset_name = sprintf('DatasetFold%d', i);
    fprintf('\n=== Processing %s ===\n', dataset_name);

    % Prepare data
    trainData = eval([dataset_name '.train']);
    testData = eval([dataset_name '.test']);

    X_train = trainData(:, 1:end-2);
    y_train = trainData.Label;
    X_test = testData(:, 1:end-2);
    y_test = testData.Label;
    sample_ids = testData.Sample;

    % Evaluate each model
    for m = 1:length(models)
        model_name = models{m}.name;
        fprintf('\nModel: %s\n', model_name);

        % Train and predict
        model = models{m}.fun(X_train, y_train);
        [y_pred, scores] = predict(model, X_test);
        y_pred = categorical(y_pred);
  %%%%%%%%%%% Compute metrics
        % Confusion matrix
        [cm, ~] = confusionmat(y_test, y_pred);
        TP = cm(1,1);  % True positives (NoTumor)
        FP = cm(2,1);  % False positives
        FN = cm(1,2);  % False negatives

        accuracy = sum(diag(cm))/sum(cm(:));
        precision = TP / (TP + FP);
        recall = TP / (TP + FN);
        f1_score = 2 * (precision * recall) / (precision + recall);

        % Identify misclassified samples
        misclassified = sample_ids(y_pred ~= y_test);

        % Store results
        results(i).(model_name) = struct(...
            'Accuracy', accuracy, ...
            'Precision', precision, ...
            'Recall', recall, ...
            'F1', f1_score, ...
            'Misclassified', misclassified);

        % Display results
        fprintf('Accuracy:  %.2f%%\n', accuracy*100);
        fprintf('Precision: %.2f%%\n', precision*100);
        fprintf('Recall:    %.2f%%\n', recall*100);
        fprintf('F1-score:  %.2f%%\n', f1_score*100);
        fprintf('Misclassified samples: ');
        if ~isempty(misclassified)
            fprintf('%d ', misclassified');
        else
            fprintf('None');
        end
        fprintf('\n');

        % Display confusion matrix
       figure;
       confusionchart(y_test, y_pred);
       title(sprintf('%s - Fold %d', model_name, i));
    end
end

fprintf('\n=== FINAL SUMMARY ===\n');
for m = 1:length(models)
    model_name = models{m}.name;
    fprintf('\nModel: %s\n', model_name);

    % Compute means
    avg_acc = mean(arrayfun(@(x) results(x).(model_name).Accuracy, 1:5));
    avg_prec = mean(arrayfun(@(x) results(x).(model_name).Precision, 1:5));
    avg_rec = mean(arrayfun(@(x) results(x).(model_name).Recall, 1:5));
    avg_f1 = mean(arrayfun(@(x) results(x).(model_name).F1, 1:5));

    % Compute standard deviations
    std_acc = std(arrayfun(@(x) results(x).(model_name).Accuracy, 1:5));
    std_prec = std(arrayfun(@(x) results(x).(model_name).Precision, 1:5));
    std_rec = std(arrayfun(@(x) results(x).(model_name).Recall, 1:5));
    std_f1 = std(arrayfun(@(x) results(x).(model_name).F1, 1:5));

    fprintf('Averages:\n');
    fprintf('  Accuracy:  %.2f%% +/- %.2f%%\n', avg_acc*100,  std_acc*100 );
    fprintf('  Precision: %.2f%% +/- %.2f%%\n', avg_prec*100, std_prec*100);
    fprintf('  Recall:    %.2f%% +/- %.2f%%\n', avg_rec*100 , std_rec*100);
    fprintf('  F1-score:  %.2f%% +/- %.2f%%\n', avg_f1*100  , std_f1*100);

    % Most frequently misclassified samples
    % all_misclassified = [];
    % for i = 1:5
    %     all_misclassified = [all_misclassified; results(i).(model_name).Misclassified];
    % end
    % [unique_ids, counts] = histcounts(categorical(all_misclassified));
    % 
    % if ~isempty(unique_ids)
    %     fprintf('\nProblematic samples (most frequently misclassified):\n');
    %     for j = 1:length(unique_ids)
    %         fprintf('  Sample %d: %d times\n', str2double(counts(j)), unique_ids(j));
    %     end
    % end
end

disp('END');
