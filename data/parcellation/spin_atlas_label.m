clear
clc
addpath(genpath('.../ENIGMA/matlab'))

%% schaefer_400 cortex
lsphere = SurfStatReadSurf1('fsa5_sphere_lh');
rsphere = SurfStatReadSurf1('fsa5_sphere_rh');

lh_centroid = centroid_extraction_sphere(lsphere.coord.', 'fsa5_lh_schaefer_400.annot');
rh_centroid = centroid_extraction_sphere(rsphere.coord.', 'fsa5_rh_schaefer_400.annot');

perm_id_cortex = rotate_parcellation(lh_centroid, rh_centroid, 10000);

%% subcortex
n_roi = 52; % 52 subcortical ROIs
n_iter = 10000;

perm_id_subcortex = zeros(n_roi, n_iter);

for n_rot = 1:n_iter
    perm_id_subcortex(:, n_rot) = randperm(n_roi);
end

%% combine
perm_id = [perm_id_cortex; perm_id_subcortex];
save('F:/Cui_Lab/Projects/ABCD_ADHD_Control_Energy/data/parcellation/perm_id_schaefer452.mat','perm_id')

%% glasser_360
% lsphere = SurfStatReadSurf1('fsa5_sphere_lh');
% rsphere = SurfStatReadSurf1('fsa5_sphere_rh');
%
% lh_centroid = centroid_extraction_sphere(lsphere.coord.', 'fsa5_lh_glasser_360.annot');
% rh_centroid = centroid_extraction_sphere(rsphere.coord.', 'fsa5_rh_glasser_360.annot');
%
% perm_id = rotate_parcellation(lh_centroid, rh_centroid, 10000);
%
% save('F:/Cui_Lab/Projects/Connectional_Variability_Axis/data/parcellation_files/perm_id_glasser360.mat','perm_id')
