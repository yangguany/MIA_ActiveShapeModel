function [Mean, Pt, lambda] = statisticalShapeModel(shapes)
    
    %building 2n long column vectors of shapes
    sVectors = [];
    Mean = zeros(size(shapes(:,:,1)));
    for i=1:length(shapes)
        temp = shapes(:,:,i);
        sVectors = [sVectors, temp(:)];
        Mean = Mean + temp;
    end
    
    %PCA
    [PC, Score, latent] = princomp(sVectors');
    
    %calculating the number of eigenvectors that cover 97% of data
    variance_measure = cumsum(latent)./sum(latent);
    satisfied = find(variance_measure > 0.97);
    t = satisfied(1);
    %eigenvectors and eigenvalues that cover 97% of data
    Pt = PC(1:t,:);
    Pt = Pt';
    %Pt = -Pt'; %daaaaat matlab 2009, why so different to 2013
    lambda = latent(1:t);
    %calculating mean
    Mean = Mean'/length(shapes);
    Mean = Mean(:);
    
end