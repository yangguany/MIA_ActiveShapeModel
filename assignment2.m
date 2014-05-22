function assignment2()

    clear all;
    close all;

    files = dir('contoursAndPoints\*.mat');
    coPo = [];
    for file = files'
        path = strcat('contoursAndPoints\',file.name);
        coPo = [coPo, load(path)];
    end
    
    imagefiles = dir('denoisedImages\*.tif');
    images = [];
    for image = imagefiles'
        path = strcat('denoisedImages\',image.name);
        images = cat(3, images, im2double(imread(path)));
    end
    total_error = [];

    [~,~,no_im] = size(images);
    for target = 1:no_im
        targetData = [];
        targetImage = [];
        trainingData = [];
        trainingImages = [];
        for i = 1:length(coPo)
            if i == target
                targetData = coPo(i).SelectedCorrespondingPoints;
                targetImage = images(:,:,target);
            else
                trainingData = cat(3, trainingData, coPo(i).SelectedCorrespondingPoints);
                trainingImages = cat(3, trainingImages, images(:,:,i));
            end

        end

        [AlignedShapes] = generalProcrustes(trainingData);

        [~,~,qq] = size(AlignedShapes);
        for i = 1:qq
            Q_means = zeros(1, 2);
            Q_means(1) = sum(AlignedShapes(1,:,i))/18;
            Q_means(2) = sum(AlignedShapes(2,:,i))/18;

            %centering
            AlignedShapes(1,:,i) = AlignedShapes(1,:,i) - Q_means(1);
            AlignedShapes(2,:,i) = AlignedShapes(2,:,i) - Q_means(2);
        end
        
        [Mean, Pt, lambda] = statisticalShapeModel(AlignedShapes);        

        [Meanpatches] = calculateMeanPatches(trainingData, trainingImages);

        h = fspecial('sobel');
        precalcX = double(imfilter(targetImage, h, 'same', 'replicate')).^2;
        precalcY = double(imfilter(targetImage, h', 'same', 'replicate')).^2;
        gradMagI = sqrt(precalcX+precalcY); 

        Mean = [Mean(1:18)+68; Mean(19:36)+100];
        [X] = calculateASM(Mean, Pt, lambda, Meanpatches, gradMagI, targetImage);

        groundTruthContour = coPo(target).GroundTruthPoints;
        [ error ] = CalculateError( X, groundTruthContour');
        
        total_error = [total_error  error];
    
    end

%     mean(total_error)

%     over = total_error(find(total_error>0.15));
%     between = total_error(find(total_error>0.1 & total_error<0.15));
%     below = total_error(find(total_error<0.1));
%     
%     h = figure;
%     pie_array = [length(below) length(between) length(over)];
%     pie(pie_array, [1 1 1], {'error<0.1', '0.1<error<0.15', 'error>0.15'});
%     title('Segmentation errors');
%     colormap jet;
%     saveas(h,'piechart.png');
end