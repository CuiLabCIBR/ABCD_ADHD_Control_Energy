clear
clc

task_contrast = 'all0In_2Back0Back';
atlas = 'schaefer400';

working_dir = '/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy';
energy_dir = [working_dir '/results/energy_data'];
energy_null_dir = [working_dir '/results/energy_data_null'];

mkdir(energy_null_dir)

sub_info = readtable([working_dir '/data/sub_info/sub_test_info.csv']);
sub_num = size(sub_info, 1);

energy_null = zeros(sub_num, 101, 452);

if isempty(gcp('nocreate'))
    parpool('local', 24);
end

% Load all null results
parfor sub_i = 1:sub_num
    sub_i
    sub_info_tmp = sub_info(sub_i, :);
    release = char(sub_info_tmp.eventname2);
    
    scanID_str = char(sub_info_tmp.sub_id);
    
    ResultantFolder = [energy_dir '/' release '/ABCD_' task_contrast '/' atlas '_null/'];
    ResultantFile = [ResultantFolder '/' num2str(scanID_str) '.mat'];
    
    tmp = load(ResultantFile);
    energy_null(sub_i, :, :) = tmp.Energy;
end

save([working_dir, '/scripts/Energy_Calculation/energy_null.mat'],'energy_null')

%% save each iteration to a csv file for combat
load([working_dir, '/scripts/Energy_Calculation/energy_null.mat'])
FileName = ['ABCD_' task_contrast '_' atlas];

for iter_i = 1:101
    iter_i
    Energy_csv = squeeze(energy_null(:,iter_i,:));
    Energy_csv = array2table(Energy_csv);
    writetable(Energy_csv,[energy_null_dir '/' FileName '_iter' num2str(iter_i, '%03d') '.csv'])
end

