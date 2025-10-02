#!/bin/bash

# Test script to check which Gemini models are available
API_KEY="AIzaSyBdQ5cHwQCUaTvr8qywxBxEHFyT1rETWYQ"

echo "Testing Gemini API models..."
echo "================================"

# Test 1: List available models
echo -e "\n1. Listing available models:"
curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=$API_KEY" | jq '.models[] | {name: .name, supportedGenerationMethods: .supportedGenerationMethods}'

# Test 2: Try gemini-1.5-flash
echo -e "\n2. Testing gemini-1.5-flash:"
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{"text": "Hello, say hi back"}]
    }]
  }' | jq '.candidates[0].content.parts[0].text // .error'

# Test 3: Try gemini-1.5-pro
echo -e "\n3. Testing gemini-1.5-pro:"
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{"text": "Hello, say hi back"}]
    }]
  }' | jq '.candidates[0].content.parts[0].text // .error'

# Test 4: Try gemini-pro
echo -e "\n4. Testing gemini-pro:"
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{"text": "Hello, say hi back"}]
    }]
  }' | jq '.candidates[0].content.parts[0].text // .error'

echo -e "\n================================"
echo "Test complete!"
