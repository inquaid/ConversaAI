#!/bin/bash

# Quick test with the correct model
echo "Testing gemini-flash-latest with conversational prompt:"
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=AIzaSyBdQ5cHwQCUaTvr8qywxBxEHFyT1rETWYQ" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "You are an interactive English-speaking companion. User said: hello what are you"
      }]
    }],
    "generationConfig": {
      "temperature": 0.7,
      "maxOutputTokens": 200
    }
  }' | jq '.candidates[0].content.parts[0].text'
