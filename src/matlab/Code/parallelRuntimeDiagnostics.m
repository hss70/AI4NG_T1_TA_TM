function parallelRuntimeDiagnostics(stageName)
% Log container-safe parallel diagnostics for deployed MATLAB Runtime jobs.

if nargin == 0 || isempty(stageName)
    stageName = 'startup';
end

parallelEnabled = valueOrUnset(strtrim(getenv('PARALLEL_ENABLED')));
parallelWorkers = valueOrUnset(strtrim(getenv('PARALLEL_WORKERS')));
parallelProfileFile = valueOrUnset(strtrim(getenv('PARALLEL_PROFILE_FILE')));
hostName = getHostName();
availableCores = getAvailableCoreCount();

fprintf('Parallel diagnostics [%s]: matlabVersion=%s\n', stageName, version);
fprintf('Parallel diagnostics [%s]: hostname=%s\n', stageName, hostName);
fprintf('Parallel diagnostics [%s]: PARALLEL_ENABLED=%s PARALLEL_WORKERS=%s PARALLEL_PROFILE_FILE=%s\n', ...
    stageName, parallelEnabled, parallelWorkers, parallelProfileFile);
fprintf('Parallel diagnostics [%s]: setmcruserdataAvailable=%d isdeployed=%d tempdir=%s availableCores=%d\n', ...
    stageName, exist('setmcruserdata', 'file') == 2, isdeployed, tempdir, availableCores);

try
    currentPool = gcp('nocreate');
    if isempty(currentPool)
        fprintf('Parallel diagnostics [%s]: existingPool=open:false workers=0\n', stageName);
    else
        fprintf('Parallel diagnostics [%s]: existingPool=open:true workers=%d\n', ...
            stageName, currentPool.NumWorkers);
    end
catch ex
    fprintf('Parallel diagnostics [%s]: existingPool=inspection_failed reason=%s\n', ...
        stageName, ex.message);
end
end

function hostName = getHostName()
hostName = strtrim(getenv('HOSTNAME'));
if ~isempty(hostName)
    return;
end

hostName = strtrim(getenv('COMPUTERNAME'));
if ~isempty(hostName)
    return;
end

[status, cmdout] = system('hostname');
if status == 0
    hostName = strtrim(cmdout);
else
    hostName = 'unknown';
end
end

function availableCores = getAvailableCoreCount()
availableCores = NaN;

try
    processesCluster = parcluster('Processes');
    clusterWorkers = floor(double(processesCluster.NumWorkers));
    if isfinite(clusterWorkers) && clusterWorkers >= 1
        availableCores = clusterWorkers;
        return;
    end
catch
end

try
    featureCores = floor(double(feature('numcores')));
    if isfinite(featureCores) && featureCores >= 1
        availableCores = featureCores;
        return;
    end
catch
end

availableCores = 1;
end

function value = valueOrUnset(value)
if isempty(value)
    value = '(unset)';
end
end
