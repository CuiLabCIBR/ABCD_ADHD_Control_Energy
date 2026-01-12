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

task_contrast <- "all0In_2Back0Back"
atlas <- "schaefer400"

sub_info <- fread(paste0(working_dir, "data/sub_info/sub_demo_info.csv"))
roi_info <- fread(paste0(working_dir, "data/parcellation/", atlas, "_subcortical_region_labels.csv"))

file_path <- paste0(working_dir, "results/energy_data/")
file_name <- paste0("ABCD_", task_contrast, "_", atlas)

sub_data <- fread(paste0(file_path, file_name, ".csv"))
sub_data <- as.data.frame(sub_data)
row.names(sub_data) <- sub_info$sub_id
colnames(sub_data) <- roi_info$ROI_Label

data_dim <- dim(sub_data)
data_num <- data_dim[2]

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

#####
sub_info_null <- fread(paste0(working_dir, "data/sub_info/sub_test_info.csv"))

age_vec <- as.numeric(sub_info_null$age)
fd_vec <- as.numeric(sub_info_null$mean_fd)
icv_vec <- as.numeric(sub_info_null$TBV)
net_vec <- as.numeric(sub_info_null[[paste0("network_strength_", atlas)]])

sex_vec <- as.factor(sub_info_null$sex)
hand_vec <- as.factor(sub_info_null$handedness)
batch_null <- as.factor(sub_info_null$site_id)

covar_df_null <- bind_cols(sub_info_null$sub_id, age_vec, sex_vec, fd_vec, icv_vec, net_vec, hand_vec)
covar_df_null <- dplyr::rename(covar_df_null, sub = ...1, 
                          age = ...2, 
                          sex = ...3,
                          fd = ...4,
                          icv = ...5,
                          net = ...6,
                          hand = ...7)

file_path_null <- paste0(working_dir, "results/energy_data_null/")

for (i in 1:101) {
  file_name_null <- paste0("ABCD_", task_contrast, "_", atlas, "_iter", sprintf("%03d", i))
  sub_data_null <- fread(paste0(file_path_null, file_name_null, ".csv"))
  sub_data_null <- as.data.frame(sub_data_null)
  row.names(sub_data_null) <- sub_info_null$sub_id
  colnames(sub_data_null) <- roi_info$ROI_Label
  
  in_pred <- predict(com_out, newdata = sub_data_null, newbat = batch_null, newcovar = covar_df_null)
  harmonized_combat <- in_pred$dat.combat
  fwrite(harmonized_combat, paste0(file_path_null, file_name_null , "_combat.csv"), row.names = FALSE)
}
