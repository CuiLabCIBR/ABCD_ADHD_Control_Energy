import matplotlib.colors as mcolors
from nilearn import plotting

import nibabel as nib
import numpy as np
import pandas as pd
import os

working_dir = 'F:/Cui_Lab/Projects/ABCD_ADHD_Control_Energy/'
data_dir = working_dir + 'data/task_activation/nBack/'
parc_dir = working_dir + 'data/parcellation/'

colors = ["#2C678C", "#4393C3", "#92C5DE", "#D1E5F0",
          "#F7F7F7", "#FDDBC7", "#F4A582", "#D6604D", "#A63726"]

cmap = mcolors.LinearSegmentedColormap.from_list("custom_cmap", colors, N=256)

subcort_atlas_file = parc_dir + "tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg.nii.gz"
subcort_atlas_img = nib.load(subcort_atlas_file)
subcort_atlas_data = subcort_atlas_img.get_fdata()

###
label_table_file = parc_dir + "SubcorticalMerged_nii_to_dwi.csv"
label_table = pd.read_csv(label_table_file)

index_to_dwi = dict(zip(label_table["index"], label_table["index_dwi"]))

subcort_atlas_data_int = np.rint(subcort_atlas_data).astype(int)
subcort_atlas_dwi_data = np.zeros_like(subcort_atlas_data_int, dtype = np.int16)

for old_index, new_index in index_to_dwi.items():
    subcort_atlas_dwi_data[subcort_atlas_data_int == old_index] = new_index

subcort_dwi_img = nib.Nifti1Image(
    subcort_atlas_dwi_data,
    affine = subcort_atlas_img.affine,
    header = subcort_atlas_img.header
)

subcort_dwi_img.set_data_dtype(np.int16)

out_nii_file = parc_dir + "tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg_dwi.nii.gz"
nib.save(subcort_dwi_img, out_nii_file)
