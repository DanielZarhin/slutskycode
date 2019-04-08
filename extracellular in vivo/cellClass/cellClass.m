function  [CellClass] = cellClass (waves, varargin)

% classifies clusters to PYR \ INT according to waveform parameters
% (trough-to-peak, asymmetry, and spike width).
% 
% INPUT
%   waves       matrix of sampels (rows) x units (columns). for example:
%               waves = cat(1, spikes.rawWaveform{spikes.su})'
%               waves = cat(1, spikes.rawWaveform{:})'
%   fs          sampling frequency
%   basepath    recording session path {pwd}
%   graphics    plot figure {1}.
%   saveFig     save figure {1}.
%   saveVar     save variable {1}.
% 
% OUTPUT
%   CellClass   struct with fields:
%       class       logical vector where 1 = PYR and 0 = INT
%       tp          trough-to-peak times
%       spkw        spike width
%       asym        asymmetry
% 
% DEPENDENCIES
%   getWavelet      from buzcode
%   fft_upsample    from Kamran Diba
%
% 08 apr 19 LH. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser;
addOptional(p, 'basepath', pwd);
addOptional(p, 'fs', 24414.14, @isnumeric);
addOptional(p, 'graphics', true, @islogical);
addOptional(p, 'saveFig', true, @islogical);
addOptional(p, 'saveVar', true, @islogical);

parse(p, varargin{:})
basepath = p.Results.basepath;
fs = p.Results.fs;
graphics = p.Results.graphics;
saveFig = p.Results.saveFig;
saveVar = p.Results.saveVar;

% params
oneMs = round(fs / 1000);
nunits = size(waves, 2);
upsamp = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trough-to-peak time [ms]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1 : nunits
    w = fft_upsample(waves(:, i), upsamp);
    [minval, minpos] = min(w);
    [maxval, maxpos] = max(w(1 : minpos - 1));   
    [maxvalpost, maxpost] = max(w(minpos + 1 : end));               
    if ~isempty(maxpost)
        % trough-to-peak - Stark et al., 2013; Bartho et al., 2004
        tp(i) = maxpost;
        % asymmetry - Sirota et al., 2008
        asym(i) = (maxvalpost - maxval) / (maxvalpost + maxval);    
    else
        warning('waveform may be corrupted')
        tp(i) = NaN;
        asym(i) = NaN;
    end
end
% samples to ms
tp = tp / fs * 1000 / upsamp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spike width by inverse of max frequency in spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1 : nunits
    w = waves(:, i);
    w = [w(1) * ones(1000, 1); w; w(end) * ones(1000, 1)];
    [wave f t] = getWavelet(w, fs, 500, 3000, 128, 'var');
    % wt = cwt(w, fs, 'amor', 'FrequencyLimits', [500 3000]);
    wave = wave(:, int16(length(t) / 4) : 3 * int16(length(t) / 4));
    
    % find maximum
    [maxPow, ix] = max(wave);
    [~, mix] = max(maxPow);
    ix = ix(mix);
    spkw(i) = 1000 / f(ix);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% graphics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if graphics
    figure
    scatter(tp, spkw)
    xlabel('trough-to-peak [ms]')
    ylabel('spike width [ms]')
    hold on
end


%% Generate separatrix for cells 

xx = [0 0.8];
yy = [2.4 0.4];
m = diff( yy ) / diff( xx );
b = yy( 1 ) - m * xx( 1 );  % y = ax+b
PYR = spkw >= m*tp'+b;
INT = ~PYR;

%% Plot for manual selection of boundary, with display of separatrix as a guide.
h = figure;
title({'Discriminate pyr and int (select Pyramidal)','left click to draw boundary', 'center click/ENTER to complete)'});
fprintf('\nDiscriminate pyr and int (select Pyramidal)');
xlabel('Trough-To-Peak Time (ms)')
ylabel('Wave width (via inverse frequency) (ms)')
[ELike,PyrBoundary] = ClusterPointsBoundaryOutBW([tp spkw],m,b);

selectCluster([tp; spkw])

if keepKnown
    ELike(knownEidx) = 1;
    ELike(knownIidx) = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if saveVar   
    CellClass.tp = tp;
    CellClass.spkw = spkw;
    CellClass.asym = asym;
    [~, filename] = fileparts(basepath);
    save([basepath, '\', filename, '.cellClass.mat'], 'CellClass')
end

% if SAVEFIG || SHOWFIG
%     figure
%     subplot(2,2,1)
%         plot(CellClass.detectionparms.TroughPeakMs(CellClass.pE),...
%             CellClass.detectionparms.SpikeWidthMs(CellClass.pE),'k.')
%         hold on
%         plot(CellClass.detectionparms.TroughPeakMs(CellClass.pI),...
%             CellClass.detectionparms.SpikeWidthMs(CellClass.pI),'r.')
%         axis tight
%         plot(CellClass.detectionparms.PyrBoundary(:,1),...
%             CellClass.detectionparms.PyrBoundary(:,2))
%         xlim([0 max([x+0.1;2])])
%         ylim([0 max([y+0.1;2])])
%         xb = get(gca,'XLim');
%         yb = get(gca,'YLim');
%         plot(xb,[m*xb(1)+b m*xb(2)+b])
%         xlabel('Trough to Peak Time (ms)')
%         ylabel('Spike Width (ms)')
%         title([baseName,': Cell Classification'])
%         
%     subplot(2,2,2)
%         plot([1:size(MaxWaves,1)]./oneMs,MaxWaves(:,CellClass.pE),'color',[0 0.6 0])
%         hold on
%         plot([1:size(MaxWaves,1)]./oneMs,MaxWaves(:,CellClass.pI),'color',[0.6 0 0])
%         axis tight
%         xlabel('t (ms)')
% end

end
