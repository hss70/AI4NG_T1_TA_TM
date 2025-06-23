#!/bin/bash

echo "Installing VS Code extensions..."
while read extension; do
  code --install-extension "$extension"
done < extensions.txt

echo "Copying settings.json..."
mkdir -p ~/.config/Code/User
cp .vscode/settings.json ~/.config/Code/User/settings.json

echo "✅ VS Code environment setup complete."
