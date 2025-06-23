#!/bin/bash

echo "Installing VS Code extensions..."
while IFS= read -r extension || [[ -n "$extension" ]]; do
  extension=$(echo "$extension" | xargs) # trim
  if [[ -n "$extension" ]]; then
    echo "Installing $extension..."
    code --install-extension "$extension" || echo "❌ Failed: $extension"
  fi
done < extensions.txt

echo "Copying settings.json..."
if [ -f ".vscode/settings.json" ]; then
  mkdir -p ~/.config/Code/User
  cp .vscode/settings.json ~/.config/Code/User/settings.json
  echo "✅ settings.json copied"
else
  echo "⚠️  .vscode/settings.json not found"
fi

echo "✅ VS Code environment setup complete."
