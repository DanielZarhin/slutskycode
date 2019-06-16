file_list = { ...
    'C:\ExperimentData\Daniel\Inscopix\Virus injected\TG__old\13.9.18_TG_old_explore\13.9.18_TG_old_explore.tiff' ...
    'C:\ExperimentData\Daniel\Inscopix\Virus injected\TG__old\16.9.18_TG_0ld_iso\16.9.18_TG_0ld_iso.tiff' ...
    };

% Verify that all files exist
for i = 1:length(file_list)
    nam = file_list{i};
    if ~exist(nam,'file')
        error('File %s does not exist.',nam);
    end
end

% Set CNMF-E parameters
Fs = 10;            % frame rate
gSiz = 13;          % maximum diameter of neurons in the image plane. larger values are preferred.
gSig = 3;           % width of the gaussian kernel, which can approximates the average neuron shape
% gSig = 2; gSiz = 9; Does not complete within 24 hours.
ssub = 1;
tsub = 1;
merge_thr = [1e-1, 0.85, 0, 0.85, 0.5];     % thresholds for merging neurons; [spatial overlap ratio, temporal correlation of calcium traces, spike correlation, high spatial overlap ratio]
                                 % components are merged if (merge_thr(1) & merge_thr(2) & merge_thr(3)) | merge(4)

for i = 1:length(file_list)
    nam = file_list{i};
    
    % Generate log file
    [filepath,name,ext] = fileparts(nam);
    diary([filepath '\' name '.log']);
    
    if ~exist(nam,'file')        
        fprintf('%s - File %s does not exist, analysis skipped.\n',datestr(datetime('now')),nam);
    else
        fprintf('%s - Starting analysis of %s.\n',datestr(datetime('now')),nam);
        fprintf('Params: Fs = %d, gSiz = %d, gSig = %d, ssub = %d, tsub = %d, merge_thr = [%.2f, %.2f, %.2f, %.2f, %.2f].\n',Fs,gSiz,gSig,ssub,tsub,merge_thr(1),merge_thr(2),merge_thr(3),merge_thr(4),merge_thr(5));
        
        % Run CNMF-E algorithm to identify neurons and extract their signals
        fprintf('Executing CNMF-E\n');
        tCNMFEOnset = tic;
        try
            CNMFE;
            fprintf('%s - analysis finished.\n',datestr(datetime('now')));
            fprintf('Spent %02d:%02d min executing CNMF-E.\n',floor(toc(tCNMFEOnset)/60), round(rem(toc(tCNMFEOnset),60)));

            % Save CNMF-E results
            save([dir_nm filesep file_nm '_results.mat'],'results');
        catch ME %e is an MException struct
            REPORT = getReport(ME);
            fprintf(2,'%s\n',REPORT);
            fprintf('%s - Analysis of %s was skipped.\n',datestr(datetime('now')),nam);
        end
    end
    
    % Close log file
    diary off;
end