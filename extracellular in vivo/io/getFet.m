function fet = getFet(basepath)

% load features from all .fet files in folder.
%
% INPUT:
%   basepath    path to recording folder {pwd}.
%   saveMat     save output in basepath
%
% OUTPUT:
%   fet         cell array of k x n x m, where k is the number of spike
%               groups (e.g. tetrodes), n is the number of spikes and m is
%               the number of features
%
% 03 dec 18 LH

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nargs = nargin;
if nargs < 1 || isempty(basepath)
    basepath = pws;
end
if nargs < 2 || isempty(saveMat)
    saveMat = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get .fet filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(basepath)
fetfiles = dir([basepath '\' '*.fet*']);
filenames = {fetfiles.name};
nfiles = length(filenames);
if isempty(filenames)
    error('no .ddt files in %s.', basepath)
end

fprintf(1, '\nFound %d .fet files\n', nfiles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load fet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1 : nfiles
    
    fprintf(1, 'Working on file %s\n', filenames{i});
    [~, basename] = fileparts(filenames{i});
    newname = [basename '.dat'];
    
    fid = fopen(filenames{i}, 'r');
    if(fid == -1);
        error('cannot open file');
    end
    
    nfet = fscanf(fid, '%d', 1);
    fet{i} = fscanf(fid, '%f', [nfet, inf])';
    fclose(fid);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save fet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if saveMat
    [~, filename, ~] = fileparts(basepath);
    save([fullfile(basepath, filename) '.fet.mat'], 'fet')
end

end

% EOF