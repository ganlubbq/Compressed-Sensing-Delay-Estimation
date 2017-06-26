function [ result ] = batch_proc( ...
    x1, x2, window_size, ...
    func_handle) 
% Batch Proc takes two signals, window size and a function handler as its
% parameters, which used to preprocess the raw signals and do the indicated
% task for the segments of the signals.
% The preprocessing of the raw signals includes 1. cutting the signals by 
% the size of the windows into multiple segments; 2. Whitening; 3. Taper.

    %% Cut the signals into multiple segments by the window size
    
    % The number of the segments of windows
    b = floor(length(x1)/window_size);
    % Length of the signal that we're going to use
    n = b * window_size;
    % Reshape the signals into 2D matrix,
    x1 = reshape(x1(1:n), window_size, b);
    x2 = reshape(x2(1:n), window_size, b);
    % Whitening
    if max(abs(x1)) ~= 0
        x1 = bsxfun(@times, x1, 1./max(abs(x1)));
    end
    if max(abs(x2)) ~= 0
        x2 = bsxfun(@times, x2, 1./max(abs(x2)));
    end
    % A row of the matrix is a segment of the raw signal (x(i,:))
    x1 = transpose(x1);
    x2 = transpose(x2);
    fprintf('Window size: %d. Number of segments: %d\n', window_size, b);

    %% Do func_handle in batches with the divided segments of the signal
    
    result = [];
    for i=1:b
        signal_a = x1(i,:);
        signal_b = x2(i,:);
        % Remove the mean value on top of the segment
        signal_a = signal_a - mean(signal_a);
        signal_b = signal_b - mean(signal_b);
        % Taper
        w_sigma = window_size/6;
        w_mean  = window_size/2;
        gaussian_window = normpdf((1:window_size), w_mean, w_sigma);
        signal_a = signal_a .* gaussian_window;
        signal_b = signal_b .* gaussian_window;
        % For debugging
        % Plot the central segment
        if i == b/2
            paint.signal(gaussian_window, 50);
            paint.signal(signal_b, 50);
        end
        % Do callback function, like cross-correlation or our
        % compressed-sensing based algorithm ...
        % Note: If you have other paremeters for the func_handle,
        %       you simply need to wrap your funtion handle into 
        %       an anonymous function where the parameters are set,
        %       e.g. func_handle = @(signal_a, signal_b) ...
        %            your_function(signal_a, signal_b, your_paras)
        result = [result; func_handle(signal_a, signal_b)];
    end

end

