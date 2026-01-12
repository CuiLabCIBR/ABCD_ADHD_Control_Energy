function EnergyCal_Sub(sub_i,task_contrast,atlas)

% task_contrast: all0In_2Back0Back
% atlas: schaefer200, schaefer400

addpath(genpath('/ibmgpfs/cuizaixu_lab/yanghang/code/pncControlEnergy'));
addpath(genpath('/ibmgpfs/cuizaixu_lab/yanghang/code/BCT'));

working_dir = '/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy';
energy_dir = [working_dir '/results/energy_data'];

if ~isnumeric(sub_i)
    sub_i = str2num(sub_i);
end

sub_info = readtable([working_dir '/data/sub_info/sub_dwi_info.csv']);
sub_info = sub_info(sub_i, :);
release = char(sub_info.eventname2);

switch atlas
    case 'schaefer200'
        n = 252;
    case 'schaefer400'
        n = 452;
end

T = 1;
rho = 1;
% Control nodes selection
xc = eye(n);
% Nodes to be constrained
S = eye(n);

switch task_contrast
    case 'all0In_2Back0Back'
        % initial state
        x0 = zeros(n, 1);
        % Target state
        xf = importdata([working_dir '/data/activation/nBack/' atlas '/ABCD_2Back_0Back_' atlas '.txt']);
end

ResultantFolder = [energy_dir '/' release '/ABCD_' task_contrast '/' atlas];
if ~exist(ResultantFolder)
    mkdir(ResultantFolder);
end

ConnPath = char(sub_info.mat_path);
scanID_str = char(sub_info.sub_id);
ResultantFile = [ResultantFolder '/' num2str(scanID_str) '.mat'];

if ~exist(ResultantFile)
    connectivity_name = [atlas '_sift_invnodevol_radius2_count_connectivity'];
    connectivity = load(ConnPath, connectivity_name);
    connectivity = connectivity.(connectivity_name);
    
    A = connectivity ./ (svds(connectivity, 1) + 1);
    A = A - eye(size(A));
    
    [X_Opt_Trajectory, X_Opt_Final, U_Opt_Trajectory, Energy, n_err] = optim_fun(A, T, xc, x0, xf, S, rho);
    save(ResultantFile, 'X_Opt_Trajectory', 'X_Opt_Final', 'U_Opt_Trajectory', 'Energy', 'n_err', 'xc', 'xf');  
end
