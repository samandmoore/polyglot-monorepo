#!/usr/bin/env ruby

def build_local_gem_lines(app_name)
  local_gems = []
  IO.foreach("#{app_name}/Gemfile") do |l|
    if l =~ /path:/
      path = l.scan(/path: ['"]([^'"]+)['"]/).first.first
      local_gems << File.basename(path)
    end
  end

  local_gems.map do |g|
    "ADD #{g} /project/#{g}"
  end
end

BASE = <<~DOCKERFILE
FROM ruby:2.3.1

RUN apt-get update -qq && apt-get install -y build-essential

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for a JS runtime
RUN apt-get install -y nodejs

ENV APP_HOME /project/project_app
WORKDIR $APP_HOME

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
DOCKERFILE

raise "you must provide an app directory" unless ARGV[0]

app_name = ARGV[0]
lines = []
lines << "ADD #{app_name}/Gemfile* $APP_HOME/"
lines = lines.concat(build_local_gem_lines(app_name))
lines << <<~CHUNK
# if we build a bundle on the same arch,
# then this will short-circuit bundling in the container
ADD rails_app/Gemfile* $APP_HOME/
ADD rails_app/vendor/bundle $APP_HOME/vendor/bundle
# no matter what, we need to add this line in.
RUN bundle install --path vendor/bundle --without development:test
CHUNK
lines << "ADD #{app_name} $APP_HOME"
lines << "# RUN bundle exec rake assets:precompile"
lines << "EXPOSE 3000"
lines << <<~CHUNK
CMD ["rails", "server", "-b", "0.0.0.0"]"
CHUNK

puts BASE
puts lines.join("\n")
