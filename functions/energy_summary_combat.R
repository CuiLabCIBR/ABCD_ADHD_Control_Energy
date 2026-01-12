energy_summary <- function(working_dir, task_contrast, atlas, combat = "", energy_norm = "control_energy"){
  
  file_name <- paste0("ABCD_", task_contrast, "_", atlas)
  schaefer_net_label <- read.csv(paste0(working_dir, "data/parcellation/", atlas, "_subcortical_region_labels.csv"))
  net_label <- schaefer_net_label$Net_Label
  
  if (combat == "") {
    Energy_ROI <- read.csv(paste0(working_dir, "data/", energy_norm, "/", file_name, ".csv"))
  } else {
    Energy_ROI <- read.csv(paste0(working_dir, "data/", energy_norm, "/", file_name, "_", combat, ".csv"))
  }
  
  colnames(Energy_ROI) <- schaefer_net_label$ROI_Label
  
  sub_num <- dim(Energy_ROI)[1]
  roi_num <- dim(Energy_ROI)[2]
  net_name <- c("VS", "SM", "DA", "VA", "LM", "FP", "DM", "SC")
  Energy_NetAvg <- data.frame(matrix(NA, nrow = sub_num, ncol = 8))
  colnames(Energy_NetAvg) <- net_name
  
  for (i in 1:8) {
    net_idx = which(net_label==i)
    Energy_NetAvg[, i] = rowMeans(Energy_ROI[, net_idx])
  }
  
  Energy_WholeBrain <- as.data.frame(rowMeans(Energy_ROI))
  colnames(Energy_WholeBrain) <- "WholeBrain"

  Energy <- list()
  Energy$ROI <- Energy_ROI
  Energy$NetAvg <- Energy_NetAvg
  Energy$WholeBrain <- Energy_WholeBrain
  
  #
  return(Energy)
  
}