function [DatabaseML] = TableDatabase(Database)

Database(:, 15) = [];
Database(:, 64) = [];

column_names = cell(1, 63); % Pre-allocate
for i = 1:62
    column_names{i} = sprintf('Feature%d', i);
end
column_names{63} = 'Labels'; % Last column

numeric_labels = Database(:, end); % Last column
text_labels = cell(size(numeric_labels)); % Pre-allocate

text_labels = repmat({'Unknown'}, size(numeric_labels)); % Default
text_labels(numeric_labels == 1) = {'NoTumor'};
text_labels(numeric_labels == 2) = {'Tumor'};
text_labels(numeric_labels == 8) = {'Noise'};
text_labels(numeric_labels == 0) = {'Uk'};

% Create table with the first 62 columns (features)
DatabaseML = array2table(Database(:, 1:62), 'VariableNames', column_names(1:62));

% Add the labels column as a categorical or string variable
DatabaseML.Labels = categorical(text_labels); % Option 1: Convert to categorical
% table.Labels = string(text_labels);    % Option 2: Use plain strings
