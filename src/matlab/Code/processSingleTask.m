
function processSingleTask(V1_TRANS, wm_taskID)
    if sum(ismember(V1_TRANS.processed_taskIDs,wm_taskID))==0
        if ~exist('T1_result_table', 'var')
            TA_addEmpty_to_resultSummary
        elseif size(T1_result_table,1) < wm_taskID
            TA_addEmpty_to_resultSummary
        end
    else

        fprintf('Processing task %d/%d...\n', wm_taskID, numel(V1_TRANS.tr_file_list));
        copyfile([V1_TRANS.f.chanlocs_dir,'\',V1_TRANS.f.chanlocs_filename], [V1_TRANS.f.BaseDir,'\',V1_TRANS.f.chanlocs_filename]);
        TA_Dataset_Transfer
        VA_TRANS.SW_T1_maxTrainTestTry = V1_TRANS.SW.T1_maxTrainTestTry;
        
        VA_TRANS.subjID_text = V1_TRANS.tr_subDir_list{1,wm_taskID}(find(V1_TRANS.tr_subDir_list{1,wm_taskID}=='\')+1:end);
    
    
        success = false;
        for attempt = 1:3
            try
                VA_TRANS.T1_tryCounter = attempt;
                TAv2_TrainTest
                success = true;
                break
            catch ME
                fprintf('Attempt failed, failed: %s\n', ME.message)
                fprintf('Attempt failed, failed: %s\n', ME.stack)
                fprintf('Attempt /%d /failed, retrying...\n', attempt);
                throw ME
    

            end
        end
        if success
            STACK_restore_01
            TA_append_resultSummary
            TA_copy_T1_files
        else
            STACK_restore_01
            TA_addEmpty_to_resultSummary
        end
        cleanupTempDirs(V1_TRANS);
    end
end
