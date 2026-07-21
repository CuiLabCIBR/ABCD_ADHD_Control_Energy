calc_w_scores <- function(train_data, test_data, covariates) {
  # Extract feature columns and demographic data
  features <- setdiff(colnames(train_data), covariates)
  
  # Initialize a matrix to store W-scores for each feature in pat
  w_scores <- matrix(0, nrow = nrow(test_data), ncol = length(features))
  colnames(w_scores) <- features
  
  for (feature in features) {
    # Fit the lm for training group
    formula <- as.formula(paste(feature, "~", paste(covariates, collapse = " + ")))
    
    td_lm <- lm(formula, data = train_data)
    
    # Calculate standard deviation of residuals for training group
    std_R_train <- sd(residuals(td_lm))
    
    # Predict response and calculate residuals for test group
    adhd_pred <- predict(td_lm, newdata = test_data[, covariates])
    R_test <- test_data[, feature] - adhd_pred
    
    # Calculate W-scores for the feature in test group
    w_scores[, feature] <- R_test / std_R_train
  }
  
  return(w_scores)
}