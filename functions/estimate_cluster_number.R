estimate_cluster_number <- function(W, NUMC = 2:5) {
  # ---- basic checks ----
  if (missing(W) || is.null(W)) stop("W is missing or NULL.")
  W <- as.matrix(W)
  if (!is.numeric(W)) stop("W must be numeric.")
  if (nrow(W) != ncol(W)) stop("W must be a square similarity matrix.")
  n <- nrow(W)
  
  # ---- validate NUMC ----
  NUMC <- unique(as.integer(NUMC))
  NUMC <- NUMC[!is.na(NUMC)]
  if (length(NUMC) == 0) NUMC <- 2:5
  
  if (any(NUMC == 1)) {
    warning("Note that we always assume there are more than one cluster.")
    NUMC <- NUMC[NUMC > 1]
  }
  if (length(NUMC) == 0) {
    warning("Invalid NUMC provided; using default NUMC = 2:5")
    NUMC <- 2:5
  }
  
  # We will access eigenvalues at indices ck and ck+1, and eigengap at index ck
  # So ck must satisfy: ck >= 2 and ck+1 <= n  and ck <= (n-1) for eigengap
  NUMC <- sort(NUMC[NUMC >= 2 & (NUMC + 1) <= n & NUMC <= (n - 1)])
  if (length(NUMC) == 0) {
    stop("After filtering, NUMC has no valid k. Need k such that 2 <= k <= n-1.")
  }
  
  # ---- ensure SNFtool internal discretisation is available ----
  if (!requireNamespace("SNFtool", quietly = TRUE)) {
    stop("Package 'SNFtool' is required (for SNFtool:::.discretisation). Install it first.")
  }
  discretise <- getFromNamespace(".discretisation", "SNFtool")
  
  # ---- preprocess W ----
  W <- (W + t(W)) / 2
  diag(W) <- 0
  
  degs <- rowSums(W)
  degs[degs == 0] <- .Machine$double.eps
  
  # Normalized Laplacian: L = D^{-1/2}(D - W)D^{-1/2}
  Di <- diag(1 / sqrt(degs))
  L  <- diag(degs) - W
  L  <- Di %*% L %*% Di
  
  # ---- eigen decomposition (stable for symmetric matrices) ----
  eigs <- eigen(L, symmetric = TRUE)
  # eigen() already returns in decreasing order for symmetric matrices,
  # but we want increasing order like the original code:
  ord <- order(eigs$values)
  eig_vals <- eigs$values[ord]
  eig_vecs <- eigs$vectors[, ord, drop = FALSE]
  
  eigengap <- abs(diff(eig_vals))  # length n-1
  
  # ---- rotation-cost quality ----
  quality <- numeric(length(NUMC))
  names(quality) <- as.character(NUMC)
  
  eps <- .Machine$double.eps
  
  for (i in seq_along(NUMC)) {
    ck <- NUMC[i]
    
    UU <- eig_vecs[, 1:ck, drop = FALSE]
    
    # discretise returns a list; first element is the discrete eigenvectors matrix
    EigenvectorsDiscrete <- discretise(UU)[[1]]
    
    EigenVectors <- EigenvectorsDiscrete^2
    
    # Sort rows by columns (lexicographic), then sort each row decreasing
    ord_rows <- do.call(order, lapply(seq_len(ncol(EigenVectors)), function(j) EigenVectors[, j]))
    temp1 <- EigenVectors[ord_rows, , drop = FALSE]
    temp1 <- t(apply(temp1, 1, sort, decreasing = TRUE))
    
    # ensure column range is valid
    col_end <- min(ncol(temp1), max(2, ck - 1))
    denom <- temp1[, 1] + eps
    A <- diag(1 / denom)
    B <- temp1[, 1:col_end, drop = FALSE]
    
    # Avoid division by ~0 in (1 - eig_vals[ck]) as well
    ratio_num <- (1 - eig_vals[ck + 1])
    ratio_den <- (1 - eig_vals[ck])
    ratio_den <- ifelse(abs(ratio_den) < eps, eps, ratio_den)
    
    quality[i] <- (ratio_num / ratio_den) * sum(diag(A %*% B))
  }
  
  # ---- pick best and 2nd best safely ----
  # Eigen-gap picks largest gaps at indices NUMC
  gaps_for_k <- eigengap[NUMC]
  # remove NAs defensively
  ok_gap <- !is.na(gaps_for_k)
  if (!any(ok_gap)) stop("All eigengap[NUMC] are NA; check NUMC range and matrix size.")
  k_gap_rank <- NUMC[order(gaps_for_k[ok_gap], decreasing = TRUE)]
  K1  <- k_gap_rank[1]
  K12 <- if (length(k_gap_rank) >= 2) k_gap_rank[2] else NA_integer_
  
  # Rotation cost: smaller is better (original code sorts ascending)
  k_rot_rank <- NUMC[order(quality, decreasing = FALSE)]
  K2  <- k_rot_rank[1]
  K22 <- if (length(k_rot_rank) >= 2) k_rot_rank[2] else NA_integer_
  
  list(
    `Eigen-gap best` = K1,
    `Eigen-gap 2nd best` = K12,
    `Rotation cost best` = K2,
    `Rotation cost 2nd best` = K22,
    eigengap = gaps_for_k,
    rotation_cost = quality
  )
}
