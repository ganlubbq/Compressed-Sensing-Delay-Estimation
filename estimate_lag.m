function tau = estimate_lag(x1, x2, Fs, low_freq, high_freq, downsample_rate, tau_ind)
    % Parameters
    n  = length(x1); % The length of the signal
    Ts = 1/Fs;       % The time interval
    search_width = 100; 
    
    % Do FFT for each of the signals
    x1_fft = fft(x1',n); % same size as x1
    x2_fft = fft(x2',n); % same size as x2
    
    % Apply bandpass filter
    ideal_BP   = filters.ideal_BP_DS_filter(low_freq, high_freq, downsample_rate, n, Fs);
    x1_filter  = x1_fft .* ideal_BP;
    x2_filter  = x2_fft .* ideal_BP;
    freq_range = (0:n-1)/n;

    % Remove the zero value.
    non_zero_ind = find(ideal_BP);
    x1_filter  = x1_filter(non_zero_ind);
    x2_filter  = x2_filter(non_zero_ind);
    freq_range = freq_range(non_zero_ind);
    Y = (x1_filter) .* conj(x2_filter) .* (abs(x1_filter) .^2);

    % cost value
    tau_val  = (tau_ind / Ts - search_width : tau_ind / Ts + search_width) * Ts;
    cost_val = zeros(1, length(tau_val));
    for i = 1:length(tau_val)
        p = exp(-1.0 .* complex(0,1) .* 2 .* pi .* tau_val(i) .* freq_range);
        cost_val(i) = -2 * real(sum(Y .* p));
    end
    
    % Get the index of the estimated tau
    [min_cost, index] = min(cost_val);
    tau = tau_val(index) * Ts;
 
    % Plot the cost value
%     f = figure;
%     plot(tau_val * Ts, cost_val, 'b');
%     xlabel('Lag (s)'); ylabel('Cost'); title('Lag-Cost Value');
%     myboldify(f);

end