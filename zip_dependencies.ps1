#This script moves all the 
# Define the output zip file path
$zipPath = Join-Path -Path (Get-Location) -ChildPath "FBCSP_Dependencies.zip"

# List of file paths to include in the zip
$filePaths = @(
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\CrossRun_VC_FBCSP_online_setup_prep_01.m",
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\CrossRun_VC_FBCSP_online_setup_prep_funct_01.m",
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\STACK_allVariables_01.m",
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\STACK_restore_01.m",
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\T1_TA_TM.m",
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\TA_Dataset_Transfer.m",
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\TA_addEmpty_to_resultSummary.m",
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\TA_append_resultSummary.m",
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\TA_copy_T1_files.m",
    "C:\Users\Hardeep\Documents\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\TA_copy_T1_online_files.m",
    # ... (The rest of the paths follow the same pattern)
    "C:\Users\Hardeep\Downloads\FBCSP 2022-CL-20240925T135336Z-001\FBCSP 2022-CL\Code\Toolboxes for FBCSP\add to path\eeglab14_1_1b\functions\sigprocfunc\topoplot.m"
)

# Create a zip file with the listed files
Compress-Archive -Path $filePaths -DestinationPath $zipPath -Force

Write-Host "Zip archive created at $zipPath"
