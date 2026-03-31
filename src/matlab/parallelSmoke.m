function parallelSmoke(nWorkers)
    if nargin == 0 || isempty(nWorkers)
        nWorkers = 2;
    end

    % Standalone app command-line args arrive as strings/chars.
    if ischar(nWorkers) || isStringScalar(nWorkers)
        nWorkers = str2double(nWorkers);
    end

    if ~isscalar(nWorkers) || isnan(nWorkers) || nWorkers < 1
        error("Invalid nWorkers input. Received: %s", string(nWorkers));
    end

    fprintf("Version: %s\n", version);
    fprintf("Host: %s\n", getenv("HOSTNAME"));
    fprintf("Raw requested workers after parse: %d\n", nWorkers);

    c = parcluster("Processes");
    fprintf("Profile: %s\n", c.Profile);
    fprintf("Cluster NumWorkers before override: %d\n", c.NumWorkers);

    c.JobStorageLocation = tempdir;
    nWorkers = min(floor(nWorkers), c.NumWorkers);

    fprintf("Final requested workers: %d\n", nWorkers);

    tStart = tic;

    % Ask parpool directly for the worker count.
    p = parpool("Processes", nWorkers);
    fprintf("Actual pool workers: %d\n", p.NumWorkers);

    x = zeros(1, 8);
    parfor i = 1:8
        pause(1);
        x(i) = i^2;
    end

    elapsed = toc(tStart);

    disp(x)
    fprintf("Elapsed: %.2f seconds\n", elapsed);

    delete(p);
end