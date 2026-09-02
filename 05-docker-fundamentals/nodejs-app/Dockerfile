# Stage 1: Base runtime
FROM node:18-alpine

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package descriptors
COPY package*.json ./

# Install production dependencies
RUN npm install --only=production

# Copy application source code
COPY . .

# Expose internal container port
EXPOSE 3000

# Set non-root user for security best practices
USER node

# Start command
CMD ["node", "server.js"]
