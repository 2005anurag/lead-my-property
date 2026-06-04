@echo off
echo Starting local server on http://localhost:8000
python -m http.server 8000 || npx http-server -p 8000 || echo "Please install Python or Node.js to run a local server."
pause
