# ABCD_ADHD_Control_Energy

Code and data accompanying the manuscript **“Structural network control of working-memory state transitions reveals divergent developmental biotypes in childhood ADHD.”**

## Abstract

Altered white-matter connectivity and atypical working-memory-related brain activation have been reported in attention-deficit/hyperactivity disorder (ADHD), yet how disruptions in structural brain networks constrain working-memory state transitions in ADHD remains unclear. How these network-control mechanisms relate to developmental heterogeneity and symptom trajectories has also not been established. Here, we combined network control theory with normative modeling to examine how network topology supports working-memory state transitions in 4,281 children, including 621 children with ADHD. Using diffusion MRI-derived structural connectomes, we estimated the control energy required to transition between working-memory states defined by task-fMRI activation. Normative models trained in typically developing children generated individualized maps of regional control-energy deviations, revealing pronounced interindividual heterogeneity in ADHD. Clustering identified two divergent network-control regimes: one biotype showed lower-than-expected energy demands, whereas the other showed globally elevated energy requirements accompanied by more severe attention and externalizing problems. Both biotypes showed symptom improvement and normalization of control-energy deviations over two years. Coupling between reductions in control-energy deviation and symptom improvement was specific to the high-energy biotype. These findings suggest that heterogeneity in childhood ADHD reflects divergent white-matter network mechanisms that constrain working-memory state transitions during development and are relevant to longitudinal symptom trajectories.

## Software and system requirements

### Diffusion and structural MRI preprocessing

- [FreeSurfer v7.1.1](https://surfer.nmr.mgh.harvard.edu/)
- [QSIPrep v0.16.0](https://qsiprep.readthedocs.io/)
- Operating system: Linux

### Postprocessing and statistical analysis

- [Connectome Workbench v2.0.1](https://www.humanconnectome.org/software/connectome-workbench)
- [R v4.2.3](https://www.r-project.org/)
- MATLAB R2023a
- Operating systems: Windows and Linux

Installation instructions and detailed system requirements are available on the respective software websites.

## Data

- The [`data/sub_info/`](data/sub_info) directory contains the participant information used in the analyses.
- The [`data/control_energy/`](data/control_energy) directory contains harmonized regional control-energy estimates for the ABCD sample in CSV format.
- The [`data/task_activation/`](data/task_activation) directory contains the emotional n-back task-fMRI activation map derived from the ABCD Study. The original statistical maps are available from the [ABCD Consortium Analysis repository](https://github.com/sahahn/ABCD_Consortium_Analysis/tree/master/Nifti_Maps/nBack/Activations).
- The [`data/parcellation/`](data/parcellation) directory contains the Schaefer-400 and Schaefer-200 cortical parcellations combined with 52 subcortical regions. The source atlases are available from [AtlasPack](https://github.com/PennLINC/AtlasPack).

## Functions

The [`functions/`](functions) directory contains the R and MATLAB functions required to run the analyses and reproduce the figures.

## Code

The analysis scripts are organized according to the main stages of the workflow.

### `step_01_nm_sample_construction`

Scripts for participant screening and construction of the normative-model training and independent test samples.

1. `step_01_check_dwi_preprocessing.m`
   - Identify scans with completed diffusion MRI preprocessing and structural-network reconstruction.
   - Load quality-control measures, including head motion and total network strength.
   - Flag and exclude structural networks containing isolated or disconnected regions.

2. `step_02_abcd_adhd_td_dwi_demo.qmd`
   - Identify children with ADHD and typically developing controls (TDCs) using the parent-reported computerized Kiddie Schedule for Affective Disorders and Schizophrenia (KSADS-COMP; DSM-5).
   - Apply imaging exclusion criteria:
     - Not recommended for inclusion according to the official ABCD quality-control criteria.
     - Failed preprocessing or structural-network reconstruction.
     - Structural networks containing isolated regions, as identified by `step_01_check_dwi_preprocessing.m`.
     - Excessive head motion, defined as framewise displacement (FD) greater than the sample mean plus three standard deviations.
   - Apply demographic and site-related exclusion criteria:
     - Missing or invalid age, sex, or handedness information.
     - Acquisition sites with fewer than 10 TDC participants for a given sex.
     - ADHD participants with usable data only at the two-year follow-up.

3. `step_03_normative_modelling_samples.qmd`
   - Divide eligible scans into the normative-model training set and the independent test set.
   - Assign all ADHD participants to the test set.
   - Match baseline ADHD participants 1:1 to baseline TDC participants on age, sex, handedness, mean FD, total brain volume, and total network strength.
   - For TDC participants with data at both waves, randomly retain one scan in the training set.
   - Visualize age and sex distributions and generate participant-level summary tables.

### `step_02_control_energy_calc`

Scripts for estimating the control energy required to transition between working-memory-related brain states using diffusion MRI-derived structural connectomes.

1. `step_01_batch_EnergyCal.sh`
   - Batch-compute regional control energy for each scan.
   - Call `EnergyCal.sh` and `EnergyCal_Sub.m`.

2. `step_02_MergeEnergy.m`
   - Aggregate scan-level control-energy outputs.
   - Save the combined results as a CSV file for ComBat harmonization.

3. `step_03_combat.R`
   - Harmonize regional control-energy estimates across acquisition sites using ComBat.
   - Save the harmonized estimates as a new CSV file.

4. `step_04_batch_NullNetworks.sh`
   - Generate 101 degree- and strength-preserving null networks for each scan using `null_model_und_sign` from the [Brain Connectivity Toolbox](https://sites.google.com/site/bctnet/).
   - Compute regional control energy for each null network.
   - Call `NullNetworks.sh` and `EnergyCal_Sub_Null.m`.

5. `step_05_MergeEnergy_null.m`
   - Merge scan-level results separately for each null-network iteration.
   - Save one CSV file per iteration for ComBat harmonization.

6. `step_06_combat_null.R`
   - Apply ComBat harmonization to the null-network control-energy estimates.
   - Save the harmonized null-network results.

7. `step_07_plot_energy_results.qmd`
   - Visualize the group-level working-memory activation contrast (2-back minus 0-back) used to define the target state.
   - Plot regional control-energy maps for the baseline test TDC and ADHD groups.
   - Compare whole-brain control energy between empirical and null structural networks in the baseline test TDC group.

### `step_03_energy_deviation`

Scripts for normative modeling of control energy, estimation of individualized deviations, and identification of ADHD biotypes.

1. `step_01_adhd_energy_deviation_biotype.qmd`
   - Fit regional normative models in the TDC training sample and calculate W-score deviations in the independent test sample.
   - Define extreme regional deviations using `|W| > 2.6` and visualize their spatial distribution.
   - Evaluate candidate cluster solutions and identify ADHD biotypes using K-means clustering.
   - Compare each ADHD biotype with its matched TDC group at regional, network, and whole-brain levels.
   - Compare ADHD-1 and ADHD-2 in CBCL attention problems, externalizing problems, and control-energy deviation measures.

2. `step_02_energy_deviation_null_network.qmd`
   - Fit normative models using empirical-network control energy in the TDC training sample.
   - Calculate test-sample deviation scores using control energy derived from degree- and strength-preserving null networks.

3. `step_03_energy_deviation_null_network_stats.qmd`
   - For each of the 101 null-network iterations, compare each ADHD biotype with its matched TDC group.
   - Construct null distributions of case-control effects.
   - Extract the median null effect and compare the empirical biotype-control differences with the null-network results.

### `step_04_longitudinal_changes`

Scripts for testing whether two-year changes in ADHD symptoms are accompanied by changes in control-energy deviations.

1. `step_01_adhd_cbcl_longitudinal_change.qmd`
   - Quantify two-year changes in CBCL attention and externalizing problem scores within each ADHD biotype.

2. `step_02_adhd_nBack_energy_deviation_longitudinal.qmd`
   - Quantify two-year changes in whole-brain control-energy deviation within each biotype.
   - Test longitudinal brain-behavior associations between changes in symptoms and changes in whole-brain control-energy deviation.

3. `step_03_adhd_nBack_energy_deviation_longitudinal_null.qmd`
   - Use 101 degree- and strength-preserving null networks to construct null distributions for:
     - Longitudinal changes in whole-brain control-energy deviation within each biotype.
     - Correlations between changes in symptoms and changes in whole-brain control-energy deviation.
   - Extract the median null result and compare it with the corresponding empirical-network result.

### `step_05_additional_analyses`

Scripts for supplementary analyses of subcortical results, head motion, clinical characteristics, attrition, and biotype robustness.

#### Subcortical analyses

1. `FigS3&4_plot_subcortex_results.py`
   - Plot subcortical task activation and control energy.
   - Visualize extreme deviations, biotype deviation maps, and biotype–TDC differences.

#### Head-motion sensitivity analyses

2. `FigS6_motion_effects.qmd`
   - Test the association between baseline mean FD and whole-brain energy deviation.
   - Refit normative models using a motion-matched TDC training set.
   - Reassess extreme-deviation overlap and within-participant map similarity.

3. `FigS6_motion_effects_longitudinal.qmd`
   - Test the association between longitudinal changes in mean FD and energy deviation.

#### Clinical characterization

4. `FigS8_adhd_presentation_biotype_analysis.qmd`
   - Compare ADHD diagnostic labels and DSM-5 presentations between biotypes.
   - Compare dimensional inattention and hyperactivity/impulsivity scores.

#### Attrition analysis

5. `FigS9_drop_out_validation.qmd`
   - Compare baseline diagnostic, clinical, and energy-deviation measures between completers and dropouts.
   - Assess whether attrition may bias the longitudinal findings.

#### Biotype robustness analyses

Alternative biotype solutions were compared with the primary solution using the adjusted Rand index (ARI).

6. `FigS10_biotype_site_validation.qmd`
   - Perform leave-one-site-out validation across 21 ABCD sites.
7. `FigS10_biotype_bootstrap_validation.qmd`
   - Repeat clustering in 1,000 random 80% subsamples.
8. `FigS11&12_biotype_spectral_validation.qmd`
   - Repeat biotype identification using spectral clustering.
9. `FigS11&12_biotype_atlas_validation.qmd`
   - Repeat the analyses using the Schaefer-200 atlas.
10. `FigS11&12_biotype_full_sample_validation.qmd`
    - Repeat normative modeling using all available TDC training scans.
11. `FigS11&12_biotype_gam_validation.qmd`
    - Model nonlinear age effects using generalized additive models.
12. `FigS11&12_biotype_state_validation.qmd`
    - Use the 0-back activation map as the initial state and the 2-back activation map as the target state.
