var AWS = require('aws-sdk');
var async = require('async');
var _ = require('lodash');
var fs = require('fs');

function missing_args(arg) {
    var err = 'Missing argument: ' + arg;
    console.log(err);
    process.exit(err);
}

var MAPIC_AWS_ACCESSKEYID = process.env.MAPIC_AWS_ACCESSKEYID;
var MAPIC_AWS_SECRETACCESSKEY = process.env.MAPIC_AWS_SECRETACCESSKEY;
var MAPIC_AWS_HOSTED_ZONE_DOMAIN = process.env.MAPIC_AWS_HOSTED_ZONE_DOMAIN;
var MAPIC_IP = process.env.MAPIC_IP;
var MAPIC_CONFIG_DEBUG = process.env.MAPIC_CONFIG_DEBUG;

if (!MAPIC_AWS_ACCESSKEYID) return missing_args('MAPIC_AWS_ACCESSKEYID');
if (!MAPIC_AWS_SECRETACCESSKEY) return missing_args('MAPIC_AWS_SECRETACCESSKEY');
if (!MAPIC_AWS_HOSTED_ZONE_DOMAIN) return missing_args('MAPIC_AWS_HOSTED_ZONE_DOMAIN');
if (!MAPIC_IP) return missing_args('MAPIC_IP');

// subdomains for which to create dns entries
var subdomains = [
    'proxy-a',
    'proxy-b',
    'proxy-c',
    'proxy-d',
    'tiles-a',
    'tiles-b',
    'tiles-c',
    'tiles-d',
    'grid-a',
    'grid-b',
    'grid-c',
    'grid-d',
]
    
// init aws
AWS.config.update({
    "accessKeyId" : process.env.MAPIC_AWS_ACCESSKEYID,
    "secretAccessKey" : process.env.MAPIC_AWS_SECRETACCESSKEY,
    "region" : "eu-west-1"
});

// get the route53 lib
var route53 = new AWS.Route53();

// async ops
var ops = [];

// get domain
var MAPIC_DOMAIN = process.env.MAPIC_DOMAIN;
if (!MAPIC_DOMAIN) {
    var err = 'Missing $MAPIC_DOMAIN. Qutting!';
    console.log(err)
    process.exit(err);
}

// get list of hosted zones
ops.push(function (callback) {
    route53.listHostedZones({}, callback);
});

// set entries
ops.push(function (data, callback) {

    // get hosted zone
    var hosted_zone = _.find(data.HostedZones, function (d) {
        console.log('d', d);
        return d['Name'] == MAPIC_AWS_HOSTED_ZONE_DOMAIN + '.';
    });

    // check
    if (!hosted_zone) return callback('No such hosted zone: ' + MAPIC_AWS_HOSTED_ZONE_DOMAIN);

    // get id
    var hosted_zone_id = hosted_zone['Id'];

    // set options
    var options = {
        "HostedZoneId": hosted_zone_id,
        "ChangeBatch": {
          "Changes": []
        }
    };

    // add main subdomain
    options['ChangeBatch']['Changes'].push({
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": MAPIC_DOMAIN,
            "Type": "A",
            "TTL": 600,
            "ResourceRecords": [{
                "Value": MAPIC_IP
            }]
        }
    });

    // add each subdomain
    subdomains.forEach(function (s) {
        options['ChangeBatch']['Changes'].push({
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": s + "-" + MAPIC_DOMAIN,
                "Type": "A",
                "TTL": 600,
                "ResourceRecords": [{
                    "Value": MAPIC_IP
                }]
            }
        });
    });
    
    // update dns records
    route53.changeResourceRecordSets(options, function(err,data) {
        callback(err, data);
    });
    
});

// run ops
async.waterfall(ops, function (err, result) {
    if (err) return console.log('Something went wrong: ', err);
    console.log('\nSuccess! DNS entries created for\n', subdomains.join('\n'), 'and', MAPIC_DOMAIN);
    MAPIC_CONFIG_DEBUG && console.log('\n\nAnswer from AWS Route 53 was:\n', result);
});

