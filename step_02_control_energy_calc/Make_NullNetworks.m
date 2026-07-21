function Make_NullNetworks(sub_i, atlas)

addpath(genpath('/ibmgpfs/cuizaixu_lab/yanghang/code/pncControlEnergy'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/yanghang/code/BCT'));

working_dir = '/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy';

if ~isnumeric(sub_i)
    sub_i = str2num(sub_i);
end

sub_info = readtable([working_dir '/data/sub_info/sub_test_info.csv']);
sub_info = sub_info(sub_i, :);

scanID_str = char(sub_info.sub_id);
ResultantFolder = [working_dir '/data/sc_null/'];
if ~exist(ResultantFolder)
    mkdir(ResultantFolder);
end

ResultantFile = [ResultantFolder '/' num2str(scanID_str) '_null.mat'];

if ~exist(ResultantFile)

    ConnPath = char(sub_info.mat_path);
    scanID_str = char(sub_info.sub_id);

    connectivity_name = [atlas '_sift_invnodevol_radius2_count_connectivity'];
    connectivity = load(ConnPath, connectivity_name);
    connectivity = connectivity.(connectivity_name);

    [nrow, ncol] = size(connectivity);

    rand_num = 101;
    sc_null = zeros(nrow, ncol,rand_num);

    for rand_i = 1:rand_num
        null_connectivity = null_model_und_sign(connectivity);
        sc_null(:,:,rand_i) = null_connectivity;
    end

    save(ResultantFile, 'sc_null')
end