library(ComBatFamily)
library(dplyr)
library(mgcv)
library(R.matlab)
library(parallel)
library(data.table)

rm(list = ls())
detectCores()

######
working_dir <- "/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy/"

contrast_list <- c("all0In_2Back0Back")
atlas_list <- c("schaefer400", "schaefer200")

sub_info <- fread(paste0(working_dir, "data/sub_info/sub_demo_info.csv"))

for (task_contrast in contrast_list) {
  
  for (atlas in atlas_list) {
    roi_info <- fread(paste0(working_dir, "data/parcellation/", atlas, "_subcortical_region_labels.csv"))
    file_path <- paste0(working_dir, "results/energy_data/")
    file_name <- paste0("ABCD_", task_contrast, "_", atlas)
    
    sub_data <- fread(paste0(file_path, file_name, ".csv"))
    sub_data <- as.data.frame(sub_data)
    row.names(sub_data) <- sub_info$sub_id
    colnames(sub_data) <- roi_info$ROI_Label
    
    age_vec <- as.numeric(sub_info$age)
    fd_vec <- as.numeric(sub_info$mean_fd)
    icv_vec <- as.numeric(sub_info$TBV)
    net_vec <- as.numeric(sub_info[[paste0("network_strength_", atlas)]])
    
    sex_vec <- as.factor(sub_info$sex)
    hand_vec <- as.factor(sub_info$handedness)
    batch <- as.factor(sub_info$site_id)
    
    covar_df <- bind_cols(sub_info$sub_id, age_vec, sex_vec, fd_vec, icv_vec, net_vec, hand_vec)
    covar_df <- dplyr::rename(covar_df, sub = ...1, 
                              age = ...2, 
                              sex = ...3,
                              fd = ...4,
                              icv = ...5,
                              net = ...6,
                              hand = ...7)
    
    com_out <- comfam(data = sub_data, bat = batch, covar = covar_df, 
                      lm, y ~ age + sex + fd + icv + net + hand)
    harmonized_combat <- com_out$dat.combat
    fwrite(harmonized_combat, paste0(file_path, file_name , "_combat.csv"), row.names = FALSE)
  }
  
}
