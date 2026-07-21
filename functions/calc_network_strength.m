function results = calc_network_strength(ConnPath)

% schaefer200
load(ConnPath,'schaefer200_sift_invnodevol_radius2_count_connectivity');
connectivity = schaefer200_sift_invnodevol_radius2_count_connectivity;
% connectivity = schaefer200_sift_invnodevol_radius2_count_connectivity(1:200,1:200);

degree_schaefer200 = sum(connectivity);
zero_schaefer200 = sum(degree_schaefer200 == 0);
[net_size_schaefer200, ~] = size(connectivity);

A = connectivity ./ (svds(connectivity, 1) + 1);
A = A - eye(size(A));

A_triu = triu(A);
net_strength_schaefer200 = sum(A_triu(:));

qc_schaefer200 = double((net_size_schaefer200 == 252) & (zero_schaefer200 == 0));
% qc_schaefer200 = double((net_size_schaefer200 == 200) & (zero_schaefer200 == 0));

% schaefer400
load(ConnPath,'schaefer400_sift_invnodevol_radius2_count_connectivity');
connectivity = schaefer400_sift_invnodevol_radius2_count_connectivity;
% connectivity = schaefer400_sift_invnodevol_radius2_count_connectivity(1:400,1:400);

degree_schaefer400 = sum(connectivity);
zero_schaefer400 = sum(degree_schaefer400 == 0);
[net_size_schaefer400, ~] = size(connectivity);

A = connectivity ./ (svds(connectivity, 1) + 1);
A = A - eye(size(A));

A_triu = triu(A);
net_strength_schaefer400 = sum(A_triu(:));

qc_schaefer400 = double((net_size_schaefer400 == 452) & (zero_schaefer400 == 0));
% qc_schaefer400 = double((net_size_schaefer400 == 400) & (zero_schaefer400 == 0));


% return results
results = [net_strength_schaefer400,net_strength_schaefer200,qc_schaefer400,qc_schaefer200];

end