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
subcort_roi_label = pd.read_csv(parc_dir + 'tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg.tsv', sep = '\t')

subcort_data = np.rint(subcort_atlas.get_fdata()).astype(np.int16)
subcort_labels = np.unique(subcort_data)

# Put the RH_CIT168Subcortical before LH_CIT168Subcortical
index_ranges = [(0, 1), (15, 29), (1, 15), (29, 53)]
subcort_labels_reorder = np.concatenate([subcort_labels[start:end] for start, end in index_ranges])

subcort_data_new = np.zeros_like(subcort_data, dtype = np.int16)

for i, roi_old in enumerate(subcort_labels_reorder):
    subcort_data_new[subcort_data == roi_old] = i

header = subcort_atlas.header.copy()
header.set_data_dtype(np.int16)

subcort_atlas_new = nib.Nifti1Image(
    subcort_data_new,
    affine = subcort_atlas.affine,
    header = header
)

subcort_img = parc_dir + "tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg_reorder.nii.gz"
nib.save(subcort_atlas_new, subcort_img)