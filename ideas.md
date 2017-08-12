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
  SOLUTION: use a script to generate the dockerfile
* if we bundle on the build machine then copy that bundle into the
  container, we can save time on subsequent builds without having to
  pull the most recent version for the container we're building. this
  only works if we're using the same cpu arch on build machines as in
  our containers. this would make sense if we're building on circleci
  and can cache the bundle using their nifty bundle caching mechanism.
  otherwise, we will wanna pull the latest version for the container
  we're building before building it so that we can leverage cached
  layers.
* configuration yml file for each app that can be read and translated
  into dockerfile configuration bits. e.g. we need to allow for
  specification of ruby version at a minimum. we could bundle mysql
  dev and pg dev kits in all containers to keep that simple. we should
  also support a node version specification.
* the container is designed to be used such with rails apps that think
  of all non-local environments as "production" environments. if you use
  "staging" as a proper Rails.env then this container won't work for
  you. we can consider doing that differently, but this is much simpler.
* can we use a simpler base image? the current ruby base images are
  yuuuuuge (>1GB). 


ruby thoughts
* we need to distinguish between ruby gems and local gems that don't get
  published (acting more as a library).
  * for a ruby gem we don't check in the gemfile.lock, so we can't use
    that as the cache key for the bundle
