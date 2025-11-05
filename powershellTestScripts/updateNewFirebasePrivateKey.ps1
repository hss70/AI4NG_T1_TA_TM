# Requires a downloaded Firebase private key JSON file at ../keys/neuroprecise-28bbe-e94b64e3f8a0-firebaseMessagingKey.json
aws secretsmanager update-secret `
  --secret-id neuro-fcm-service-account `
  --secret-string file://../keys/neuroprecise-28bbe-e94b64e3f8a0-firebaseMessagingKey.json `
  --region eu-west-2 `
  --profile hardeepGmail