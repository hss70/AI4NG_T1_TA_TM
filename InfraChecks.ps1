sam build --template-file .\infra\trainingPipelineTemplate.yaml --region eu-west-2
sam validate --template-file .\infra\trainingPipelineTemplate.yaml --region eu-west-2 --lint