FROM ruby:2.5.5

RUN mkdir -p /app
WORKDIR /app

# Various Python and C/build deps
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    python-pycurl

RUN apt-get install -y python3-pip python3-numpy

RUN pip3 install opencv-python
RUN pip3 install Pillow

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update -qq && apt-get install -y libpq-dev nodejs ghostscript

RUN mkdir -p /usr/local/nvm
WORKDIR /app

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY . .
RUN gem install bundler -v 1.17.2
RUN gem install foreman -v 0.85.0
RUN bundle install --verbose --jobs 20 --retry 5
RUN RAILS_ENV=production rails db:migrate
RUN RAILS_ENV=production rake assets:precompile

RUN npm install -g yarn
RUN yarn install --check-files

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-e", "production"]
