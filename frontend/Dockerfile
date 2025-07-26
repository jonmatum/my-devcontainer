# Base Node.js image
FROM node:20-slim

# Set working directory
WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm

# Only copy package.json + lockfile first (to leverage Docker cache)
COPY ./app/package.json ./app/pnpm-lock.yaml ./

# Install dependencies separately
RUN if [ -f package.json ]; then pnpm install --frozen-lockfile; fi

# Now copy the entire app source code
COPY ./app ./app

# Set working directory inside app
WORKDIR /app/app

# Make sure entrypoint script is copied and executable
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port for Vite dev server
EXPOSE 3000

# Start the frontend app
CMD ["/entrypoint.sh", "start"]