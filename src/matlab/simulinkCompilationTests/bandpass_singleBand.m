function filteredEEG = bandpass_singleBand(eegData, sm)
% SINGLEBAND_BANDPASS_FILTER Applies highpass then lowpass filtering
    % Match simulink behaviour by erroring on NAN or Inf values
    if any(~isfinite(eegData))
        error('bandpass_singleBand:InvalidInput', 'Signal contains NaN or Inf values.');
    end

    % Apply highpass first
    eegData_hp = singleband_highpass_filter(eegData, sm);

    % Then apply lowpass
    filteredEEG = singleband_lowpass_filter(eegData_hp, sm);
end



function y = singleband_highpass_filter(x, sm)
% SINGLEBAND_HIGHPASS_FILTER Applies a highpass FIR filter based on sm struct
%
% Inputs:
%   x  - Input signal (column vector)
%   sm - Struct containing EEG filter parameters:
%        sm.p.EEG.sr               = Sample rate (Hz)
%        sm.p.EEG.band(1).low1     = Stopband frequency (Hz)
%        sm.p.EEG.band(1).low2     = Passband frequency (Hz)
%        sm.p.EEG.band_stop_dB     = Stopband attenuation (dB)
%        sm.p.EEG.band_pass_dB     = Passband ripple (dB)
%
% Output:
%   y  - Filtered signal

    % Extract parameters
    Fs     = sm.p.EEG.sr;
    Fstop  = sm.p.EEG.band(1).low1;
    Fpass  = sm.p.EEG.band(1).low2;
    Astop  = sm.p.EEG.band_stop_dB;
    Apass  = sm.p.EEG.band_pass_dB;

    % Normalize frequencies
    d = fdesign.highpass( ...
        'Fst,Fp,Ast,Ap', ...
        Fstop, Fpass, Astop, Apass, Fs);

    % Design equiripple FIR filter
    Hd = design(d, 'equiripple');

    % Apply filter
    y = filter(Hd, x);
end


function y = singleband_lowpass_filter(x, sm)
% SINGLEBAND_LOWPASS_FILTER Applies a lowpass FIR filter based on sm struct
%
% Inputs:
%   x  - Input signal (column vector)
%   sm - Struct containing EEG filter parameters:
%        sm.p.EEG.sr                = Sample rate (Hz)
%        sm.p.EEG.band(1).high1    = Passband frequency (Hz)
%        sm.p.EEG.band(1).high2    = Stopband frequency (Hz)
%        sm.p.EEG.band_stop_dB     = Stopband attenuation (dB)
%        sm.p.EEG.band_pass_dB     = Passband ripple (dB)
%
% Output:
%   y  - Filtered signal

    % Extract parameters
    Fs     = sm.p.EEG.sr;
    Fpass  = sm.p.EEG.band(1).high1;
    Fstop  = sm.p.EEG.band(1).high2;
    Apass  = sm.p.EEG.band_pass_dB;
    Astop  = sm.p.EEG.band_stop_dB;

    % Design lowpass equiripple filter
    d = fdesign.lowpass( ...
        'Fp,Fst,Ap,Ast', ...
        Fpass, Fstop, Apass, Astop, Fs);

    Hd = design(d, 'equiripple');

    % Apply filter
    y = filter(Hd, x);
end
