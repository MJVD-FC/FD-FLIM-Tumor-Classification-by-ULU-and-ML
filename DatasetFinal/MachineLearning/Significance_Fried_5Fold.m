%% Accuracy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n=== FINAL SUMMARY AND STATISTICAL ANALYSIS ===\n');

% 1. Extract metrics into matrices (Folds x Models)
num_models = length(models);
acc_matrix = zeros(5, num_models);

for m = 1:num_models
    model_name = models{m}.name;
    for i = 1:5
        acc_matrix(i, m) = results(i).(model_name).Accuracy;
    end
end

% 2. Compute mean and standard deviation
for m = 1:num_models
    model_name = models{m}.name;

    mu = mean(acc_matrix(:, m));
    sigma = std(acc_matrix(:, m));

    fprintf('\n-------------------------------------------\n');
    fprintf('Model: %s\n', model_name);
    fprintf('Report: %.4f ± %.4f (Accuracy)\n', mu, sigma);
    fprintf('-------------------------------------------\n');
end

% 3. Friedman test
fprintf('\n--- Friedman test ---\n');

% acc_matrix: rows = folds, columns = models
[p,tbl,stats] = friedman(acc_matrix, 1, 'off');

fprintf('p-value = %.4f', p);

if p < 0.05
    fprintf(', there are significant differences among models.\n');

    % Post-hoc multiple comparisons
    fprintf('\n--- Pairwise comparison p-values ---\n');

    c = multcompare(stats, ...
        'CriticalValueType','dunn-sidak', ...
        'Display','off');

    fprintf('Mod1\t\tMod2\t\tp-value\n');

    for k = 1:size(c,1)
        fprintf('%s\t\t%s\t\t%.4f\n', ...
            models{c(k,1)}.name, ...
            models{c(k,2)}.name, ...
            c(k,6));
    end

else
    fprintf(', (ns) no significant differences were found.\n');
end


%% Precision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n=== FINAL SUMMARY AND STATISTICAL ANALYSIS ===\n');

% 1. Extract metrics into matrices (Folds x Models)
num_models = length(models);
acc_matrix = zeros(5, num_models);

for m = 1:num_models
    model_name = models{m}.name;
    for i = 1:5
        acc_matrix(i, m) = results(i).(model_name).Precision;
    end
end

% 2. Compute mean and standard deviation
for m = 1:num_models
    model_name = models{m}.name;

    mu = mean(acc_matrix(:, m));
    sigma = std(acc_matrix(:, m));

    fprintf('\n-------------------------------------------\n');
    fprintf('Model: %s\n', model_name);
    fprintf('Report: %.4f ± %.4f (Precision)\n', mu, sigma);
    fprintf('-------------------------------------------\n');
end

% 3. Friedman test
fprintf('\n--- Friedman test ---\n');

% acc_matrix: rows = folds, columns = models
[p,tbl,stats] = friedman(acc_matrix, 1, 'off');

fprintf('p-value = %.4f', p);

if p < 0.05
    fprintf(', there are significant differences among models.\n');

    % Post-hoc multiple comparisons
    fprintf('\n--- Pairwise comparison p-values ---\n');

    c = multcompare(stats, ...
        'CriticalValueType','dunn-sidak', ...
        'Display','off');

    fprintf('Mod1\t\tMod2\t\tp-value\n');

    for k = 1:size(c,1)
        fprintf('%s\t\t%s\t\t%.4f\n', ...
            models{c(k,1)}.name, ...
            models{c(k,2)}.name, ...
            c(k,6));
    end

else
    fprintf(', (ns) no significant differences were found.\n');
end

%% Recall
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n=== FINAL SUMMARY AND STATISTICAL ANALYSIS ===\n');

% 1. Extract metrics into matrices (Folds x Models)
num_models = length(models);
acc_matrix = zeros(5, num_models);

for m = 1:num_models
    model_name = models{m}.name;
    for i = 1:5
        acc_matrix(i, m) = results(i).(model_name).Recall;
    end
end

% 2. Compute mean and standard deviation
for m = 1:num_models
    model_name = models{m}.name;

    mu = mean(acc_matrix(:, m));
    sigma = std(acc_matrix(:, m));

    fprintf('\n-------------------------------------------\n');
    fprintf('Model: %s\n', model_name);
    fprintf('Report: %.4f ± %.4f (Recall)\n', mu, sigma);
    fprintf('-------------------------------------------\n');
end

% 3. Friedman test
fprintf('\n--- Friedman test ---\n');

% acc_matrix: rows = folds, columns = models
[p,tbl,stats] = friedman(acc_matrix, 1, 'off');

fprintf('p-value = %.4f', p);

if p < 0.05
    fprintf(', there are significant differences among models.\n');

    % Post-hoc multiple comparisons
    fprintf('\n--- Pairwise comparison p-values ---\n');

    c = multcompare(stats, ...
        'CriticalValueType','dunn-sidak', ...
        'Display','off');

    fprintf('Mod1\t\tMod2\t\tp-value\n');

    for k = 1:size(c,1)
        fprintf('%s\t\t%s\t\t%.4f\n', ...
            models{c(k,1)}.name, ...
            models{c(k,2)}.name, ...
            c(k,6));
    end

else
    fprintf(', (ns) no significant differences were found.\n');
end

%% F1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n=== FINAL SUMMARY AND STATISTICAL ANALYSIS ===\n');

% 1. Extract metrics into matrices (Folds x Models)
num_models = length(models);
acc_matrix = zeros(5, num_models);

for m = 1:num_models
    model_name = models{m}.name;
    for i = 1:5
        acc_matrix(i, m) = results(i).(model_name).F1;
    end
end

% 2. Compute mean and standard deviation
for m = 1:num_models
    model_name = models{m}.name;

    mu = mean(acc_matrix(:, m));
    sigma = std(acc_matrix(:, m));

    fprintf('\n-------------------------------------------\n');
    fprintf('Model: %s\n', model_name);
    fprintf('Report: %.4f ± %.4f (F1)\n', mu, sigma);
    fprintf('-------------------------------------------\n');
end

% 3. Friedman test
fprintf('\n--- Friedman test ---\n');

% acc_matrix: rows = folds, columns = models
[p,tbl,stats] = friedman(acc_matrix, 1, 'off');

fprintf('p-value = %.4f', p);

if p < 0.05
    fprintf(', there are significant differences among models.\n');

    % Post-hoc multiple comparisons
    fprintf('\n--- Pairwise comparison p-values ---\n');

    c = multcompare(stats, ...
        'CriticalValueType','dunn-sidak', ...
        'Display','off');

    fprintf('Mod1\t\tMod2\t\tp-value\n');

    for k = 1:size(c,1)
        fprintf('%s\t\t%s\t\t%.4f\n', ...
            models{c(k,1)}.name, ...
            models{c(k,2)}.name, ...
            c(k,6));
    end

else
    fprintf(', (ns) no significant differences were found.\n');
end