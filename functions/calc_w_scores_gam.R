calc_w_scores_gam <- function(train_data, test_data, covariates) {
  library(mgcv)
  # Extract feature columns and demographic data
  features <- setdiff(colnames(train_data), covariates)
  
  # Initialize a matrix to store W-scores for each feature in pat
  w_scores <- matrix(0, nrow = nrow(test_data), ncol = length(features))
  colnames(w_scores) <- features
  
  for (feature in features) {
    # Build GAM formula:
    # For continuous covariates like "age", add s for nonlinear smooth
    # For categorical covariates, keep them linear
    gam_covariates <- covariates
    gam_covariates[gam_covariates == "age"] <- "s(age, k = 3)"

    formula <- as.formula(paste(feature, "~", paste(gam_covariates, collapse = " + ")))
    # Fit the GAM for training group
    train_gam <- gam(formula, data = train_data, method = "REML")

    # Calculate standard deviation of residuals for training group
    std_R_train <- sd(residuals(train_gam))

    # Predict response and calculate residuals for test group
    test_pred <- predict(train_gam, newdata = test_data[, covariates])
    R_test <- test_data[, feature] - test_pred

    # Calculate W-scores for the feature in test group
    w_scores[, feature] <- R_test / std_R_train

  }
  
  return(w_scores)
}
