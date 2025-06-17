%workDir = getenv('WORK_DIR');
%Converts Csvs into .mat files and ensures they're in the right palce
batchConvertCsvToMat;

T1_proper;

%T1ResultsDir = GetEnv()
%outputDir = GetEnv
%reorganiseFiles(T1ResultsDir, outputDir);
reorganiseFiles('C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\Work\T1', ...
                 'C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\Work\Output');