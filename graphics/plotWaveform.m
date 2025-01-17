function plotWaveform(avgwv, stdwv, c, orient, fs)

% plots mean +- std waveform of all channels horizontal (concatenated) or
% vertical
%
% INPUT
%   avgwv       average waveform [nchans x nsamps] 
%   stdwv       std of waveform [nchams x nsamps]
%   c           color of plot
%   orient      channels horizontal {horz} or vertical (vert)
%
% SEE ALSO
%   plotCluster.m
% 
% 04 dec 18 LH. updates:
% 22 jan 19 LH  horizontal plot
% 08 may 19 LH  offset according to trace

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nargs = nargin;
if nargs < 1 || isempty(avgwv)
    error('average waveform not specified')
end
if nargs < 2 || isempty(stdwv)
    warning('std of waveform not specificed. plotting average only')
    stdwv = [];
end
if nargs < 3 || isempty(c)
    c = 'k';
end
if nargs < 4 || isempty(orient)
    orient = 'horz';
end
if nargs < 5 || isempty(fs)
    fs = 24414.14;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nchans, nsamps] = size(avgwv);
j = 1;
if strcmp(orient, 'horz')
        avgwv = [avgwv, NaN(nchans, nsamps / 4)];
        avgwv = reshape(avgwv', [], 1);
        if ~isempty(stdwv)
            stdwv = [stdwv, zeros(nchans, nsamps / 4)];
            stdwv = reshape(stdwv', [], 1);
            errbounds = [avgwv + stdwv, avgwv - stdwv];
            errbounds(isnan(errbounds)) = 0;
            p = patch([1 : length(errbounds), length(errbounds) : -1 : 1],...
                [errbounds(:, 1); errbounds(end : -1 : 1, 2)]', c);
            p.EdgeColor = 'none';
            p.FaceAlpha = 0.3;
        end
        hold on
        l = plot(avgwv, 'lineWidth', 2, 'Color', c);
        ylim([-200 200])
else
    for j = 1 : nchans
        offset = j * (max(avgwv(j, :)) - min(avgwv(j, :)));
        if ~isempty(stdwv)
            errbounds = [avgwv(j, :) + stdwv(j, :);...
                avgwv(j, :) - stdwv(j, :)];
            p = patch([1 : nsamps, nsamps : -1 : 1],...
                [errbounds(1, :), errbounds(2, end : -1 : 1)], c);
            p.EdgeColor = 'none';
            p.FaceAlpha = 0.5;
            set(p, 'YData', get(p, 'YData') - offset);
        end
        hold on
        l = plot(avgwv(j, :), 'lineWidth', 1, 'Color', c);
        set(l, 'YData', get(l, 'YData') - offset);
    end
end
axis off

% scale bar: 
% time (x-axis), sampling frequency 24414
% voltgae (y-axis), the PZ5 by TDT has an input range of +/- 500 mV,
% digitized @ 28 bit resolution. Accordingly:
% signal [V] = signal [bits] * IO range [V] / ADC resolution [nbits] 
% nbits = 2 ^ 27 -1;          % resolution [bits]
% maxv = 1;                 % maximum voltage [V]
% bit = maxv / nbits;         % one bit [V]
% sigv = double(x) * bit * 10 ^ 6

line([0 0], [0 100], 'Color', 'k')
line([0 fs / 10 ^ 3], [0 0], 'Color', 'k') 

end

% EOF


