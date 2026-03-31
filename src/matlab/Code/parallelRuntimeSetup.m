function poolInfo = parallelRuntimeSetup(defaultWorkers)
% Configure local container-safe parallel execution for MATLAB Runtime.

if nargin == 0 || isempty(defaultWorkers) || ~isnumeric(defaultWorkers) || ~isfinite(defaultWorkers)
    defaultWorkers = 1;
end

poolInfo = struct( ...
    'enabled', false, ...
    'requestedWorkers', double(0), ...
    'actualWorkers', double(0), ...
    'usedProfileFile', "", ...
    'status', "serial");

enabledValue = strtrim(getenv('PARALLEL_ENABLED'));
workersValue = strtrim(getenv('PARALLEL_WORKERS'));
profileValue = strtrim(getenv('PARALLEL_PROFILE_FILE'));

fprintf('Parallel setup: env PARALLEL_ENABLED=%s PARALLEL_WORKERS=%s PARALLEL_PROFILE_FILE=%s\n', ...
    valueOrUnset(enabledValue), valueOrUnset(workersValue), valueOrUnset(profileValue));

if ~isTruthy(enabledValue)
    fprintf('Parallel setup: running serial because PARALLEL_ENABLED is not enabled.\n');
    fprintf('Parallel setup: final status=%s requestedWorkers=%g actualWorkers=%g usedProfileFile=%s\n', ...
        char(poolInfo.status), poolInfo.requestedWorkers, poolInfo.actualWorkers, char(poolInfo.usedProfileFile));
    return;
end

availableCores = getAvailableCoreCount();
requestedWorkers = resolveRequestedWorkers(workersValue, defaultWorkers);
actualWorkers = max(1, min(requestedWorkers, availableCores));

poolInfo.requestedWorkers = double(requestedWorkers);

if isInsideParallelWorker()
    fprintf('Parallel setup: running serial because execution is already inside a parallel worker.\n');
    fprintf('Parallel setup: final status=%s requestedWorkers=%g actualWorkers=%g usedProfileFile=%s\n', ...
        char(poolInfo.status), poolInfo.requestedWorkers, poolInfo.actualWorkers, char(poolInfo.usedProfileFile));
    return;
end

if actualWorkers ~= requestedWorkers
    fprintf('Parallel setup: clamped requested workers from %d to %d based on available cores.\n', ...
        requestedWorkers, actualWorkers);
else
    fprintf('Parallel setup: requested worker count resolved to %d.\n', requestedWorkers);
end

poolInfo = configureOptionalProfile(profileValue, poolInfo);

try
    currentPool = gcp('nocreate');
    if isempty(currentPool)
        processesCluster = parcluster('Processes');
        processesCluster.JobStorageLocation = tempdir;
        fprintf('Parallel setup: starting local Processes pool with %d workers and JobStorageLocation=%s\n', ...
            actualWorkers, processesCluster.JobStorageLocation);
        currentPool = parpool(processesCluster, actualWorkers);
    elseif currentPool.NumWorkers ~= actualWorkers
        fprintf('Parallel setup: restarting existing pool from %d to %d workers.\n', ...
            currentPool.NumWorkers, actualWorkers);
        delete(currentPool);
        processesCluster = parcluster('Processes');
        processesCluster.JobStorageLocation = tempdir;
        currentPool = parpool(processesCluster, actualWorkers);
    else
        fprintf('Parallel setup: reusing existing pool with %d workers.\n', currentPool.NumWorkers);
    end

    poolInfo.enabled = true;
    poolInfo.actualWorkers = double(currentPool.NumWorkers);
    poolInfo.status = "parallel";
    fprintf('Parallel setup: pool startup succeeded with %d workers.\n', currentPool.NumWorkers);
catch ex
    poolInfo.enabled = false;
    poolInfo.actualWorkers = 0;
    poolInfo.status = "serial_fallback";
    warning('parallelRuntimeSetup:PoolStartupFailed', ...
        'Parallel pool startup failed. Falling back to serial execution. Details: %s', ...
        ex.message);
    fprintf('Parallel setup: serial fallback reason=%s\n', ex.message);
end

fprintf('Parallel setup: final status=%s requestedWorkers=%g actualWorkers=%g usedProfileFile=%s\n', ...
    char(poolInfo.status), poolInfo.requestedWorkers, poolInfo.actualWorkers, char(poolInfo.usedProfileFile));

end

function poolInfo = configureOptionalProfile(profileValue, poolInfo)
if isempty(profileValue)
    fprintf('Parallel setup: no profile file provided; using built-in local Processes configuration.\n');
    return;
end

resolvedProfile = resolveProfilePath(profileValue);
if isempty(resolvedProfile)
    fprintf('Parallel setup: profile file "%s" was provided but not found; using built-in local Processes configuration.\n', ...
        profileValue);
    return;
end

if exist('setmcruserdata', 'file') ~= 2
    fprintf('Parallel setup: setmcruserdata is unavailable; skipping optional profile file %s\n', resolvedProfile);
    return;
end

try
    setmcruserdata('ParallelProfile', resolvedProfile);
    poolInfo.usedProfileFile = string(resolvedProfile);
    fprintf('Parallel setup: optional profile file configured: %s\n', resolvedProfile);
catch ex
    fprintf('Parallel setup: optional profile file %s could not be configured (%s); using built-in local Processes configuration.\n', ...
        resolvedProfile, ex.message);
end
end

function requestedWorkers = resolveRequestedWorkers(workersValue, defaultWorkers)
requestedWorkers = sanitizeWorkerCount(defaultWorkers);

if isempty(workersValue)
    fprintf('Parallel setup: PARALLEL_WORKERS is not set; using default worker count %d.\n', requestedWorkers);
    return;
end

parsedWorkers = str2double(workersValue);
if isnan(parsedWorkers) || ~isfinite(parsedWorkers) || parsedWorkers < 1
    fprintf('Parallel setup: PARALLEL_WORKERS=%s is invalid; using default worker count %d.\n', ...
        workersValue, requestedWorkers);
    return;
end

requestedWorkers = sanitizeWorkerCount(parsedWorkers);
end

function workerCount = sanitizeWorkerCount(workerCount)
workerCount = floor(double(workerCount));
if ~isfinite(workerCount) || workerCount < 1
    workerCount = 1;
end
end

function availableCores = getAvailableCoreCount()
availableCores = NaN;

try
    processesCluster = parcluster('Processes');
    clusterWorkers = floor(double(processesCluster.NumWorkers));
    if isfinite(clusterWorkers) && clusterWorkers >= 1
        availableCores = clusterWorkers;
        fprintf('Parallel setup: detected available cores from Processes cluster=%d.\n', availableCores);
        return;
    end
catch
end

try
    featureCores = floor(double(feature('numcores')));
    if isfinite(featureCores) && featureCores >= 1
        availableCores = featureCores;
        fprintf('Parallel setup: detected available cores from feature(''numcores'')=%d.\n', availableCores);
        return;
    end
catch
end

availableCores = 1;
fprintf('Parallel setup: available core detection failed; defaulting to %d.\n', availableCores);
end

function resolvedProfile = resolveProfilePath(profileValue)
resolvedProfile = '';

if exist(profileValue, 'file') == 2
    resolvedProfile = profileValue;
    return;
end

bundledProfile = which(profileValue);
if ~isempty(bundledProfile)
    resolvedProfile = bundledProfile;
end
end

function tf = isTruthy(value)
tf = any(strcmpi(value, {'1', 'true', 'yes', 'on'}));
end

function tf = isInsideParallelWorker()
tf = false;

try
    currentTask = getCurrentTask();
    tf = ~isempty(currentTask);
catch
end
end

function value = valueOrUnset(value)
if isempty(value)
    value = '(unset)';
end
end
