# i'm a monorepo

I have many apps in me and I will run only the ones that need to be run
in CI.

(disclaimer: i gave up on figuring out a good way to run only the jobs for directories that have changed in a given commit because CircleCI doesn't provide a mechanism for "skip build" at the moment. Maybe they will eventually. Follow this thread: https://discuss.circleci.com/t/any-option-as-skip-build-inside-step-command-sections/16598/2)
