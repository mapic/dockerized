#!/usr/bin/env node
//
// Creates a bash script which will create correct storage containers. Can't create storage containers from this script, 
// since it's run within a Docker container. Containers must be created on host.
// Therefore the cleanup must also happen in `create-storage-containers.sh`.
//

// install node modules
var exec = require('child_process').exec;
var child = exec('npm install lodash yamljs async', function (err, stdout, stderr) {
    if (err) console.log('Creating storage containers failed! [exec error:', err, ']');

    // deps
    var _ = require('lodash');
    var YAML = require('yamljs');
    var async = require('async');
    var fs = require('fs');

    // load file
    var MAPIC_DOMAIN = process.argv[2] || process.env.MAPIC_DOMAIN || 'localhost';
    console.log('Using domain', MAPIC_DOMAIN);
    console.log(process.argv[2]);
    console.log(process.env.MAPIC_DOMAIN);
    console.log(process.env);

    if (!MAPIC_DOMAIN) {
        console.log('Usage: node .storage-script-helper.js [MAPIC_DOMAIN]');
        process.exit(1);
    }
    var yml_file = YAML.load('yml/' + MAPIC_DOMAIN + '.yml');

    // settings
    var paths = {
        engine      : '/data',
        mile        : '/data',
        redisstats  : '/data',
        redislayers : '/data',
        redistokens : '/data',
        mongo       : '/data/db',           // todo: simplify this path to /data/ like the rest
        postgis     : '/var/lib/postgresql', // todo: simplify this path to /data/ like the rest
    }

    // parse
    var parsed = {};
    _.each(yml_file, function (value, key) {
        if (value.volumes_from) {
            parsed[key] = value.volumes_from[0];
        }
    });

    // define commands
    var commands = [];
    _.each(parsed, function (name, service) {
        var docker_command = [
            'docker', 
            'create', 
            '-v', 
            paths[service],
            '--name', 
            name,
            'mapic/ubuntu'
        ].join(' ');
        console.log(docker_command);
        commands.push(docker_command);
    });

    // concat
    var bash_script = '#!/bin/bash \n';
    commands.forEach(function (c) {
        bash_script += c + '\n';
    });

    // write bash script to file
    fs.writeFileSync('createcontainers.tmp.sh', bash_script, 'utf-8');

    // cleanup: remove node modules
    var child = exec('rm -rf node_modules', function (err, stdout, stderr) {
        process.exit(err);
    });
});
