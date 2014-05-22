function [aligned] = generalProcrustes(copo)
    
    %set first meanshape "random" from all shapes
    meanshape = copo(:,:,1);
    %initial aligning of shapes
    aligned = aligning(meanshape, copo);
    %calculate new meanshape
    new_meanshape = sum(aligned, 3)./length(copo);
    %get difference to old meanshape
    difference = sum(sum(abs(meanshape - new_meanshape)));
    %repeat until convergence
    while difference > 0.0001
        meanshape = new_meanshape;
        aligned = aligning(meanshape, copo);
        new_meanshape = sum(aligned, 3)./length(copo);
        difference = sum(sum(abs(meanshape - new_meanshape)));
    end
end


%aligns all shapes via procrustesAlignment to given meanshape
function [results] = aligning(meanshape, copo)
    results = 0;
    [~,~,l] = size(copo);
    for i = 1:l
        result = procrustesAlignment(meanshape, copo(:,:,i));
        if results == 0
            results = result;
        else
            results = cat(3, results, result);
        end
    end
end
