sam build --template-file ..\infra\trainingPipelineTemplate.yaml --region eu-west-2
sam validate --template-file ..\infra\trainingPipelineTemplate.yaml --region eu-west-2 --lint
aws stepfunctions validate-state-machine-definition --region eu-west-2 --definition ..\infra\EEGProcessingStateMachine.asl.json