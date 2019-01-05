function spkcount = spkCount(spikes, varargin)

% for each unit calculates firing frequency in Hz, defined as spike count
% per binsize divided by binsize {default 1 min}. Also calculates average
% and std of normailzed firing frequency. Normalization is according to
% average or maximum FR within a specified window.
% 
% INPUT
% required:
%   spikes      struct (see getSpikes)
% optional:
%   graphics    plot figure {1}.
%   win         time window for calculation {[1 Inf]}. specified in min.
%   binsize     size in s of bins {60}.
%   saveFig     save figure {1}.
%   basePath    recording session path {pwd}
%   normMethod  normalize to 'max' or 'avg' FR within normWin {'avg'}.
%   normWin     window to calculate avg or max FR when normalizing {[1 Inf]}.
%               specified in min.
% 
% examples:     spkCount(spikes, 'normMethod', 'avg', 'normWin', [90 Inf]);
%               will normalize FR according to the average FR between 90
%               min and the end of the recording.
%
% OUTPUT
% spkcount      struct with fields strd, norm, avg, std, bins, binsize,
%               normMethod, normWin
%
% 24 nov 18 LH. updates:
% 05 jan 18 LH  added normMethod and normWin

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% arguments and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
validate_win = @(win) assert(isnumeric(win) && length(win) == 2,...
    'time window must be in the format [start end]');

p = inputParser;
addOptional(p, 'binsize', 60, @isscalar);
addOptional(p, 'graphics', 1, @islogical);
addOptional(p, 'win', [1 Inf], validate_win);
addOptional(p, 'saveFig', 1, @islogical);
addOptional(p, 'basepath', pwd);
addOptional(p, 'saveVar', true, @islogical);
addOptional(p, 'normMethod', 'avg', @ischar);
addOptional(p, 'normWin', [1 Inf], validate_win);

parse(p,varargin{:})
graphics = p.Results.graphics;
binsize = p.Results.binsize;
win = p.Results.win;
saveFig = p.Results.saveFig;
basepath = p.Results.basepath;
saveVar = p.Results.saveVar;
normMethod = p.Results.normMethod;
normWin = p.Results.normWin;

% validate windows
recDur = ceil(max(spikes.spindices(:, 1)) / 60);    % [min]
if win(1) == 0; win(1) = 1; end
if win(2) == Inf; win(2) = recDur; end
if normWin(1) == 0; normWin(1) = 1; end
if normWin(2) == Inf; normWin(2) = recDur; end

nunits = length(spikes.UID);
nmints = ceil(win(2)) - win(1);

spkcount.strd = zeros(nunits, nmints);
spkcount.norm = zeros(nunits, nmints);
spkcount.avg = zeros(1, nmints);
spkcount.std = zeros(1, nmints);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate spike count
for i = 1 : nunits
    for j = 1 : nmints
        % correct for last minute
        if j > win(2)
            binsize = mod(win(2), 60) * 60;
        end
        spkcount.strd(i, j) = sum(ceil(spikes.times{i} / 60) == j) / binsize;
    end
end

% normalize spike count
for i = 1 : nunits
    switch normMethod
        case 'max'
            bline = max(spkcount.strd(normWin(1) : normWin(2)));
        case 'avg'
            bline = mean(spkcount.strd(normWin(1) : normWin(2)));
    end
    spkcount.norm(i, :) = spkcount.strd(i, :) / bline;
end

% calculate mean and std of norm spike count
spkcount.avg = mean(spkcount.norm, 1);
spkcount.std = std(spkcount.norm, 0, 1);
errbounds = [abs(spkcount.avg) + abs(spkcount.std);...
    abs(spkcount.avg) - abs(spkcount.std)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if saveVar
    spkcount.binsize = binsize;
    spkcount.normMethod = normMethod;
    spkcount.normWin = normWin;
    
    [~, filename] = fileparts(basepath);
    save([basepath, '\', filename, '.spkcount.mat'], 'spkcount')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if graphics
    
    f = figure;
    x = ([1 : nmints] / 60);
    
    % raster plot of units
    subplot(3, 1, 1)
    hold on
    for i = 1 : nunits
        y = ones(length(spikes.times{i}) ,1) * spikes.UID(i);
        plot(spikes.times{i} / 60 / 60, y, '.k', 'markerSize', 0.1)
    end
    axis tight
    ylabel('Unit #')
    title('Raster Plot')
    
    % firing rate across time
    subplot(3, 1, 2)
    hold on
    for i = 1 : nunits
        plot(x, spkcount.strd(i, :))
    end
    axis tight
    ylabel('Frequency [Hz]')
    title('Spike Count')
    
    % normalized firing rate across time
    subplot(3, 1, 3)
    hold on
    for i = 1 : nunits
        plot(x, spkcount.norm(i, :))
    end
    p = patch([x, x(end : -1 : 1)], [errbounds(1 ,:), errbounds(2, end : -1 : 1)], [.5 .5 .5]);
    p.EdgeColor = 'none';
    plot(x, spkcount.avg, 'lineWidth', 3, 'Color', 'k')
    axis tight
    xlabel('Time [h]')
    ylabel('Norm. Frequency')
    title('Norm. Spike Count')
    
    if saveFig
        filename = 'spikeCount';
        savePdf(filename, basepath, f)
    end

end

end

% EOF