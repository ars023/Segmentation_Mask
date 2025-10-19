file  = load('TrainingSamplesDCT_8.mat');
FG = file.TrainsampleDCT_FG;    
BG = file.TrainsampleDCT_BG;
K  = 64;
nFG = size(FG,1); 
nBG = size(BG,1);
pFG = nFG/(nFG+nBG); 
pBG = 1 - pFG;
fprintf('Priors: P(cheetah)=%.4f, P(grass)=%.4f\n', pFG, pBG);

idxBG = second_idx(BG);
idxFG = second_idx(FG);                       

pmfBG = accumarray(idxBG, 1, [K 1]);   
pmfBG = (pmfBG + 1) / (sum(pmfBG) + K);
pmfFG = accumarray(idxFG, 1, [K 1]);   
pmfFG = (pmfFG + 1) / (sum(pmfFG) + K);      

figure;
bar(1:K, [pmfFG pmfBG], 'grouped');
xlabel('Index of 2^{nd}-largest |DCT| (1..64)');
ylabel('Probability');
legend('P(X|cheetah)','P(X|grass)','Location','northeast');
title('Class-conditional pmfs');
grid on;



Pic = imread('cheetah.bmp');
I = im2double(Pic);

Z = dlmread('Zig-Zag Pattern.txt'); 
[~, zz] = sort(Z(:));
[H,W] = size(I);

Ipad = padarray(I, [4 4], 'symmetric', 'both');
A_pred = false(H, W);               

for r = 1:H            
    for c = 1:W        
        patch = Ipad(r:r+7, c:c+7);   
        B = dct2(patch);     
    z = B(:);
    z = z(zz);           
    xp = second(z.');    
        postFG = pmfFG(xp) * pFG;
        postBG = pmfBG(xp) * pBG;

        A_pred(r,c) = (postFG >= postBG);
    end
end

figure;
imagesc(I, [0 1]); colormap(gray(256)); axis image off;
set(gca,'YDir','reverse'); title('Original image (imagesc)');

figure;
imagesc(A_pred, [0 1]); colormap(gray(256)); axis image off;
set(gca,'YDir','reverse'); title('Predicted mask (sliding, center assign)');


M = imread('cheetah_mask.bmp');
M = M > 0;                           

tp = sum( A_pred(:)==1 & M(:)==1 );
tn = sum( A_pred(:)==0 & M(:)==0 );
fp = sum( A_pred(:)==1 & M(:)==0 );
fn = sum( A_pred(:)==0 & M(:)==1 );
N  = numel(M);

overall_acc = (tp+tn)/N;
fg_err = fn / max(tp+fn,1);     
fprintf('Overall acc: %.2f%% | Cheetah miss: %.2f%%', 100*overall_acc, 100*fg_err);
perr = mean(A_pred(:) ~= M(:));
fprintf('P(error) = %.4f  (accuracy = %.2f%%)\n', perr, 100*(1-perr));
diffmap = A_pred ~= M;
figure; imagesc(diffmap, [0 1]); colormap(gray(256)); axis image off;
set(gca,'YDir','reverse'); title('Disagreement map (white = error)');
