function Cosine_Similarity=cosim(A,B)
% Normalize the matrices A and B
% A = A ./ norm(A, 'fro');
% B = B ./ norm(B, 'fro');

% Calculate dot product between matrices A and B
Dot_Product = sum(sum(A .* B));

% Calculate the magnitudes of matrices A and B
Magnitude_A = sqrt(sum(sum(A.^2)));
Magnitude_B = sqrt(sum(sum(B.^2)));

% Calculate the cosine similarity between matrices A and B
Cosine_Similarity =sin(acos( Dot_Product ./ (Magnitude_A * Magnitude_B)))*Magnitude_B;

end