function parCore = parallelRuntimeSetup(parCore)
% Configure deployed parallel profile support and open a local pool when enabled.

if nargin == 0 || isempty(parCore)
    parCore = struct();
end

parCore.profileConfigured = false;
parCore.profileStatus = 'not_checked';
parCore.poolStatus = 'not_checked';
parCore.poolWorkerCount = 0;

parCore = applyParallelEnvOverrides(parCore);
parCore = applyDeployedParallelProfile(parCore);
parCore = ensureParallelPool(parCore);
logParallelStatus(parCore);

end

function parCore = applyParallelEnvOverrides(parCore)
enabledValue = strtrim(getenv('PARALLEL_ENABLED'));
workerValue = strtrim(getenv('PARALLEL_WORKERS'));
locationValue = strtrim(getenv('PARALLEL_LOCATION'));
reopenValue = strtrim(getenv('PARALLEL_REOPEN'));
closeValue = strtrim(getenv('PARALLEL_CLOSE_AT_END'));

if isempty(enabledValue)
    return;
end

if isTruthy(enabledValue)
    parCore.parforUsed = 1;
else
    parCore.parforUsed = 0;
end

if ~isempty(workerValue)
    workerCount = str2double(workerValue);
    if ~isnan(workerCount) && isfinite(workerCount) && workerCount >= 0
        parCore.number_basis = floor(workerCount);
    end
end

if ~isempty(locationValue)
    parCore.location = locationValue;
elseif ~isfield(parCore, 'location') || isempty(parCore.location)
    parCore.location = 'local';
end

if ~isempty(reopenValue)
    parCore.reOpenIfOpen = double(isTruthy(reopenValue));
end

if ~isempty(closeValue)
    parCore.closeAtEnd = double(isTruthy(closeValue));
end
end

function parCore = applyDeployedParallelProfile(parCore)
profilePath = getParallelProfilePath();
parCore.profilePath = profilePath;

if isempty(profilePath)
    parCore.profileStatus = 'not_found';
    fprintf('Parallel profile not found. Continuing without bundled profile.\n');
    return;
end

if exist('setmcruserdata', 'file') ~= 2
    parCore.profileStatus = 'setmcruserdata_unavailable';
    fprintf('setmcruserdata is not available in this MATLAB context. Profile path resolved to %s\n', profilePath);
    return;
end

try
    setmcruserdata('ParallelProfile', profilePath);
    parCore.profileConfigured = true;
    parCore.profileStatus = 'configured';
    fprintf('Parallel profile configured: %s\n', profilePath);
catch ex
    parCore.profileStatus = 'configuration_failed';
    warning('parallelRuntimeSetup:ProfileConfigFailed', ...
        'Unable to configure deployed parallel profile "%s": %s', ...
        profilePath, ex.message);
end
end

function parCore = ensureParallelPool(parCore)
if ~isfield(parCore, 'parforUsed') || parCore.parforUsed ~= 1
    parCore.poolStatus = 'disabled';
    return;
end

if ~isfield(parCore, 'number_basis') || isempty(parCore.number_basis)
    parCore.number_basis = 0;
end

if ~isfield(parCore, 'reOpenIfOpen') || isempty(parCore.reOpenIfOpen)
    parCore.reOpenIfOpen = 0;
end

if ~isfield(parCore, 'closeAtEnd') || isempty(parCore.closeAtEnd)
    parCore.closeAtEnd = 0;
end

if ~isfield(parCore, 'location') || isempty(parCore.location)
    parCore.location = 'local';
end

if parCore.number_basis == -1
    if ~isfield(parCore, 'number') || isempty(parCore.number)
        warning('parallelRuntimeSetup:DynamicWorkersUnavailable', ...
            'Parallel worker count requested as dynamic (-1), but no computed worker count was supplied. Running serial.');
        parCore.parforUsed = 0;
        parCore.poolStatus = 'dynamic_worker_resolution_failed';
        return;
    end
else
    parCore.number = parCore.number_basis;
end

if parCore.number <= 0
    warning('parallelRuntimeSetup:InvalidWorkerCount', ...
        'Parallel worker count resolved to %d. Running serial.', parCore.number);
    parCore.parforUsed = 0;
    parCore.poolStatus = 'invalid_worker_count';
    return;
end

try
    currentPool = gcp('nocreate');
    if isempty(currentPool) || parCore.reOpenIfOpen == 1
        if ~isempty(currentPool)
            delete(currentPool);
        end
        parpool(parCore.location, parCore.number);
    end
    currentPool = gcp('nocreate');
    if isempty(currentPool)
        parCore.poolStatus = 'not_open';
    else
        parCore.poolStatus = 'open';
        parCore.poolWorkerCount = currentPool.NumWorkers;
    end
catch ex
    warning('parallelRuntimeSetup:PoolInitFailed', ...
        'Parallel pool initialization failed. Falling back to serial execution. Details: %s', ...
        ex.message);
    parCore.parforUsed = 0;
    parCore.poolStatus = 'fallback_serial';
end
end

function profilePath = getParallelProfilePath()
profilePath = '';

envProfile = strtrim(getenv('PARALLEL_PROFILE_FILE'));
if ~isempty(envProfile)
    if exist(envProfile, 'file') == 2
        profilePath = envProfile;
        return;
    end
    bundledProfile = which(envProfile);
    if ~isempty(bundledProfile)
        profilePath = bundledProfile;
        return;
    end
end

defaultProfile = which('deployLocal.mlsettings');
if ~isempty(defaultProfile)
    profilePath = defaultProfile;
end
end

function tf = isTruthy(value)
tf = any(strcmpi(value, {'1', 'true', 'yes', 'on'}));
end

function logParallelStatus(parCore)
if ~isfield(parCore, 'parforUsed')
    parforUsedValue = 0;
else
    parforUsedValue = parCore.parforUsed;
end

if ~isfield(parCore, 'location') || isempty(parCore.location)
    locationValue = 'local';
else
    locationValue = parCore.location;
end

if ~isfield(parCore, 'number_basis') || isempty(parCore.number_basis)
    requestedWorkers = NaN;
else
    requestedWorkers = parCore.number_basis;
end

if ~isfield(parCore, 'number') || isempty(parCore.number)
    resolvedWorkers = NaN;
else
    resolvedWorkers = parCore.number;
end

fprintf(['Parallel runtime status: enabled=%d location=%s requestedWorkers=%g ', ...
    'resolvedWorkers=%g profileStatus=%s poolStatus=%s poolWorkers=%d\n'], ...
    parforUsedValue, locationValue, requestedWorkers, resolvedWorkers, ...
    parCore.profileStatus, parCore.poolStatus, parCore.poolWorkerCount);
end
