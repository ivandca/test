#!/bin/bash

# Prompt the user for the URL and port number
echo "Starting the FirefoxDriver automation script..."
read -p "Enter the URL to navigate to: " URL
read -p "Enter the FirefoxDriver port: " DRIVER_PORT

# Wait for a moment to ensure the driver is already running
echo "Using FirefoxDriver on port $DRIVER_PORT..."
sleep 2

echo
echo
# Create a session and capture the response
echo "Creating a session with FirefoxDriver..."
SESSION_RESPONSE=$(curl -s --location "http://localhost:$DRIVER_PORT/session" \
--header 'Content-Type: application/json' \
--data '{
    "capabilities": {
        "firstMatch": [
            {
                "acceptInsecureCerts": true,
                "browserName": "firefox",
                "moz:debuggerAddress": true,
                "moz:firefoxOptions": {
                    "prefs": {
                        "remote.active-protocols": 3
                    }
                },
                "unhandledPromptBehavior": "ignore"
            }
        ]
    }
}')

echo
echo
# Print the session response
echo "Session successfully created. Session Response: $SESSION_RESPONSE"

# Extract the session ID from the response
SESSION_ID=$(echo $SESSION_RESPONSE | grep -o '"sessionId":"[^"]*' | cut -d '"' -f 4)
echo "Extracted Session ID: $SESSION_ID"

echo
echo
# Prompt the user for the session ID for subsequent steps
read -p "Enter the session ID for subsequent steps (or press Enter to use $SESSION_ID): " USER_SESSION_ID
if [ -z "$USER_SESSION_ID" ]; then
    USER_SESSION_ID=$SESSION_ID
fi

echo "Using Session ID: $USER_SESSION_ID"
echo

# Navigate to the provided URL
echo "Navigating to the provided URL: $URL"
curl -s -X POST "http://localhost:$DRIVER_PORT/session/$USER_SESSION_ID/url" \
-H "Content-Type: application/json" \
-d "{\"url\": \"$URL\"}"

# Get the page title
echo
echo "Fetching the page title..."
TITLE_RESPONSE=$(curl -s -X GET "http://localhost:$DRIVER_PORT/session/$USER_SESSION_ID/title")
echo "Page Title: $TITLE_RESPONSE"

# Prompt to close the session
read -p "Press Enter to close the session..." a

echo
echo "Closing the session..."
# Close the session
curl -s -X DELETE "http://localhost:$DRIVER_PORT/session/$USER_SESSION_ID"

echo "FirefoxDriver session closed. Script execution complete."
