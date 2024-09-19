# Use the official Python image as a base
FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    xvfb \
    libxi6 \
    libgconf-2-4 \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN wget -q -O - https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > chrome.deb \
    && dpkg -i chrome.deb \
    && apt-get -fy install \
    && rm chrome.deb

# Install ChromeDriver
RUN CHROMEDRIVER_VERSION=$(curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE) \
    && wget https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip \
    && unzip chromedriver_linux64.zip \
    && chmod +x chromedriver \
    && mv chromedriver /usr/local/bin/

# Set environment variables
ENV DISPLAY=:99

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the test code into the container
COPY . /app
WORKDIR /app

# Run tests and generate the HTML report
CMD ["pytest", "--html=/app/report.html"]
