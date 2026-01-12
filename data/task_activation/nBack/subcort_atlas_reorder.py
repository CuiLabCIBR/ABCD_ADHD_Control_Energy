locals().clear()

import nibabel as nib
import numpy as np
import pandas as pd
import os

working_dir = 'F:/Cui_Lab/Projects/ABCD_ADHD_Control_Energy/'
data_dir = working_dir + 'data/task_activation/nBack/'
parc_dir = working_dir + 'data/parcellation/'
os.chdir(data_dir)

subcort_atlas = nib.load(parc_dir + 'tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg.nii.gz')
subcort_roi_label = pd.read_csv(parc_dir + 'tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg.tsv', sep='\t')

subcort_data = subcort_atlas.get_fdata()
subcort_labels = np.unique(subcort_data)

# put the RH_CIT168Subcortical before LH_CIT168Subcortical
index_ranges = [(0, 1), (15, 29), (1, 15), (29, 53)]
subcort_labels = np.concatenate([subcort_labels[start:end] for start, end in index_ranges])

subcort_data_new = subcort_data.copy()

for i, roi_old in enumerate(subcort_labels):
    idx = np.where(subcort_data == roi_old)
    subcort_data_new[idx] = i  # Assign new indices
    
subcort_atlas_new = nib.Nifti1Image(subcort_data_new, affine = subcort_atlas.affine, header = subcort_atlas.header)
subcort_img = parc_dir + "tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg_reorder.nii.gz"
nib.save(subcort_atlas_new, subcort_img)