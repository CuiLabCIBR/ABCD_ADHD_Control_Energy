# ABCD_ADHD_Control_Energy

Code and data accompanying the manuscript **“Structural network control of working memory state transitions reveals divergent developmental biotypes in childhood ADHD.”**



## Abstract

Altered white matter connectivity and atypical working memory related brain activation have been reported in attention-deficit/hyperactivity disorder (ADHD), yet how disruptions in structural brain networks constrain working memory state transitions in ADHD remains unclear. How such network control mechanisms relate to developmental heterogeneity and symptom trajectories has not been established. Here we combined network control theory with normative modeling to examine how network topology supports working memory state transitions in 4,281 children (621 with ADHD). Using diffusion MRI derived structural connectomes, we estimated the control energy required to transition between working memory states defined by task fMRI activation. Normative models trained in typically developing children generated individualized deviation maps of regional control energy, revealing pronounced inter-individual heterogeneity in ADHD. Clustering analysis revealed divergent network control regimes, with one biotype showing lower than expected energy demands and another showing globally elevated energy requirements accompanied by more severe attention and externalizing symptoms. Both biotypes showed symptom improvement and normalization of control energy deviations over two years, with coupling between reductions in control energy deviation and symptom improvement specific to high-energy biotype. These findings reveal that heterogeneity in childhood ADHD reflects divergent white matter network mechanisms constraining working memory state transitions during development, with direct relevance to symptom trajectories.



## `data`

- The [sub_info](data/sub_info) folder contains the subject information used in this study. 
- The [control_energy](data/control_energy) folder contains the harmonized regional control energy the ABCD, saved in the `.csv` file.
- The [task_activation](data/task_activation) folder contains the Emotional n-Back task fMRI activation map derived from the ABCD study (https://github.com/sahahn/ABCD_Consortium_Analysis/tree/master/Nifti_Maps/nBack/Activations).
- The [parcellation](data/parcellation) folder contains the parcellation files (`Schaefer-400`/`Schaefer-200` with 52 subcortical regions) used in this study (https://github.com/PennLINC/AtlasPack).



## `functions`

The [functions](functions/) folder contain the R and MATLAB functions required to conduct the analyses and generate the figures for this study.



## `code`

### `step_01_nm_sample_construction`

Scripts for:

- plotting the S–A rank distributions across Yeo networks,
- generating the S–A connectional-axis matrix, and
- creating Yeo-17 network CIFTI files ordered along the S–A axis.

### `step_02_control_energy_calc`  

Scripts for screening participants and organizing structural-connectivity strengths for 120 connections into `N_obs × N_conn` data frames.  

### `step_03_energy_deviation`  

Scripts for constructing normative models and computing individual deviations per connection.  

1. `S1_selectparameters_*.qmd`: Code to select the optimal distribution family and spline parameters for all connections.  
2. `S2_bootstrap_*.R`: Defines a function that performs one iteration of the bootstrap analysis. Called by `S2_bootstrap_*_exe.R`.  

### `step_04_longitudinal_changes`  

Scripts for constructing normative models and computing individual deviations per connection.  

1. `S1_selectparameters_*.qmd`: Code to select the optimal distribution family and spline parameters for all connections.  
2. `S2_bootstrap_*.R`: Defines a function that performs one iteration of the bootstrap analysis. Called by `S2_bootstrap_*_exe.R`.  

### `step_05_validation_analyses`  

Scripts for constructing normative models and computing individual deviations per connection.  

1. `S1_selectparameters_*.qmd`: Code to select the optimal distribution family and spline parameters for all connections.  
2. `S2_bootstrap_*.R`: Defines a function that performs one iteration of the bootstrap analysis. Called by `S2_bootstrap_*_exe.R`.  
3. 
