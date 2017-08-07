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

=============================================================

to figure out:
* path-based gems are frustrating. they require you to run docker from
  a parent directory that has the path-based gems and the target source
  directory in its sub-tree. it then also requires manual adding of the
  path-based gems to the container prior to bundling.
* if we bundle on the build machine then copy that bundle into the
  container, we can save time on subsequent builds without having to
  pull the most recent version for the container we're building. this
  only works if we're using the same cpu arch on build machines as in
  our containers. this would make sense if we're building on circleci
  and can cache the bundle using their nifty bundle caching mechanism.
  otherwise, we will wanna pull the latest version for the container
  we're building before building it so that we can leverage cached
  layers.
