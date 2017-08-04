load environment variables
install service dependencies
install proper verison of ruby
restore bundler cache
bundle install --path vendor/cache
bundle clean
stash bundler cache

============ build phase ============
install Dockerfile
docker build -t $container_name .
ecr-login
docker tag $git_commit # for lookup later
docker push ecr

============ test phase ============
bundle exec rake
