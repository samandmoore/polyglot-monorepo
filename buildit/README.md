# continuous integration tooling

## config generation

Project
* directory
* name
* type
* config
* dependencies: List<Project>

FilesystemProjectDiscovery
* in: directory
* out: List<Project>

ProjectProcessor
* in: List<Project>
* out: config.yml

design thoughts:
* separate the reading of configs off the filesystem from the processing
  of them

test cases:
* for each project type, we should be able to test various hash-based
  inputs (as if from yml) and verify the output yml chunk
* for a given set of projects, we should be able to verify that the
  workflow is constructed properly

## tests to run calculation

ProjectChangeEvaluation
* in: List<FileChange>, List<Project>
* out: projects to run tests for
