FROM node:lts-slim AS builder

# Install git and essential build tools
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

#LABEL org.opencontainers.image.source= "Add here the URL of your source code repository"
#LABEL org.opencontainers.image.description= "Add here a description of your image"
#LABEL org.opencontainers.image.licenses= "Add here the license of your image"
#LABEL org.opencontainers.image.authors= "Add here the authors of your image"
#LABEL org.opencontainers.image.vendor= "Add here the vendor of your image"
#LABEL org.opencontainers.image.version= "Add here the version of your image"
#LABEL org.opencontainers.image.title= "Add here the title of your image"
#LABEL org.opencontainers.image.documentation= "Add here the documentation of your image"

# set working directory
RUN mkdir -p /usr/src/add-frontend
WORKDIR /usr/src/add-frontend

# Copies package.json and package-lock.json to Docker environment
COPY package*.json /usr/src/add-frontend
ADD src /usr/src/add-frontend/src
ADD fonts /usr/src/add-frontend/fonts
ADD public /usr/src/add-frontend/public

COPY .env.production /usr/src/add-frontend
# Copy the .npmrc file if it exists
# Check if the .npmrc file exists in the context
RUN if [ -f ".npmrc" ]; then \
        echo ".npmrc file found, copying it to the container..."; \
        COPY .npmrc /usr/src/add-frontend/.npmrc \
    else \
        echo ".npmrc file not found, skipping copy."; \
    fi

# Conditional npm install based on .npmrc existence
RUN if [ -f ".npmrc" ]; then \
        echo "Installing with custom .npmrc..." && \
        --mount=type=secret,id=npmrc,target=/usr/src/add-frontend/.npmrc npm ci --omit=dev --legacy-peer-deps; \
    else \
        echo "Installing without .npmrc..." && \
        npm ci --prefer-offline --no-audit --no-fund --omit=dev --legacy-peer-deps; \
    fi

# Build for production.
RUN npm run build

FROM node:lts-slim

# Set working directory
WORKDIR /usr/src/add-frontend
# Copy build artifacts from the builder stage
COPY --from=builder /usr/src/add-frontend/build ./build

# Create the folder where the DB will be mounted
RUN mkdir -p ./db
RUN mkdir -p ./log

# Disable SSL verification (no certificate in the image / container will be stored)
RUN npm config set strict-ssl false
# Install `serve` to run the application.
RUN npm install -g serve
# Expose of port of actual application, and the SSH port for debugging purposes

EXPOSE 8000

# Run application
CMD serve -s build -l 8000 
