sam build --template-file ..\infra\trainingPipelineTemplate.yaml --region eu-west-2
sam validate --template-file ..\infra\trainingPipelineTemplate.yaml --region eu-west-2 --lint
aws stepfunctions validate-state-machine-definition --definition file://..\infra\EEGProcessingStateMachine.asl.json