#! /bin/bash
#RunAndVisualizeCommunityDetection_wrapper.sh requires a ParamFile as an input (e.g. RunAndVisualizeCommunityDetection_wrapper.sh RunAndVisualizeCommunityDetection_example.bash). See the RunAndVisualizeCommunityDetection_example.bash for more information on available parameters.
source $1
#If missing parameters, set defaults
filename=${filename:-'thenamelessone'}
infomap_command_file=${infomap_command_file:-'/group_shares/fnl/bulk/code/internal/utilities/simple_infomap/simple_infomap.py'}
lowdensity=${lowdensity:-0.2}
stepdensity=${stepdensity:-0.05}
highdensity=${highdensity:-1}
#Construct the model, which will save outputs to a filename.mat file
matlab -nodisplay -nosplash -singleCompThread -r "addpath('/group_shares/fnl/bulk/code/internal/analyses/RFAnalysis') ; RunAndVisualizeCommunityDetection(struct('path','"${corrmatpath}"','variable','"${corrmatvar}"'),'"$filename"','"$infomap_command_file"',100,'LowDensity',"$lowdensity",'StepDensity',"$stepdensity",'HighDensity',"$highdensity"); exit"
