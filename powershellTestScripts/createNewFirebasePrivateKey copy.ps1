# requires firebase key in ../keys/neuroprecise-28bbe-e94b64e3f8a0-firebaseMessagingKey.json
aws secretsmanager create-secret `
  --name neuro-fcm-service-account `
  --description "Firebase service account for FCM HTTP v1" `
  --secret-string file://../keys/neuroprecise-28bbe-e94b64e3f8a0-firebaseMessagingKey.json `
  --region eu-west-2 `
  --profile hardeepGmail
