%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

order = 4;
passband = 'ripples';
switch passband
    case 'delta'
        passband = [0 6];
        order = 8;
    case 'theta'
        passband = [4 10];
    case 'spindles'
        passband = [9 17];
    case 'gamma'
        passband = [30 80];
    case 'ripples'
        passband = [100 250];
    otherwise
        error('Unknown frequency band')
end

filtered = bz_Filter(lfp, 'passband', passband, 'order', order);

% plot filteres vs. raw
interval = [500, 5000];
t = lfp.fs * interval(1) : lfp.fs * interval(2);
figure
yyaxis left
p1 = plot(t / lfp.fs, filtered.data(t, 1));
hold on
yyaxis right
p2 = plot(t / lfp.fs, lfp.data(t, 1));
p2.Color(4) = 0.5;
legend('Filtered', 'Raw')
xlabel('Time [s]')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ripples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ripples = bz_FindRipples(lfp.data, lfp.timestamps, 'EMGThres', 0);
[maps,data,stats] = bz_RippleStats(filtered.data(:, 1), lfp.timestamps, ripples);
bz_PlotRippleStats(maps, data, stats)





