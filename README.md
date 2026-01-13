# ABCD_ADHD_Control_Energy

Code and data accompanying the manuscript: **“Structural network control of working memory state transitions reveals divergent developmental biotypes in childhood ADHD.”**


## Abstract

Altered white-matter connectivity and atypical working-memory–related brain activation have been reported in attention-deficit/hyperactivity disorder (ADHD), yet how disruptions in structural brain networks constrain working-memory state transitions in ADHD remains unclear. How such network control mechanisms relate to developmental heterogeneity and symptom trajectories has not been established. Here, we combined network control theory with normative modeling to examine how network topology supports working-memory state transitions in **4,281** children (**621** with ADHD). Using diffusion MRI–derived structural connectomes, we estimated the control energy required to transition between working-memory states defined by task-fMRI activation. Normative models trained in typically developing children generated individualized deviation maps of regional control energy, revealing pronounced inter-individual heterogeneity in ADHD. Clustering analysis revealed divergent network control regimes, with one biotype showing lower-than-expected energy demands and another showing globally elevated energy requirements accompanied by more severe attention and externalizing symptoms. Both biotypes showed symptom improvement and normalization of control-energy deviations over two years, with coupling between reductions in control-energy deviation and symptom improvement specific to the high-energy biotype. These findings suggest that heterogeneity in childhood ADHD reflects divergent white-matter network mechanisms constraining working-memory state transitions during development, with direct relevance to symptom trajectories.

## `data`

- The [sub_info](data/sub_info) folder contains the subject information used in this study. 
- The [control_energy](data/control_energy) folder contains the harmonized regional control energy the ABCD, saved in the `.csv` file.
- The [task_activation](data/task_activation) folder contains the Emotional n-Back task fMRI activation map derived from the ABCD study (https://github.com/sahahn/ABCD_Consortium_Analysis/tree/master/Nifti_Maps/nBack/Activations).
- The [parcellation](data/parcellation) folder contains the parcellation files (`Schaefer-400`/`Schaefer-200` with 52 subcortical regions) used in this study (https://github.com/PennLINC/AtlasPack).


## `functions`

The [`functions/`](functions) folder contains R and MATLAB functions required to run the analyses and reproduce the figures in this study.


## `code`

### `step_01_nm_sample_construction`

Scripts for screening participants and splitting them into **training** and **test** sets.

1. `step_01_check_dwi_preprocessing.m`
   - Identify scans with completed DWI preprocessing and structural-network reconstruction.
   - Load QC metrics including head motion and total network strength.
   - Exclude scans containing isolated brain regions (disconnected nodes).

2. `step_02_abcd_adhd_td_dwi_demo.qmd`
   - Identify ADHD and typically developing controls (TDC) based on the parent-reported computerized Kiddie Schedule for Affective Disorders and Schizophrenia (**KSADS-COMP**, DSM-5).
   - Exclude scans based on imaging criteria:
     - Not recommended for inclusion after official ABCD QC
     - Failed preprocessing or reconstruction
     - Structural networks with isolated regions (flagged by `step_01_check_dwi_preprocessing.m`)
     - Excessive head motion (**FD > mean + 3 × SD**)
   - Exclude participants based on demographic/site criteria:
     - Missing or invalid age, sex, or handedness
     - Sites with fewer than **10 TDCs** for a given sex
     - ADHD participants with only **2-year follow-up** data

3. `step_03_normative_modelling_samples.qmd`
   - Split eligible scans into training and test sets.
   - For the baseline test set, match ADHD participants to TDC participants.
   - Visualize age/sex distributions and generate participant summary tables for each group.


### `step_02_control_energy_calc`

Estimate the **control energy** required to transition between working-memory states defined by task-fMRI activation, using diffusion MRI–derived **structural connectomes**.

1. `step_01_batch_EnergyCal.sh`
   - Batch-compute control energy for each scan.
   - Calls `EnergyCal.sh` and `EnergyCal_Sub.m`.

2. `step_02_MergeEnergy.m`
   - Aggregate control-energy outputs across all scans.
   - Save a single CSV file for ComBat harmonization.

3. `step_03_combat.R`
   - Harmonize control-energy measures across sites using **ComBat**.
   - Save harmonized results to a new CSV file.

4. `step_04_batch_NullNetworks.sh`
   - Generate **101 degree- and strength-preserving null networks** per scan using `null_model_und_sign` from the Brain Connectivity Toolbox (BCT):  
     https://sites.google.com/site/bctnet/
   - Compute control energy for each null network.
   - Calls `NullNetworks.sh` and `EnergyCal_Sub_Null.m`.

5. `step_05_MergeEnergy_null.m`
   - For each null-network iteration, merge results across scans.
   - Save per-iteration CSV files for ComBat harmonization.

6. `step_06_combat_null.R`
   - Apply ComBat harmonization to null-network control-energy outputs.
   - Save harmonized null results to new CSV files.

7. `step_07_plot_energy_results.qmd`
   - Visualize task activation for working memory using the contrast **[2-back − 0-back]**.
   - Plot regional control-energy maps for baseline test TDC and ADHD groups.
   - Compare whole-brain control energy between the empirical network and null networks in the baseline test TDC group.


### `step_03_energy_deviation`

Build a normative model of control energy, estimate individual deviations, and identify two ADHD biotypes.

1. `step_01_adhd_energy_deviation_biotype.qmd`
   - Construct a normative model (W-scores) using the training TDC group.
   - Estimate individual deviation scores in the test set.
   - Define extreme deviations (**|W| > 2.6**) and visualize regional extreme-deviation maps.
   - Perform ADHD biotyping using **k-means clustering**, resulting in two ADHD biotypes.
   - Conduct case–control comparisons between each ADHD biotype and matched TDC participants.
   - Perform between-biotype comparisons in CBCL attention/externalizing symptoms and extreme-deviation measures of control energy.

2. `step_02_energy_deviation_null_network.qmd`
   - Construct the normative model using empirical-network control energy in the training TDC group.
   - Compute deviation scores in the test set using control energy estimated from null networks.

3. `step_03_energy_deviation_null_network_stats.qmd`
   - For each of the **101 null networks**, compare each ADHD biotype against matched TDC participants to generate a null distribution of case–control differences.
   - Extract the median of the null distribution and report biotype–control group differences.


### `step_04_longitudinal_changes`

Because ADHD symptoms often diminish across adolescence, we examined whether longitudinal changes in clinical symptoms over a **two-year follow-up** were accompanied by corresponding changes in control-energy deviations.

1. `step_01_adhd_cbcl_longitudinal_change.qmd`
   - Quantify longitudinal changes in **CBCL attention** and **externalizing** symptoms within each ADHD biotype.

2. `step_02_adhd_nBack_energy_deviation_longitudinal.qmd`
   - Quantify longitudinal changes in **whole-brain control-energy deviation** within each biotype.
   - Assess brain–behavior relationships by correlating symptom change with change in control-energy deviation.

3. `step_03_adhd_nBack_energy_deviation_longitudinal_null.qmd`
   - Using **101 degree- and strength-preserving null networks**:
     - Generate a null distribution of longitudinal changes in whole-brain control-energy deviation for each biotype, extract the median, and report longitudinal group differences.
     - Generate a null distribution for correlations between symptom change and control-energy deviation change, extract the median, and report brain–behavior associations.


### `step_05_validation_analyses`

Because biotype assignment underlies all downstream analyses, we performed a series of robustness checks to evaluate the stability of ADHD biotype identification. For each validation analysis, biotype assignments were compared with the primary clustering solution using the **adjusted Rand index (ARI)**.

1. `step_01_adhd_energy_deviation_biotype_site_validation.qmd`
   - Assess robustness to site-related variability using **leave-one-site-out** validation.
   - Data from each of the **21 ABCD acquisition sites** were excluded in turn, and clustering was repeated on the remaining participants.

2. `step_02_adhd_energy_deviation_biotype_bootstrap_validation.qmd`
   - Assess robustness to sample selection using **bootstrap resampling**.
   - Randomly subsample **80% of ADHD participants** and repeat clustering **1,000 times**.

3. `step_03_adhd_energy_deviation_biotype_spectral_validation.qmd`
   - Assess robustness to clustering methodology using an alternative algorithm (**spectral clustering**).

4. `step_04_adhd_energy_deviation_biotype_atlas_validation.qmd`
   - Assess robustness to brain parcellation using an alternative atlas (**Schaefer-200**).

5. `step_05_adhd_energy_deviation_biotype_full_sample_validation.qmd`
   - Evaluate the influence of longitudinal data structure in normative modeling by retaining all available training scans and treating them as independent observations.

