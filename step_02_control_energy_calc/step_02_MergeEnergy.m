clear
clc

release_list = {'baselineYear1Arm1', '2YearFollowUpYArm1'};
contrast_list = {'all0In_2Back0Back'};
atlas_list = {'schaefer400', 'schaefer200'};

addpath(genpath('/ibmgpfs/cuizaixu_lab/yanghang/code/pncControlEnergy'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/yanghang/code/BCT'));

working_dir = '/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy';
energy_dir = [working_dir '/results/energy_data'];
data_dir = [working_dir '/data/sub_info/'];

sub_info = readtable([data_dir, 'sub_demo_info.csv']);
sublist = sub_info.sub_id;

if isempty(gcp('nocreate'))
    parpool('local', 24);
end

% Load all .mat files in the folder
for release_i = 1:length(release_list)
    release = release_list{release_i};
    
    for contrast_i = 1:length(contrast_list)
        task_contrast = contrast_list{contrast_i};
        
        for atlas_i = 1:length(atlas_list)
            atlas = atlas_list{atlas_i};
            
            ResultantFolder = [energy_dir '/' release '/ABCD_' task_contrast];
            sc_dir = struct2cell(dir([ResultantFolder '/' atlas '/*.mat']))';
            file_path = cellfun(@(x1,x2) fullfile(x1,x2),sc_dir(:,2),sc_dir(:,1),'UniformOutput',false);
            
            FileName = ['ABCD_' task_contrast '_' atlas];
            ResultantFile = [ResultantFolder '/' FileName '.mat'];
            
            EnergyMerge_Function(file_path, ResultantFile);
            
            Energy_Mat = load(ResultantFile);
            Energy_csv = array2table(Energy_Mat.Energy);
            writetable(Energy_csv,[ResultantFolder '/' FileName '.csv'])
            
        end
    end
end

%% Select .mat files and sort based on sub_demo_info.csv
for contrast_i = 1:length(contrast_list)
    task_contrast = contrast_list{contrast_i};
    
    for atlas_i = 1:length(atlas_list)
        atlas = atlas_list{atlas_i};
        
        ResultantFolder = [energy_dir '/' release_list{1} '/ABCD_' task_contrast];
        FileName = ['ABCD_' task_contrast '_' atlas];
        ResultantFile = [ResultantFolder '/' FileName '.mat'];
        
        Energy_Mat_0y = load(ResultantFile);
        Energy_0y = Energy_Mat_0y.Energy;
        sublist_0y = Energy_Mat_0y.scan_ID';
        
        % 2year follow up
        ResultantFolder = [energy_dir '/' release_list{2} '/ABCD_' task_contrast];
        FileName = ['ABCD_' task_contrast '_' atlas];
        ResultantFile = [ResultantFolder '/' FileName '.mat'];
        
        Energy_Mat_2y = load(ResultantFile);
        Energy_2y = Energy_Mat_2y.Energy;
        sublist_2y = Energy_Mat_2y.scan_ID';
        
        Energy_all = [Energy_0y; Energy_2y];
        sublist_all = [sublist_0y; sublist_2y];
        
        [~, idx] = ismember(sublist, sublist_all); % sort based on sub_demo_info.csv
        Energy_all = Energy_all(idx, :);
        sublist_all = sublist_all(idx, :);
        
        Energy_csv = array2table(Energy_all);
        writetable(Energy_csv,[energy_dir '/' FileName '.csv'])
        
    end
end
