function [ simulated_data, new_covariance_matrices, groups, max_diffs, old_covariance_matrices ] = SimulateGroupData(varargin)
%SimulateGroupData will generate simulated data
%   Detailed explanation goes here
filename='thenamelessone';
categorical_vector = 0;
ncases = 1;
group_column = 0;
ngroups = 0;
data_range = 0;
write_file = logical(1);
for i = 1:size(varargin,2)
    if ischar(varargin{i})
        switch(varargin{i})
            case('InputData')
                input_data = varargin{i+1};
            case('GroupBy')
                group_column = varargin{i+1};
                ngroups = unique(group_column);
            case('Categorical')
                categorical_vector = varargin{i+1};
            case('NumSimCases')
                ncases = varargin{i+1};
            case('DataRange')
                data_range = varargin{i+1};
            case('OutputDirectory')
                filename = varargin{i+1};
            case('NoSave')
                write_file = logical(0);
        end
    end
end
%check input data for categorical features needed for limited values
%Convert from cell matrix to numeric if categories exist
%NOTE: This will overwrite the categorical vector if used.
if iscell(input_data)
    [categorical_vector, group_data] = ConvertCelltoMatrixforTreeBagging(input_data);
else
    group_data = input_data;
end
ncols = size(group_data,2);
%if unspecified, the categorical vector will be set to zeros
if categorical_vector == 0
    categorical_vector = zeros(ncols,1);
end
%determine range for columns -- used to control appropriate values for
%simulated outputs
min_values = min(group_data,[],'omitnan');
max_values = max(group_data,[],'omitnan');
%using a covariance matrix to generated random data may cause problems when
%dealing with covariances that derived from messy data. The algorithm below
%will account for the problems generated by messy data, and provide a new 
%covariance matrix that can be used to generate random data. The algorithm
%will also report the maximum discrepancy between the new and old
%covariance matrices.
%compute eigenvalues and vectors via cholesky decomposition and inspect eigenvalues
%negative eigenvalues will be set to the lowest positive value per:
%Brissette FP, Khalili M, Leconte R. Efficient stochastic generation of multi-site synthetic precipitation data. 
%Journal of Hydrology. 2007 Oct 30;345(3-4):121-33.
if ngroups == 0
    ngroups = 1;
    group_column = ones(size(group_data,1),1);
    nsimulatedpergroup = ncases;
else
    nsimulatedpergroup = zeros(ngroups,1);
    for curr_group = 1:ngroups
        curr_group_data = group_data(group_column==curr_group,:);
        nsimulatedpergroup(curr_group) = round((size(curr_group_data,1)/size(group_data,1))*ncases);
    end
end
new_covariance_matrices = cell(ngroups,1);
old_covariance_matrices = cell(ngroups,1);
max_diffs = zeros(ngroups,1);
simulated_data = zeros(sum(nsimulatedpergroup),ncols);
groups = zeros(sum(nsimulatedpergroup),1);
curr_sub = 1;
for curr_group = 1:ngroups
    curr_group_data = group_data(group_column==curr_group,:);
    old_covariance_matrix = cov(curr_group_data,'partialrows');
    [eigenvector_data, eigenvalue_mat] = eig(old_covariance_matrix,'matrix');
    new_value = realmin;
    eigennewvalue_mat = zeros(size(eigenvalue_mat));
    for feature = 1:length(eigenvalue_mat);
        if eigenvalue_mat(feature,feature) < 0
            eigennewvalue_mat(feature,feature) = new_value;
        else
            eigennewvalue_mat(feature,feature) = eigenvalue_mat(feature,feature);
        end
    end
    new_covariance_matrix = eigenvector_data*eigennewvalue_mat*(eigenvector_data');
    %having made the new covariance matrix, we will check it against the old
    %covariance matrix and report the differences to stdout
    cov_diff = new_covariance_matrix - old_covariance_matrix;
    max_diff = max(max(cov_diff./old_covariance_matrix));
    sprintf('%s\n',['New covariance matrix for group ' num2str(curr_group) ' is at most ' num2str(max_diff*100) '% deviant from the old matrix.'])
    %assuming the difference between the two matrices is small, we can generate
    %an initial set of simulated data
    mu_data = mean(curr_group_data,'omitnan');
    fake_data = mvnrnd(mu_data,new_covariance_matrix,nsimulatedpergroup(curr_group));
%data is then evaluated based on the observed ranges and set to the closest
%observable value
    for curr_col = 1:ncols
        if categorical_vector(curr_col) == 0
            fake_data(:,fake_data(:,curr_col) < min_values(curr_col)) = min_values(curr_col);
            fake_data(:,fake_data(:,curr_col) > max_values(curr_col)) = max_values(curr_col);
        else
            fake_data(:,curr_col) = round(fake_data(:,curr_col));
            fake_data(:,fake_data(:,curr_col) < min_values(curr_col)) = min_values(curr_col);
            fake_data(:,fake_data(:,curr_col) > max_values(curr_col)) = max_values(curr_col);            
        end 
    end
    simulated_data(curr_sub:(curr_sub-1)+nsimulatedpergroup(curr_group),:) = fake_data;
    groups(curr_sub:(curr_sub-1)+nsimulatedpergroup(curr_group),1) = curr_group;
    curr_sub = curr_sub + nsimulatedpergroup(curr_group);
    max_diffs(curr_group) = max_diff;
    old_covariance_matrices{curr_group} = old_covariance_matrix;
    new_covariance_matrices{curr_group} = new_covariance_matrix;
end
if write_file
    save(filename,'simulated_data','groups','new_covariance_matrices','old_covariance_matrices','max_diffs','input_data');
end
end
