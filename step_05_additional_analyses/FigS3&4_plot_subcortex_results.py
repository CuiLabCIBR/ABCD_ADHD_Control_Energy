import matplotlib.colors as mcolors
from nilearn import plotting

import nibabel as nib
import numpy as np
import pandas as pd
import os


# =========================
# Set paths
# =========================

working_dir = 'F:/Cui_Lab/Projects/ABCD_ADHD_Control_Energy/'
data_dir = working_dir + 'data/task_activation/nBack/'
parc_dir = working_dir + 'data/parcellation/'
plot_dir = working_dir + 'results/plots/all0In_2Back0Back/subcortex/'

os.chdir(data_dir)
os.chdir(plot_dir)

subcort_atlas_file = parc_dir + "tpl-MNI152NLin6Asym_atlas-SubcorticalMerged_res-01_dseg_dwi.nii.gz"

# %%
# ============================================================
# 2. Colormaps
# ============================================================

# Positive percentage: white -> red
cmap_r = mcolors.LinearSegmentedColormap.from_list(
    "positive_deviation_pct",
    ["#F7F7F7", "#FDDBC7", "#F4A582", "#D6604D", "#A63726"],
    N=256
)

# Negative percentage: white -> blue
cmap_b = mcolors.LinearSegmentedColormap.from_list(
    "negative_deviation_pct",
    ["#F7F7F7", "#D1E5F0", "#92C5DE", "#4393C3", "#2C678C"],
    N=256
)

# Diverging: blue -> white -> red
cmap = mcolors.LinearSegmentedColormap.from_list(
    "blue_white_red",
    [
        "#2C678C", "#4393C3", "#92C5DE", "#D1E5F0",
        "#F7F7F7",
        "#FDDBC7", "#F4A582", "#D6604D", "#A63726"
    ],
    N=256
)


# %%
# =========================
# Define function
# =========================

def plot_subcortex_values(
    values_52,
    atlas_file,
    threshold = 0.2,
    colorbar = False,
    cmap = None,
    vmin = -0.4,
    vmax = 0.4,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    output_file = None,
    save_nii_file = None,
    dpi = 1200
):
    atlas_img = nib.load(atlas_file)
    atlas_data = np.rint(atlas_img.get_fdata()).astype(int)

    values_52 = np.asarray(values_52).reshape(-1)

    if len(values_52) != 52:
        raise ValueError(f"Expected 52 values, got {len(values_52)}.")

    subcort_data = np.zeros_like(atlas_data, dtype = np.float32)

    for roi_id, value in zip(range(1, 53), values_52):
        subcort_data[atlas_data == roi_id] = value

    header = atlas_img.header.copy()
    header.set_data_dtype(np.float32)

    subcort_img = nib.Nifti1Image(
        subcort_data,
        affine = atlas_img.affine,
        header = header
    )

    if save_nii_file is not None:
        nib.save(subcort_img, save_nii_file)

    display = plotting.plot_glass_brain(
        subcort_img,
        title = title,
        threshold = threshold,
        colorbar = colorbar,
        cmap = cmap,
        vmin = vmin,
        vmax = vmax,
        display_mode = display_mode,
        plot_abs = plot_abs
    )

    if output_file is not None:
        display.savefig(output_file, dpi = dpi)
        display.close()

    return display


# %%
# =========================
# 1. WM activation
# =========================

nback_activation_file = data_dir + "ABCD_2Back_0Back_452.txt"

nback_activation = np.loadtxt(nback_activation_file)
subcort_values = np.asarray(nback_activation).reshape(-1)[-52:]


plot_subcortex_values(
    values_52 = subcort_values,
    atlas_file = subcort_atlas_file,
    threshold = 0,
    colorbar = False,
    cmap = cmap,
    vmin = -0.25,
    vmax = 0.25,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    save_nii_file = plot_dir + "ABCD_2Back_0Back_subcortex.nii.gz",
    output_file = plot_dir + "ABCD_2Back_0Back_subcortex.png"
)

# %%
# =========================
# 2. TDC controk energy
# =========================

test_td_0y_energy_file = plot_dir + "test_td_0y_energy_log.csv"

test_td_0y_energy = pd.read_csv(test_td_0y_energy_file)
subcort_values = test_td_0y_energy.values.reshape(-1)
print(min(subcort_values))
print(max(subcort_values))

plot_subcortex_values(
    values_52 = subcort_values,
    atlas_file = subcort_atlas_file,
    threshold = 0,
    colorbar = False,
    cmap = cmap,
    vmin = -10,
    vmax = 0,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    save_nii_file = plot_dir + "test_td_0y_energy_subcortex.nii.gz",
    output_file = plot_dir + "test_td_0y_energy_subcortex.png"
)

# %%
# =========================
# 3. ADHD controk energy
# =========================

test_adhd_0y_energy_file = plot_dir + "test_adhd_0y_energy_log.csv"

test_adhd_0y_energy = pd.read_csv(test_adhd_0y_energy_file)
subcort_values = test_adhd_0y_energy.values.reshape(-1)
print(min(subcort_values))
print(max(subcort_values))

plot_subcortex_values(
    values_52 = subcort_values,
    atlas_file = subcort_atlas_file,
    threshold = 0,
    colorbar = False,
    cmap = cmap,
    vmin = -10,
    vmax = 0,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    save_nii_file = plot_dir + "test_adhd_0y_energy_subcortex.nii.gz",
    output_file = plot_dir + "test_adhd_0y_energy_subcortex.png"
)


# %%
# =========================
# 4. ADHD negative extreme deviation
# =========================
adhd_neg_deviation_pct_file = plot_dir + "adhd_neg_deviation_pct.csv"

adhd_neg_deviation_pct = pd.read_csv(adhd_neg_deviation_pct_file)
subcort_values = adhd_neg_deviation_pct.values.reshape(-1)
print(min(subcort_values))
print(max(subcort_values))

plot_subcortex_values(
    values_52 = subcort_values,
    atlas_file = subcort_atlas_file,
    threshold = 0,
    colorbar = False,
    cmap = cmap_b,
    vmin = 0,
    vmax = 4,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    save_nii_file = plot_dir + "adhd_neg_deviation_pct_subcortex.nii.gz",
    output_file = plot_dir + "adhd_neg_deviation_pct_subcortex.png"
)

# %%
# =========================
# 5. ADHD positive extreme deviation
# =========================
adhd_pos_deviation_pct_file = plot_dir + "adhd_pos_deviation_pct.csv"

adhd_pos_deviation_pct = pd.read_csv(adhd_pos_deviation_pct_file)
subcort_values = adhd_pos_deviation_pct.values.reshape(-1)
print(min(subcort_values))
print(max(subcort_values))

plot_subcortex_values(
    values_52 = subcort_values,
    atlas_file = subcort_atlas_file,
    threshold = 0,
    colorbar = False,
    cmap = cmap_r,
    vmin = 0,
    vmax = 6,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    save_nii_file = plot_dir + "adhd_pos_deviation_pct_subcortex.nii.gz",
    output_file = plot_dir + "adhd_pos_deviation_pct_subcortex.png"
)


# %%
# =========================
# 6. ADHD-1 deviation map
# =========================
adhd1_0y_deviation_roi_file = plot_dir + "adhd1_0y_deviation_roi.csv"

adhd1_0y_deviation_roi = pd.read_csv(adhd1_0y_deviation_roi_file)
subcort_values = adhd1_0y_deviation_roi.values.reshape(-1)
print(min(subcort_values))
print(max(subcort_values))

plot_subcortex_values(
    values_52 = subcort_values,
    atlas_file = subcort_atlas_file,
    threshold = 0,
    colorbar = False,
    cmap = cmap,
    vmin = -0.8,
    vmax = 0.8,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    save_nii_file = plot_dir + "adhd1_0y_deviation_roi_subcortex.nii.gz",
    output_file = plot_dir + "adhd1_0y_deviation_roi_subcortex.png"
)


# %%
# =========================
# 7. ADHD-1 deviation map
# =========================
adhd2_0y_deviation_roi_file = plot_dir + "adhd2_0y_deviation_roi.csv"

adhd2_0y_deviation_roi = pd.read_csv(adhd2_0y_deviation_roi_file)
subcort_values = adhd2_0y_deviation_roi.values.reshape(-1)
print(min(subcort_values))
print(max(subcort_values))

plot_subcortex_values(
    values_52 = subcort_values,
    atlas_file = subcort_atlas_file,
    threshold = 0,
    colorbar = False,
    cmap = cmap,
    vmin = -0.8,
    vmax = 0.8,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    save_nii_file = plot_dir + "adhd2_0y_deviation_roi_subcortex.nii.gz",
    output_file = plot_dir + "adhd2_0y_deviation_roi_subcortex.png"
)


# %%
# =========================
# 8. ADHD-1 vs TDC-1
# =========================
biotype1_energy_roi_stats_file = plot_dir + "biotype1_energy_roi_stats.csv"

biotype1_energy_roi_stats = pd.read_csv(biotype1_energy_roi_stats_file)
subcort_values = biotype1_energy_roi_stats["Cohens_d"].values[-52:]
print(min(subcort_values))
print(max(subcort_values))

plot_subcortex_values(
    values_52 = subcort_values,
    atlas_file = subcort_atlas_file,
    threshold = 0,
    colorbar = False,
    cmap = cmap,
    vmin = -0.8,
    vmax = 0.8,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    save_nii_file = plot_dir + "biotype1_energy_roi_stats_subcortex.nii.gz",
    output_file = plot_dir + "biotype1_energy_roi_stats_subcortex.png"
)

# %%
# =========================
# 9. ADHD-2 vs TDC-2
# =========================
biotype2_energy_roi_stats_file = plot_dir + "biotype2_energy_roi_stats.csv"

biotype2_energy_roi_stats = pd.read_csv(biotype2_energy_roi_stats_file)
subcort_values = biotype2_energy_roi_stats["Cohens_d"].values[-52:]
print(min(subcort_values))
print(max(subcort_values))

plot_subcortex_values(
    values_52 = subcort_values,
    atlas_file = subcort_atlas_file,
    threshold = 0,
    colorbar = False,
    cmap = cmap,
    vmin = -0.8,
    vmax = 0.8,
    display_mode = "lyrz",
    title = "",
    plot_abs = False,
    save_nii_file = plot_dir + "biotype2_energy_roi_stats_subcortex.nii.gz",
    output_file = plot_dir + "biotype2_energy_roi_stats_subcortex.png"
)
