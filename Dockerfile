# 1. Use the lightweight Python 3.10 "Slim" image
# It is small but has everything you need to run Python code.
FROM python:3.10-slim

# 2. Create the working folder inside the container
WORKDIR /app

# 3. Copy the requirements file first (for caching speed)
COPY requirements.txt .

# 4. Install dependencies
# Since we are in a single stage, we just install them normally.
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the rest of your application code
COPY . .

# 6. Documentation: Tell Docker we listen on port 5000
EXPOSE 5000

# 7. The command to run your app
CMD ["python", "app.py"]