function spkcount = diffFR(spkcount, varargin)

% INPUT
% required:
%   spkcount    struct (spkCount)
% optional:
%   graphics    plot figure {1}.
%   win         time window for calculation {[1 Inf]}. specified in min.
%   saveFig     save figure {1}.
%   basepath    recording session path {pwd}
% 
% EXAMPLES:     
%
% OUTPUT
%   spkcount    additional field 'change'
%
% 07 jan 18 LH.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
validate_win = @(win) assert(isnumeric(win) && size(win, 1) == 2,...
    'time window must be in the format [start end]');

p = inputParser;
addOptional(p, 'graphics', 1, @islogical);
addOptional(p, 'win', [30 60; 240 270], validate_win);
addOptional(p, 'saveFig', 1, @islogical);
addOptional(p, 'basepath', pwd);
addOptional(p, 'saveVar', true, @islogical);

parse(p,varargin{:})
graphics = p.Results.graphics;
binsize = p.Results.binsize;
win = p.Results.win;
saveFig = p.Results.saveFig;
basepath = p.Results.basepath;
saveVar = p.Results.saveVar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate change in normalized firing rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1 : nunits
    for j = 1 : size(win, 1)
        spkcount.change(i, j) = mean(spkcount.norm(i, win(1, j) : win(2, j)));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if graphics
    f = figure;
    xpoints = 1 : size(win, 1);
    line(xpoints, [spkcount.change], 'Color', [0.5 0.5 0.5])
    hold on
    line(xpoints, [mean(spkcount.change)], 'Color', 'k', 'LineWidth', 5)
    xlim([xpoints(1) - 0.2, xpoints(end) + 0.2])
    ax = gca;
    ax.XTick = xpoints;
    if size(win, 1) == 2
        ax.XTickLabel = {'Pre Injection' 'Post Injection'};
    end
    xlabel('Treatment')
    ylabel('Norm. Firing Rate')
    ylim([0 5])
    
    if saveFig
        filename = 'diffFR';
        savePdf(filename, basepath, f)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if saveVar  
    [~, filename] = fileparts(basepath);
    save([basepath, '\', filename, '.spkcount.mat'], 'spkcount')
end

end

% EOF