function buildParallelSmoke()
    outDir = fullfile(pwd, "Deployment", "ParallelSmoke");

    if ~exist(outDir, "dir")
        mkdir(outDir);
    end

    mcc( ...
        "-m", "parallelSmoke.m", ...
        "-d", outDir ...
    );

    fprintf("Build complete. Output folder: %s\n", outDir);
end