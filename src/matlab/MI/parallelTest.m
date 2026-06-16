disp(version)
% c = parcluster("Processes");   % or "Threads"
c = parcluster("Threads");
disp(c.NumWorkers)

parpool(c, min(2, c.NumWorkers));
x = zeros(1,4);
parfor i = 1:4
    pause(1);
    x(i) = i^2;
end
disp(x)
delete(gcp("nocreate"))