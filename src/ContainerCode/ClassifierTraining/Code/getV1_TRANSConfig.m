function V1_TRANS = getV1_TRANSConfig( ...
        HomeDir, ...
        ChanLocDir, channelNumber, sampleRate, downsampleRate)
%GETV1_TRANSCONFIG   Build the V1_TRANS struct with container-friendly paths.
%
%   V1_TRANS = GETV1_TRANSCONFIG()
%       Uses defaults:
%         • HomeDir        = getenv('PROJECT_ROOT') if set; otherwise parent(pwd)
%         • SourceDataName = 'EEG_rec.mat'
%         • PreviousResultDir = fullfile(HomeDir,'Work','T1','Results')
%         • chanlocs_filename = 'Standard-10-20-Cap81.locs'
%         • save__T1_results  = 0
%
%   V1_TRANS = GETV1_TRANSCONFIG(HomeDir, SourceDataName, PreviousResultDir, ...
%                                chanlocs_filename, save__T1_results)
%       Overrides any of the five inputs. All paths are built via fullfile()
%       so that Linux‐based containers (or Windows) work transparently.
%
%   Example (inside a Docker container where /app is mounted as PROJECT_ROOT):
%       V1_TRANS = getV1_TRANSConfig(); 
%       % Sets HomeDir = '/app' (from getenv), then builds all subfolders.

    % 1) DETERMINE HomeDir
    if nargin < 1 || isempty(HomeDir)
        % Try environment variable first (e.g. set in Dockerfile or run command)
        homeEnv = getenv('PROJECT_ROOT');
        if ~isempty(homeEnv)
            HomeDir = homeEnv;
        else
            % Fallback: parent directory of current working folder
            tmp = pwd;
            cd('..');
            HomeDir = pwd;
            cd(tmp);
        end
    end

    % Normalize HomeDir: replace any backslashes with filesep
    HomeDir = strrep(HomeDir, '\', filesep);

    % === Build all subfolders/filenames with fullfile ===
    % Top‐level “fields” struct
    V1_TRANS.f.HomeDir           = HomeDir;
    V1_TRANS.f.SourceDataDir     = fullfile(HomeDir, 'Work', 'SourceData (EEG_rec)');
    V1_TRANS.f.SourceDataName    = 'EEG_rec.mat';
    V1_TRANS.f.PreviousResultDir = fullfile(HomeDir, 'Work', 'T1', 'Results');

    V1_TRANS.f.BaseDir           = fullfile(HomeDir, 'Work');
    V1_TRANS.f.DataSubDir        = 'TMP Data';
    V1_TRANS.f.TrainTestSubDir   = 'TrainTest';
    V1_TRANS.f.Subj1Sess1SubDir  = fullfile('Subj 01', 'Session 01');

    % Only one classification subfolder in this version
    V1_TRANS.f.classSubDir{1}    = 'EEG';

    % T1‐related subdirectories
    V1_TRANS.f.T1_subDir             = 'T1';
    V1_TRANS.f.T1_online_subSubDir   = 'Online';
    V1_TRANS.f.T1_param_subSubDir    = 'Param';
    V1_TRANS.f.T1_param2_subSubDir   = '';
    V1_TRANS.f.T1_results_subSubDir  = 'Results';
    V1_TRANS.f.save__T1_results      = 1;

    % Channel‐location directory and file
    V1_TRANS.f.chanlocs_dir       = ChanLocDir;%fullfile(HomeDir, 'Code');
    V1_TRANS.f.chanlocs_filename  = 'Standard-10-20-Cap81.locs';

    % === Other high‐level flags/arrays ===
    V1_TRANS.processed_taskIDs       = '';
    V1_TRANS.SW.T1_maxTrainTestTry   = 0;

    % EEG config
    V1_TRANS.NumberOfChannels = channelNumber;
    V1_TRANS.sr = sampleRate;
    V1_TRANS.downsamp.sr = downsampleRate;

    % End of function; V1_TRANS struct is returned
end
