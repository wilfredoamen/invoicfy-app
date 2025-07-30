# Base image
FROM node:22

# Install dependencies required by Puppeteer/Chromium
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    chromium \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy dependency files and install dependencies
COPY package*.json ./

# Install all dependencies (including dev for build)
RUN npm install

# Copy the rest of the application
COPY . .

# Set Puppeteer executable path via env var
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium


# Build the Next.js app
RUN npm run build

# Expose port for the app
EXPOSE 3000

# Start the app in production
CMD ["npm", "run", "dev"]
