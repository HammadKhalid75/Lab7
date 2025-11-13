%%  Gaussian Noise Modeling & Denoising Comparison
%  -------------------------------------------------
%  1. Load image & add Gaussian noise
%  2. Apply three traditional filters (Mean, Median, Gaussian blur)
%  3. Apply the pre-trained DnCNN (AI) filter
%  4. Compute MSE, PSNR, SSIM for every method
%  5. Show visual results + quantitative table
%  -------------------------------------------------

clear; clc; close all;

%% 1. Load image & add Gaussian noise
original = im2double(imread('cameraman.tif'));   % 256x256 grayscale
sigma    = 0.04;                                 % noise std
noisy    = imnoise(original,'gaussian',0,sigma^2);

%% 2. Traditional filters
% ---- Mean filter (box) ----
meanFilt   = imfilter(noisy, fspecial('average', [5 5]), 'replicate');

% ---- Median filter ----
medianFilt = medfilt2(noisy, [5 5], 'symmetric');

% ---- Gaussian blur ----
gaussFilt  = imgaussfilt(noisy, 1.0, 'FilterSize', 5);   % sigma = 1.0

% ---- Adaptive Wiener (already a strong baseline) ----
wienerFilt = wiener2(noisy, [5 5], sigma^2);

%% 3. AI filter – pre-trained DnCNN
net      = denoisingNetwork('DnCNN');
aiFilt   = denoiseImage(noisy, net);

%% 4. Quality metrics
% Helper: MSE
mse = @(x,y) mean((x(:)-y(:)).^2);

methods   = {'Noisy', 'Mean', 'Median', 'Gaussian', 'Wiener', 'DnCNN'};
images    = {noisy,  meanFilt, medianFilt, gaussFilt, wienerFilt, aiFilt};

MSE  = zeros(numel(methods),1);
PSNR = zeros(numel(methods),1);
SSIM = zeros(numel(methods),1);

for i = 1:numel(methods)
    MSE(i)  = mse(images{i}, original);
    PSNR(i) = psnr(images{i}, original);
    SSIM(i) = ssim(images{i}, original);
end

%% 5. Display results
figure('Name','Gaussian Noise Denoising Comparison','NumberTitle','off');
subplot(2,4,1); imshow(original);      title('Original');
subplot(2,4,2); imshow(noisy);         title('Noisy');
subplot(2,4,3); imshow(meanFilt);      title('Mean (5x5)');
subplot(2,4,4); imshow(medianFilt);    title('Median (5x5)');
subplot(2,4,5); imshow(gaussFilt);     title('Gaussian (\sigma=1)');
subplot(2,4,6); imshow(wienerFilt);    title('Wiener (5x5)');
subplot(2,4,7); imshow(aiFilt);        title('DnCNN (AI)');

% Table
fprintf('\n--- Quantitative Comparison (Gaussian noise \x03C3=%g) ---\n',sigma);
fprintf('%-12s %8s %8s %8s\n','Method','MSE','PSNR(dB)','SSIM');
fprintf('%s\n',repmat('-',1,44));
for i = 1:numel(methods)
    fprintf('%-12s %8.5f %8.2f %8.4f\n',methods{i},MSE(i),PSNR(i),SSIM(i));
end

%% 6. Brief interpretation
fprintf('\nInterpretation:\n');
fprintf('  • Mean & Gaussian blur heavily smooth the image → low MSE but loss of edges.\n');
fprintf('  • Median is better at preserving edges but still leaves residual noise.\n');
fprintf('  • Wiener adapts locally and usually beats the non-adaptive filters.\n');
fprintf('  • DnCNN (deep learning) consistently yields the highest PSNR/SSIM and the sharpest details.\n');