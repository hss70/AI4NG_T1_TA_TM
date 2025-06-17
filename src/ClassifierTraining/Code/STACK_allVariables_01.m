
% ____________________________________
% 
% Stacking all variables into STACK(1)
% ____________________________________

STACK(1).varNameList = who;
for wm_STACK = 1 : size(STACK(1).varNameList,1)
    eval(['STACK(1).var{wm_STACK} =', STACK(1).varNameList{wm_STACK}, ';'])
end

% Delete variables expect STACK
% _____________________________

% clearvars -except STACK

% % % _______________________________
% % % 
% % % Restore variables from STACK(1)
% % % _______________________________
% % 
% % for wm_STACK = 1 : size(STACK(1).varNameList,1)
% %     eval([STACK(1).varNameList{wm_STACK}, '= STACK(1).var{wm_STACK};'])
% % end
% % 
% % % Delete STACK
% % % ____________
% % 
% % clearvars STACK wm_STACK

