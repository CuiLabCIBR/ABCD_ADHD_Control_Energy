import nibabel as nib
import numpy as np
import pandas as pd
import os
import scipy.io
from neuromaps.datasets import fetch_annotation
from neuromaps import transforms
from nilearn.surface import load_surf_data
from nilearn.image import resample_to_img
from netneurotools import datasets as nntdata
from netneurotools.freesurfer import vertices_to_parcels

working_dir = 'F:/Cui_Lab/Projects/ABCD_Control_Energy/'
data_dir = working_dir + 'data/activation/'
parc_dir = working_dir + 'data/parcellation/'
os.chdir(data_dir)

nback_map = ['2-back_vs._0-back']
output_file = ['ABCD_2Back_0Back_452']
task_list = ['2-back_vs_0-back']

# get the schaefer2018_200Parcels7Networks with fsaverage 164k
schaefer_fsaverage = nntdata.fetch_schaefer2018('fsaverage')['200Parcels7Networks']
lh_schaefer_fsaverage, rh_schaefer_fsaverage = schaefer_fsaverage

# get the subcortical atlas and resample to the activation data
subcort_atlas = nib.load(parc_dir + 'tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg.nii.gz')
subcort_roi_label = pd.read_csv(parc_dir + 'tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg.tsv', sep='\t')

activation_img = nib.load(data_dir + '0-back vs. fixation_subcort.nii.gz')
subcort_atlas = resample_to_img(subcort_atlas, activation_img,interpolation='nearest')

subcort_atlas = subcort_atlas.get_fdata()
subcort_labels = np.unique(subcort_atlas)

# put the RH_CIT168Subcortical before LH_CIT168Subcortical
index_ranges = [(0, 1), (15, 29), (1, 15), (29, 53)]
subcort_labels = np.concatenate([subcort_labels[start:end] for start, end in index_ranges])

for i in range(3):    
    data_name = nback_map[i]
    task_name = task_list[i]
    out_name = output_file[i]
    print('Get the task activation of ' + data_name)
    
    # get the activation data [0-back vs. fixation]
    surf_map_lh = data_dir + data_name + '_lh.nii.gz'
    lh_data = load_surf_data(surf_map_lh);

    surf_map_rh = data_dir + data_name + '_rh.nii.gz'
    rh_data = load_surf_data(surf_map_rh);

    cortex_activation = np.concatenate([lh_data, rh_data], axis=0)

    cortex_mean_activations = vertices_to_parcels(cortex_activation,
                                                             lhannot = lh_schaefer_fsaverage,
                                                             rhannot = rh_schaefer_fsaverage)

    # get the subcortical activation
    subcort_map = data_dir + data_name + '_subcort.nii.gz'
    subcort_img = nib.load(subcort_map)
    subcort_acitvation = subcort_img.get_fdata()

    subcort_mean_activations = []

    for label in subcort_labels:
        # Exclude zero label (background)
        if label != 0:
            region_voxels = np.where(subcort_atlas == label)
            region_activation = subcort_acitvation[region_voxels]
            mean_activation = np.mean(region_activation)
            subcort_mean_activations.append(mean_activation)
            
    # Combine cortex and subcortex data
    brain_mean_activations = np.concatenate([cortex_mean_activations, subcort_mean_activations], axis=0)

    out_activation_txt = data_dir + out_name + '.txt'
    np.savetxt(out_activation_txt, brain_mean_activations)
    
    out_activation_mat = data_dir + out_name + '.mat'
    scipy.io.savemat(out_activation_mat, {out_name: brain_mean_activations})

    #%% transform from fsaverage 164k to fsLR32k

    # get any template from neuromaps
    abagen = fetch_annotation(source='abagen')
    fsaverage = transforms.fsaverage_to_fsaverage(abagen, '164k')
    fsaverage_lh, fsaverage_rh = fsaverage

    # replace with the activation data
    fsaverage_lh.darrays[0].data = lh_data
    fsaverage_rh.darrays[0].data = rh_data

    fsaverage_new = fsaverage_lh,fsaverage_rh

    # transform from fsaverage 164k to fsLR32k
    fslr = transforms.fsaverage_to_fslr(fsaverage_new, '32k')
    fslr_lh, fslr_rh = fslr
    
    fslr_lh_func_gii = data_dir + task_name + '_space-fsLR_den-32k_hemi-L.func.gii'
    fslr_rh_func_gii = data_dir + task_name + '_space-fsLR_den-32k_hemi-R.func.gii'

    nib.save(fslr_lh, fslr_lh_func_gii)
    nib.save(fslr_rh, fslr_rh_func_gii)

    # combine func.gii to dscalar.nii
    import subprocess

    def run_workbench_command(command):
        try:
            # Run the command and capture the output
            output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
            print(output.decode("utf-8"))  # Decode bytes to string and print the output
        except subprocess.CalledProcessError as e:
            # Handle errors
            print("Error:", e.output.decode("utf-8"))  # Decode bytes to string and print the error output
            
    fslr_dscalar = data_dir + task_name + '_32k_fs_LR.dscalar.nii'

    command = ("wb_command -cifti-create-dense-scalar " + fslr_dscalar + 
               " -left-metric " + fslr_lh_func_gii + " -right-metric " + fslr_rh_func_gii)
    print(command)

    run_workbench_command(command)



