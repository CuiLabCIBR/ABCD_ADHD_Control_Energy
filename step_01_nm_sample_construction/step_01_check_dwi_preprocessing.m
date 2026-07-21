clear
clc

root_path = '/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_control_energy/';
addpath(genpath('/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy/scripts/functions'))

working_path = '/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy/scripts/load_sc/';
cd(working_path)

release_list = {'baselineYear1Arm1','2YearFollowUpYArm1'};
eventname_list = {'baseline_year_1_arm_1','2_year_follow_up_y_arm_1'};

for year_i = 1:length(release_list)
    
    release = release_list{year_i};
    eventname = eventname_list{year_i};
    
    %% SIEMENS
    datapath = ['/ibmgpfs/cuizaixu_lab/xuxiaoyu/ABCD/processed/qsiPrep/SC_matrix/' release '/SIEMENS/'];
    
    site = struct2cell(dir([datapath 'site*']))';
    [n_site, ~] = size(site);
    site_subnum = zeros(n_site,1);
    sc_path = {};
    
    for i = 1:n_site
        site_path = [site{i,2},filesep,site{i,1}];
        sc_dir = struct2cell(dir([site_path,filesep,'*.mat']))';
        file_path = cellfun(@(x1,x2) fullfile(x1,x2),sc_dir(:,2),sc_dir(:,1),'UniformOutput',false);
        file_path = [sc_dir(:,1:2),file_path];
        
        sc_path = [sc_path;file_path];
    end
    
    sc_path_SIEMENS = sc_path;
    sc_path_SIEMENS(:,4) = {'SIEMENS'};
    sub_SIEMENS = sc_path_SIEMENS(:,1);
    
    %% GE
    datapath = ['/ibmgpfs/cuizaixu_lab/xuxiaoyu/ABCD/processed/qsiPrep/SC_matrix/' release '/GE/'];
    
    site = struct2cell(dir([datapath 'site*']))';
    [n_site, ~] = size(site);
    site_subnum = zeros(n_site,1);
    sc_path = {};
    
    for i = 1:n_site
        site_path = [site{i,2},filesep,site{i,1}];
        sc_dir = struct2cell(dir([site_path,filesep,'*.mat']))';
        file_path = cellfun(@(x1,x2) fullfile(x1,x2),sc_dir(:,2),sc_dir(:,1),'UniformOutput',false);
        file_path = [sc_dir(:,1:2),file_path];
        
        sc_path = [sc_path;file_path];
    end
    
    sc_path_GE = sc_path;
    sc_path_GE(:,4) = {'GE'};
    sub_GE = sc_path_GE(:,1);
    
    %% Philips
    datapath = ['/ibmgpfs/cuizaixu_lab/xuxiaoyu/ABCD/processed/qsiPrep/SC_matrix/' release '/Philips/'];
    
    site = struct2cell(dir([datapath 'site*']))';
    [n_site, ~] = size(site);
    site_subnum = zeros(n_site,1);
    sc_path = {};
    
    for i = 1:n_site
        site_path = [site{i,2},filesep,site{i,1}];
        sc_dir = struct2cell(dir([site_path,filesep,'*.mat']))';
        file_path = cellfun(@(x1,x2) fullfile(x1,x2),sc_dir(:,2),sc_dir(:,1),'UniformOutput',false);
        file_path = [sc_dir(:,1:2),file_path];
        
        sc_path = [sc_path;file_path];
    end
    
    sc_path_Philips = sc_path;
    sc_path_Philips(:,4) = {'Philips'};
    sub_Philips = sc_path_Philips(:,1);
    
    %%
    % all subjects with sc_connectome
    sc_path_all = [sc_path_SIEMENS; sc_path_GE; sc_path_Philips];
    
    [~, site_id] = cellfun(@(x) fileparts(x),sc_path_all(:,2),'UniformOutput',false);
    sc_path_all = [sc_path_all, site_id];
    
    sub_sc_all = sc_path_all(:,1);
    suffix = '_space-T1w_desc-preproc_msmtconnectome.mat';
    sub_sc_all = cellfun(@(x) strrep(x,suffix,''),sub_sc_all,'UniformOutput',false);
    sc_path_all(:,1) = sub_sc_all;
    
    % get unique subjects and correct site_id
    abcd_y_lt = readtable([root_path 'behav/abcd-data-release-5.1/core/abcd-general/abcd_y_lt.csv']);
    abcd_y_lt = abcd_y_lt(strcmp(abcd_y_lt.eventname, eventname),:);
    
    sub_y_lt = abcd_y_lt.src_subject_id;
    sub_y_lt = cellfun(@(x) strrep(x,'NDAR_','sub-NDAR'),sub_y_lt,'UniformOutput',false);
    sub_y_lt = cellfun(@(x) [x '_ses-' release],sub_y_lt,'UniformOutput',false);
    
    tbl = tabulate(sub_sc_all);
    repeat_idx = find(cell2mat(tbl(:,2)) > 1);
    repeat_sub = tbl(repeat_idx,1);
    
    if length(repeat_idx) > 0
        for sub_i = 1:length(repeat_sub)
            idx = find(ismember(sub_y_lt, repeat_sub(sub_i)));
            real_site = abcd_y_lt.site_id_l(idx);
            real_site = regexprep(real_site, 'site0([1-9])', 'site$1');
            
            idx = find(ismember(sub_sc_all, repeat_sub(sub_i)));
            repeat_site = sc_path_all(idx,5);
            
            idx_exclude(sub_i,1) = idx(~ismember(repeat_site,real_site));
        end
        
        sc_path_all(idx_exclude,:) = [];
        sub_sc_all = sc_path_all(:,1);
    end
    
    %% check sc connectome
    sub_num = length(sub_sc_all);
    network_strength = zeros(sub_num,4);
    
    if isempty(gcp('nocreate'))
        parpool('local', 24);
    end
    
    parfor sub_i = 1:sub_num
        sub_i
        
        ConnPath = sc_path_all{sub_i,3};
        network_strength(sub_i,:,:,:) = calc_network_strength(ConnPath);
    end
    
    qc_idx = find(network_strength(:,3) == 1); % no isolated regions for schaefer400 atlas
    
    sc_path_all = sc_path_all(qc_idx,:);
    sub_sc_all = sub_sc_all(qc_idx);
    network_strength = network_strength(qc_idx,:);
    
    %% Load HeadMotion
    sub_num = length(sub_sc_all);
    dwi_fd = zeros(sub_num,1);
    
    if isempty(gcp('nocreate'))
        parpool('local', 24);
    end
    
    parfor sub_i = 1:sub_num
        sub_i
        
        sub_id = sc_path_all{sub_i,1};
        file_path = sc_path_all{sub_i,2};
        file_path = strrep(file_path,'SC_matrix','qc_json');
        
        try
            dwi_fd(sub_i,1) = load_qc_fd(sub_id, file_path);
        catch
            dwi_fd(sub_i,1) = nan;
        end
        
    end
    
    %
    network_strength_fd = [network_strength(:,1:2),dwi_fd];
    sub_dwi_strength_fd = [sc_path_all(:,[1,3]), num2cell(network_strength_fd)];
    sub_dwi_strength_fd = [{'sub_id','mat_path','schaefer400','schaefer200','mean_fd'};sub_dwi_strength_fd];
    
    writecell(sub_dwi_strength_fd,[working_path 'sub_dwi_strength_fd_' release '_qc.csv'])
end
