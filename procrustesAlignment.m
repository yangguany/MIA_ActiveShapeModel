%determine rotation and translation to near P to Q

function [Z,t,R] = procrustesAlignment(Q, P)
    Q = double(Q);
    P = double(P);
    Q_means = zeros(1, 2);
    P_means = zeros(1, 2);
    Q_means = mean(Q,2);
    P_means = mean(P,2);

    %centering
    Q_center = zeros(2, 18);
    P_center = zeros(2, 18);
    Q_center(1,:) = Q(1,:) - Q_means(1);
    Q_center(2,:) = Q(2,:) - Q_means(2);
    P_center(1,:) = P(1,:) - P_means(1);
    P_center(2,:) = P(2,:) - P_means(2);
    
    %rotation
    H = P_center*Q_center';
    
    [U, L, V] = svd(H);

    D = zeros(2,2);
    D(1,1) = 1;
    D(2,2) = round(det(V*U'));

    R = V * D * U';
       
    %translation
    t = Q_means - R * P_means;
    Z = zeros(2,length(P));
    for i = 1:length(P)
        Z(:,i) = R * double(P(:,i)) + t;
    end
end