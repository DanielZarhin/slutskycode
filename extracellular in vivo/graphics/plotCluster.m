function plotCluster(basepath, spikes, clu, saveFig)

% INPUT
%   basepath    path to recording
%   spikes      struct (see getSpikes)
%   clu         units to plot. if == nunits than a figure with all units
%               will be plotted, in addition to figures of individual units
%   saveFig     save figure {true} or not (false)
%
% CALLS
%   plotWaveform
%
% 24 nov 18 LH. updates:
% 04 dec 18. added individual units.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nargs = nargin;
if nargs < 1 || isempty(basepath)
    basepath = pwd;
end
if nargs < 2 || isempty(spikes)
    warning('spikes will be loaded from %s', basepath)
    spikes = getSpikes('basepath', basepath);
end
nunits = length(spikes.UID);
if nargs < 3 || isempty(clu)
    clu = 1 : nunits;
elseif length(clu) > nunits
    error('specified more units to plot than are available in spikes')
end
if nargs < 4 || isempty(saveFig)
    saveFig = true;
end
if ~isfield(spikes, 'L')
    spikes.L = nan(nunits, 1);
end
if ~isfield(spikes, 'iDist')
    spikes.iDist = nan(nunits, 1);
end
if ~isfield(spikes, 'ISIratio')
    spikes.ISIratio = nan(nunits, 1);
end
if ~isfield(spikes, 'su')
    spikes.su = nan(nunits, 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
grpcolor = ['k', 'b', 'r', 'm', 'g', 'y'];

% plot individual units
for i = 1 : length(clu)
    f = figure;
    
    % waveform
    subplot(2, 2, 1)
    unitcolor = grpcolor(spikes.shankID(clu(i)));
    plotWaveform(spikes.avgWaveform{clu(i)}, spikes.stdWaveform{clu(i)}, unitcolor)
    
    % ISI histogram
    subplot(2, 2, 2)
    binsize = 0.0005;
    bins = [-0.1 : binsize : 0.1];
    h = histogram([diff(spikes.times{clu(i)}) diff(spikes.times{clu(i)}) * -1], bins);
    h.EdgeColor = 'none';
    h.FaceColor = unitcolor;
    axis off
    
    % raster
    subplot(2, 2, [3 4])
    y = ones(length(spikes.times{i}) ,1);
    plot(spikes.times{clu(i)} / 60 / 60, y, '.k', 'markerSize', 0.1)
    axis off
    title(sprintf('nSpks = %d', length(spikes.times{clu(i)})), 'FontSize', 14, 'FontWeight', 'norma');
    
    % discriptives
    if spikes.su(clu(i)) == 1
        su = 'SU';
    elseif spikes.su(clu(i)) == 0
        su = 'MU';
    else
        su = 'NaN';
    end
    txt = sprintf('%d - %s; L = %.2f; iDist = %.2f; ISI = %.2f',...
        clu(i), su, spikes.L(clu(i)), spikes.iDist(clu(i)), spikes.ISIratio(clu(i)));
    suptitle(txt)
    
    if saveFig
        figname = fullfile(basepath, ['\graphics\clu' int2str(i)]);
        saveas(f, figname, 'png')
    end
    
end
close all

% plot all units in a grid
if length(clu) == nunits
    
    plotidx = ceil(sqrt(nunits));
    plotidx = [plotidx ceil(nunits * 2 / plotidx)];
    wvidx = 1 : 2 : nunits * 2;
    histidx = 2 : 2 : nunits * 2;
    
    f = figure;
    for i = 1 : nunits
        
        % waveform
        subplot(plotidx(1), plotidx(2), wvidx(i))
        unitcolor = grpcolor(spikes.shankID(i));
        plotWaveform(spikes.avgWaveform{i}, spikes.stdWaveform{i}, unitcolor)
        title(int2str(i))
        
        % ISI correlogram
        subplot(plotidx(1), plotidx(2), histidx(i))
        binsize = 0.0005;
        bins = [-0.15 : binsize : 0.15];
        h = histogram([diff(spikes.times{i}) diff(spikes.times{i}) * -1], bins);
        h.EdgeColor = 'none';
        h.FaceColor = unitcolor;
        axis off
        
    end
    
    if saveFig
        savepdf('clusters', basepath, f)
    end
end

end

% EOF

