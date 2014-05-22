function [result] = calculateASM(Mean, Pt, lambda, Meanpatches, gradMagI, targetImage)
    result = 0;
    bOld = zeros(size(lambda));

    SearchPoints = [Mean(1:18), Mean(19:36)];
    MeanPoints = [Mean(1:18)-68, Mean(19:36)-100];
    XOld = SearchPoints;

    searchSize = 91; %best results with starting search size 6 times the patch size

    while(1)
        
        X = [];
        
        for p = 1:length(SearchPoints)
            
            point = SearchPoints(p,:);
            
            indices_row = ((round(point(1))-(searchSize-1)/2) : (round(point(1))+(searchSize-1)/2));
            indices_col = ((round(point(2))-(searchSize-1)/2) : (round(point(2))+(searchSize-1)/2));
            indices_row = int32(indices_row);
            indices_col = int32(indices_col);
            [ index_row index_col ] = GetIndexOfBestMatchNCC(Meanpatches(:,:,p), gradMagI, indices_col, indices_row );

            X = [X; index_col, index_row ];

        end
        
        double(X);
        
        [AlignedOld, tOld, ROld] = procrustesAlignment(MeanPoints',XOld');
        [AlignedNew, tNew, RNew] = procrustesAlignment(MeanPoints',X');
        
        AlignedNew = AlignedNew';
        AlignedOld = AlignedOld';
        AlignedNew = [AlignedNew(:,1); AlignedNew(:,2)];
        AlignedOld = [AlignedOld(:,1); AlignedOld(:,2)];
        
        b = UpdateShapeParameters(bOld, Pt, lambda, AlignedOld, AlignedNew);
        
        tmpNewShape = [MeanPoints(:,1); MeanPoints(:,2)] + Pt*b;
        tmpNewShape = [tmpNewShape(1:18), tmpNewShape(19:36)];
        
        
        XNew = zeros(size(tmpNewShape));
        for i = 1:length(tmpNewShape)
            XNew(i,:) = (RNew' * (double(tmpNewShape(i,:))' - tNew))';
        end

        XOld = XNew;
        bOld = b;
        SearchPoints = XNew;
        
        %return value
        result = XNew;
        searchSize = searchSize*0.8;
        if (searchSize <15)
            break;
        end
    end
end