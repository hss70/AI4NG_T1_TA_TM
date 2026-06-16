function wf_out_str = subFunc_num2str_2digit(wf_in_num)
    % function call test:
    % fprintf([subFunc_num2str_2digit(2),'...\n']);
    if wf_in_num < 10
        wf_out_str = ['0',num2str(wf_in_num)];
    else
        wf_out_str = num2str(wf_in_num);
    end
end
