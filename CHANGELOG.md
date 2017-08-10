# Change Log
All notable changes to all repositories in this project will be documented in this file. 

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased
### `mapic/mapic`
- Additions to Mapic CLI: `mapic tor`, `mapic info`
- Implemented Tor Project relay-only on all nodes
- Moved most configuration to ENV
- Added visualizer for Docker nodes @ localhost:8080
    - Port 8080 is blocked in AWS, so only ssh tunnel can access visualizer
    - Need to add `LocalForward 8080 localhost:8080` to /.ssh/config on your localhost
- Replicating mode 
- Bugfixes


## [17.7](https://github.com/mapic/mapic/releases/tag/v17.7)
Released: 2017-07-03
### `mapic/mapic`
- Many additions to Mapic CLI
- Swarm mode: Mapic is now running on Swarm, but on single node only.
- Config files are written automatically, all config handled by CLI
- New versioning scheme: Year.Month

## [2.0.1](https://github.com/mapic/mapic/releases/tag/v2.0.1)
Released: 2017-06-23

### `mapic/mapic` 
- Added colors to Mapic CLI
- Fixed bugs in CLI and Travis builds.

## [2.0.0](https://github.com/mapic/mapic/releases/tag/v2.0) 
Released: 2017-06-22

### `mapic/mapic`
- Added Mapic CLI [#27](https://github.com/mapic/mapic/issues/27)
- Added Travis [builds](https://travis-ci.org/mapic) to all Mapic repositories
- Reorganized repositories [#37](https://github.com/mapic/mapic/issues/37)
- Moved Docker images to standalone repositories
- Implemented Automatic builds on Docker Hub
- Changed `mapic/ubuntu` to `mapic/xenial` Docker image 

## 1.0.0 
Released before 2017-05-17
- Previous changes not logged. Please see commit history.