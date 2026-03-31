function parallelRuntimeDiagnostics(stageName)
% Print preflight information for deployed parallel execution.

if nargin == 0 || isempty(stageName)
    stageName = 'unspecified';
end

parallelEnabled = strtrim(getenv('PARALLEL_ENABLED'));
parallelWorkers = strtrim(getenv('PARALLEL_WORKERS'));
parallelLocation = strtrim(getenv('PARALLEL_LOCATION'));
parallelProfileFile = strtrim(getenv('PARALLEL_PROFILE_FILE'));

if isempty(parallelEnabled)
    parallelEnabled = '(unset)';
end
if isempty(parallelWorkers)
    parallelWorkers = '(unset)';
end
if isempty(parallelLocation)
    parallelLocation = '(unset)';
end
if isempty(parallelProfileFile)
    parallelProfileFile = '(unset)';
end

fprintf('Parallel preflight [%s]: enabled=%s workers=%s location=%s profile=%s\n', ...
    stageName, parallelEnabled, parallelWorkers, parallelLocation, parallelProfileFile);

resolvedProfilePath = which('deployLocal.mlsettings');
if isempty(resolvedProfilePath)
    fprintf('Parallel preflight [%s]: bundled deployLocal.mlsettings not found on MATLAB path.\n', stageName);
else
    fprintf('Parallel preflight [%s]: bundled profile found at %s\n', stageName, resolvedProfilePath);
end

fprintf('Parallel preflight [%s]: setmcruserdataAvailable=%d isdeployed=%d\n', ...
    stageName, exist('setmcruserdata', 'file') == 2, isdeployed);

try
    currentPool = gcp('nocreate');
    if isempty(currentPool)
        fprintf('Parallel preflight [%s]: no existing parallel pool is open.\n', stageName);
    else
        fprintf('Parallel preflight [%s]: existing pool is open with %d workers.\n', ...
            stageName, currentPool.NumWorkers);
    end
catch ex
    fprintf('Parallel preflight [%s]: pool inspection failed: %s\n', stageName, ex.message);
end
end
