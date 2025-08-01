# Use the official Node.js latest image as the base image
FROM node:latest

# Create and set the working directory
WORKDIR /home/node

# Copy the package.json and package-lock.json files to the working directory
COPY package.json .

# Install the dependencies
RUN npm install

RUN npm install -g nodemon

# Copy the index.js file to the working directory
COPY index.js ./

# Expose port 3000
EXPOSE 3000

# Start the server
CMD ["nodemon", "--watch", ".", "--legacy-watch", "index.js"]