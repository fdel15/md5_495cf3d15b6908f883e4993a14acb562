# Start from the official Ruby base image
FROM ruby:3.2.2

# Install Node.js and Yarn
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y nodejs yarn

# Set the working directory for the application
WORKDIR /app

# Copy the Gemfile, Gemfile.lock, and package.json into the image
COPY Gemfile Gemfile.lock package.json ./

# Install the application's dependencies
RUN bundle install

# Install JS dependencies
RUN yarn install

# Copy the main application into the image
COPY . ./

# Expose the application on port 3000
EXPOSE 3000

# Start rails app
CMD sh ./scripts/start.sh
