# Change Log
All notable changes to all repositories in this project will be documented in this file. 

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

## Unreleased
### `mapic/mapic` 
- Added automatic scheduling for AWS EC2 resources: `mapic schedule day|night|register`

### `mapic/mapic.js` 
- Added support for exporting `.csv` directly from charted deformation points
- Added support for graph data layer

### `mapic/mile`
- Improved bbox calculation of extent
- Optimized processing of empty tiles

## [17.10](https://github.com/mapic/mapic/releases/tag/v17.10)
### `mapic/mapic.js` 
- Bugfix: regression
- Refactor of charts into M.Chart
- Renaming of Wu global to M
- Improved logo customization
- Added pre-rendering button
- Updated C3 lib

### `mapic/mile`
- Pre-rendering functionality added
- Cleanup of old code
- Optimizations

### `mapic/mapic` 
- Improvements to CLI
- Stable Swarm Mode

## [17.9](https://github.com/mapic/mapic/releases/tag/v17.9)
### `mapic/mapic`
- Swarm mode: Mapic is now running on n nodes
- Replicating `mile` tileserver on n nodes
- Additions and improvements to Mapic CLI
    - `mapic info`
    - `mapic tor`
    - `mapic viz` 
    - `mapic api login` 
    - `mapic api project create`
    - `mapic api upload`
    - `mapic bench` 
    - `mapic scale`
- Implemented Tor Project relay on all nodes: `mapic tor start` 
- Added visualizer for Docker nodes: `mapic viz start`
    - Port 8080 is closed in AWS, so only ssh tunnel can access visualizer
    - NB: Ensure port 8080 is closed to public in your setup.
    - You need to add `LocalForward 8080 localhost:8080` to /.ssh/config on your localhost
    - Only accessible in the browser @ localhost:8080
- Moved most configuration to ENV, removed all dependency on config files
- Bugfixes
- Run benchmarks with `mapic bench` 
- Scale service with `mapic scale` 

### `mapic/mile` 
- Cleaned up stale ENV and naming
- Removed Kue and clustering. Scaling will be handled through Docker Swarm
- Removed `redistemp` (was only needed for Kue)
- Added pre-rendering of tiles

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