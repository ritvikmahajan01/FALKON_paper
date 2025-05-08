% Simple 1D function estimation test using FALKON
clear all;
close all;

% Define the true function
y_true = @(x) 500*sin(x/5000) + 30000*(cos(x/100000)).^2 + exp(x/10000) - x/50000;

% Generate 1D training data
n_train = 500;
x_train = rand(n_train, 1) * 200000 - 100000;  % Random points in (-100000, 100000)
y_train = y_true(x_train) + 100 * randn(n_train, 1);  % Add noise of std 100

% Generate test data
n_test = 200;
x_test = linspace(-100000, 100000, n_test)';
y_test = y_true(x_test) + 100 * randn(n_test, 1);

% FALKON parameters
M = 200;  % Number of Nyström centers (increased to capture more complexity)
lambda = 1e-4;  % Regularization parameter (reduced to allow better fitting)
T = 100;  % Maximum number of iterations
sigma = 10000;  % Kernel bandwidth (increased to match the function's scale)

% Create kernel function
kernel = gaussianKernel(sigma);

% Select Nyström centers randomly
idx = randperm(n_train, M);
C = x_train(idx, :);

% Train FALKON
disp('Training FALKON...');
tic;
useGPU = 0;  % Don't use GPU
memToUse = [];  % Let FALKON determine memory usage
callback = @(x, y) [];  % Empty callback function
cobj = [];  % Empty callback object

alpha = falkon(x_train, C, kernel, y_train, lambda, T, cobj, callback, memToUse, useGPU);
training_time = toc;
fprintf('Training completed in %.2f seconds\n', training_time);

% Make predictions
disp('Making predictions...');
K_test = kernel(x_test, C);
y_pred = K_test * alpha;

% Calculate MSE
mse = mean((y_pred - y_test).^2);
fprintf('Test MSE: %.6f\n', mse);

% Plot results
figure('Position', [100, 100, 800, 600]);

% Plot training data with transparency
h1 = scatter(x_train, y_train, 20, 'b.', 'DisplayName', 'Training Data');
set(h1, 'MarkerEdgeAlpha', 0.3, 'MarkerFaceAlpha', 0.3);
hold on;

% Plot test data
scatter(x_test, y_test, 30, 'g.', 'DisplayName', 'True Test Values');

% Plot continuous predictions
x_continuous = linspace(-100000, 100000, 1000)';
K_continuous = kernel(x_continuous, C);
y_pred_continuous = K_continuous * alpha;
plot(x_continuous, y_pred_continuous, 'r-', 'LineWidth', 2, 'DisplayName', 'Predicted Function');

% Plot the true function
x_true = linspace(-100000, 100000, 1000)';
y_true_vals = y_true(x_true);
plot(x_true, y_true_vals, 'k-', 'LineWidth', 1, 'DisplayName', 'True Function');

% Customize plot
xlabel('x');
ylabel('y');
title('FALKON 1D Function Estimation');
legend('Location', 'best');
grid on;

% Save figure
% saveas(gcf, '1d_function_estimation_results.png'); 