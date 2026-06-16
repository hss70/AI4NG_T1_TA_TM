% http://www.mathworks.com/matlabcentral/answers/135285-how-do-i-use-save-with-a-parfor-loop-using-parallel-computing-toolbox

function csc_parsave(fname,varargin)
	numvars=numel(varargin);
	for i=1:numvars
	   eval([inputname(i+1),'=varargin{i};']);  
	end
	save('-mat',fname,inputname(2));
	for i = 2:numvars    
		save('-mat',fname,inputname(i+1),'-append');
	end
end










