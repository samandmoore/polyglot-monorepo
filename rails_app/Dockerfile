FROM ruby:2.3.1

RUN apt-get update -qq && apt-get install -y build-essential

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for a JS runtime
RUN apt-get install -y nodejs

ENV GEM_HOME /tmp/gems
WORKDIR $GEM_HOME
ADD Gemfile* $GEM_HOME/
RUN bundle install --path vendor/bundle --without development:test

ENV APP_HOME /project_app
WORKDIR $APP_HOME

RUN mv $GEM_HOME/vendor/bundle vendor/bundle

# if we build a bundle on the same arch,
# then this will short-circuit bundling in the container
# ADD Gemfile* $APP_HOME/
# ADD vendor/bundle $APP_HOME/vendor/bundle
# RUN bundle install --local --path vendor/bundle --without development:test

ADD . $APP_HOME

CMD bundle exec rake RAILS_ENV=production assets:precompile
