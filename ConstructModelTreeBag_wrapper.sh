#! /bin/bash

#ConstructModelTreeBag_wrapper.sh requires a ParamFile as an input (e.g. ConstructModelTreeBag_wrapper.sh TreeBagParamFile_example.bash). See the TreeBagParamFile_example.bash for more information on available parameters.
source $1
#declare missing parameters that have logic flow as false -- correction 12/14/16
outcome_variable_exist=${outcome_variable_exist:-'false'}
matchgroups=${matchgroups:-'false'}
OOB_error=${OOB_error:-'false'}
holdout=${holdout:-'false'}
estimate_trees=${estimate_trees:-'false'}
weight_trees=${weight_trees:-'false'}
trim_features=${trim_features:-'false'}
estimate_predictors=${estimate_predictors:-'false'}
estimate_treepred=${estimate_treepred:-'false'}
regression=${regression:-'false'}
surrogate=${surrogate:-'false'}
group2test=${group2test:-'false'}
fisher_z_transform=${fisher_z_transform:-'false'}
#parameters set from the TreeBagParamFile
if $use_group2_data; then group2_data="struct('path','"${group2path}"','variable','"${group2var}"')"; else group2_data=0; fi
if $estimate_trees; then estimate_trees='EstimateTrees'; else estimate_trees='NONE'; fi
if $weight_trees; then weight_trees='WeightForest'; else weight_trees='NONE'; fi
if $trim_features; then trim_features='TrimFeatures'; else trim_features='NONE'; fi
if $fisher_z_transform; then fisher_z_transform='FisherZ'; else fisher_z_transform='NONE'; fi
if $disable_treebag; then disable_treebag='TreebagsOff'; else disable_treebag='NONE'; fi
if $holdout; then holdout='Holdout'; else holdout='NONE'; fi
if $npredictors; then npredictors='npredictors'; else npredictors='NONE'; fi
if $estimate_predictors; then estimate_predictors='EstimatePredictors'; else estimate_predictors='NONE'; fi
if $estimate_treepred; then estimate_treepred='EstimateTreePredictors'; else estimate_treepred='NONE'; fi
if $OOB_error; then OOB_error='OOBErrorOn'; else OOB_error='NONE'; fi
if $regression; then regression='Regression'; else regression='NONE'; fi
if $outcome_variable; then outcome_variable_exist='useoutcomevariable'; if $outcome_is_struct; then group1outcome="struct('path','"${group1outcome_path}"','variable','"${group1outcome_var}"')"; group2outcome="struct('path','"${group2outcome_path}"','variable','"${group2outcome_var}"')"; else group1outcome=$group1outcome_num; group2outcome=$group2outcome_num; fi; else group1outcome=0; group2outcome=0; fi
if $surrogate; then surrogate='surrogate'; else surrogate='NONE'; fi
if $group2_validate_only; then group2test='group2istestdata'; else group2test='NONE'; fi
if $uniform_priors; then priors='Uniform'; else priors='Empirical'; fi
if $use_unsupervised; then unsupervised='unsupervised'; else unsupervised='NONE'; fi
if $matchgroups; then matchgroups='MatchGroups'; else matchgroups='NONE'; fi
#If missing other parameters, set defaults
datasplit=${datasplit:-0.9}
ntrees=${ntrees:-1000}
nreps=${nreps:-1000}
nperms=${nperms:-1}
filename=${filename:-'thenamelessone'}
nfeatures=${nfeatures:-0}
disable_treebag=${disable_treebag:-'TreebagsOff'}
holdout_data=${holdout_data:-'NONE'}
group_holdout=${group_holdout:-0}
proxsublimit_num=${proxsublimit_num:-500}
npredictors=${npredictors:-'NONE'}
num_predictors=${num_predictors:-0}
group1outcome=${group1outcome:-0}
group2outcome=${group2outcome:-0}
lowdensity=${lowdensity:-0.2}
stepdensity=${stepdensity:-0.05}
highdensity=${highdensity:-1}
#Construct the model, which will save outputs to a filename.mat file
matlab -nodisplay -nosplash -singleCompThread -r "addpath('/group_shares/fnl/bulk/code/internal/analyses/RFAnalysis') ; ConstructModelTreeBag(struct('path','"${group1path}"','variable','"${group1var}"'),"$group2_data","$datasplit","$nreps","$ntrees","$nperms",'"${filename}"',"$proxsublimit_num",'"${estimate_trees}"','"${weight_trees}"','"${trim_features}"',"$nfeatures",'"${OOB_error}"','"${fisher_z_transform}"','"${disable_treebag}"','"${holdout}"','"${holdout_data}"',"$group_holdout",'"${estimate_predictors}"','"${estimate_treepred}"','"${npredictors}"',"$num_predictors",'"${surrogate}"','"${regression}"','"${outcome_variable_exist}"',"$group1outcome","$group2outcome",'"${group2test}"','Prior','"${priors}"','"${unsupervised}"','"${matchgroups}"','LowDensity',"$lowdensity",'StepDensity',"$stepdensity",'HighDensity',"$highdensity") ; exit"
