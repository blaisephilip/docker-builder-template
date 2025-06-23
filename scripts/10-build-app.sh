#!/bin/bash

# Start time measurement
START_TIME=$(date +%s)

# Attempt a local npm install to ensure all dependencies are available
# Change to app-frontend directory
cd ../src/app-frontend || exit
# Check if package-lock.json exists
if [ ! -f package-lock.json ]; then
    echo "package-lock.json not found. Running npm install..."
    # If package-lock.json does not exist, run npm install  
    npm install
else
    echo "package-lock.json available, performing a package-lock.json-based install..."
    #if [ -d node_modules ]; then
    # If package-lock.json exists, optionally remove node_modules directory
    #rm -rf node_modules
    #fi
    #npm ci --prefer-offline --no-audit --no-fund --omit=dev --legacy-peer-deps
fi

npm run build -- --prod

# Calculate and display execution time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo "----------------------------------------"
echo "Build completed in ${MINUTES}m ${SECONDS}s"
echo "----------------------------------------"

#node --inspect --trace-warnings src/server.js
#chmod -R a+x node_modules
#npm install serve
#npx serve -s build -l 8000 

#npm start
#node --watch app.js

# Calculate and display execution time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo "----------------------------------------"
echo "Script finished at $(date '+%Y-%m-%d %H:%M:%S')"
echo "----------------------------------------"


