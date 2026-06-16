function pool = ensureParpool(location, requestedWorkers, reOpenIfOpen)
  pool = gcp('nocreate');

  if isempty(pool) || (reOpenIfOpen == 1)
    delete(pool);

    cpar = parcluster(location);

    disp("Parallel diag before adjustment:");
    disp("  location        = " + string(location));
    disp("  requested       = " + string(requestedWorkers));
    disp("  cluster max now = " + string(cpar.NumWorkers));

    if cpar.NumWorkers < requestedWorkers
      cpar.NumWorkers = requestedWorkers;
    end

    disp("Parallel diag after adjustment:");
    disp("  cluster max now = " + string(cpar.NumWorkers));

    pool = parpool(cpar, requestedWorkers);
  else
    disp("Reusing existing parpool with " + string(pool.NumWorkers) + " workers.");
  end
end