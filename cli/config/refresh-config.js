var fs = require("fs");
var crypto = require("crypto");

// set config folder
var CONFIG_FOLDER       = '/config/';
var MONGO_JSON_PATH     = CONFIG_FOLDER + "mongo.json";
var MILE_CONFIG_PATH    = CONFIG_FOLDER + "mile.config.js";
var ENGINE_CONFIG_PATH  = CONFIG_FOLDER + "engine.config.js";
var REDIS_CONFIG_PATH   = CONFIG_FOLDER + "redis.conf";
var NGINX_CONFIG_PATH   = CONFIG_FOLDER + "nginx.conf";

// check if folder exists
if (!fs.existsSync(CONFIG_FOLDER)) {
    console.log(CONFIG_FOLDER, 'does not exist. Quitting!');
    process.exit(1);
}

// helper fn
var updateRedisConfig = function (config) {
    var lines = fs.readFileSync(config).toString().split("\n");
    for(var i in lines) {
        var lineText = lines[i];
        if (lineText.indexOf('requirepass') > -1){
            lines[i] = "requirepass " + redisPassString;
            break;
        }
    }
    lines = lines.join('\n');
    fs.writeFileSync(config, lines, 'utf-8');  
};
var addLineToRedisConfig = function (config, line) {
    var lines = fs.readFileSync(config).toString('utf-8').split("\n");
    var l = lines.length;
    lines[l] = line
    lines = lines.join('\n');
    fs.writeFileSync(config, lines, 'utf-8');
};

var mongoPassString = crypto.randomBytes(64).toString('hex');
var redisPassString = crypto.randomBytes(64).toString('hex');

// mongo
var mongo_json = fs.readFileSync(MONGO_JSON_PATH);
var mongo_config = JSON.parse(mongo_json);
mongo_config.password = mongoPassString;
fs.writeFileSync(MONGO_JSON_PATH, JSON.stringify(mongo_config, null, 2) , 'utf-8');

// mile
var mileConfig = require(MILE_CONFIG_PATH);
mileConfig.redis.layers.auth = redisPassString;
mileConfig.redis.stats.auth = redisPassString;
mileConfig.redis.temp.auth = redisPassString;
var mileJsonStr = 'module.exports = ' + JSON.stringify(mileConfig, null, 2);
fs.writeFileSync(MILE_CONFIG_PATH, mileJsonStr , 'utf-8');

// engine
var engineConfig = require(ENGINE_CONFIG_PATH);
engineConfig.serverConfig.mongo.url =  'mongodb://' + mongo_config.user + ':' + mongoPassString + '@mongo/' + mongo_config.database;
engineConfig.serverConfig.redis.layers.auth = redisPassString;
engineConfig.serverConfig.redis.stats.auth = redisPassString;
engineConfig.serverConfig.redis.temp.auth = redisPassString;

var MAPIC_DOMAIN = process.env.MAPIC_DOMAIN;
var domain_split = MAPIC_DOMAIN.split('.').reverse();
var MAPIC_ROOT_DOMAIN = domain_split[1] + '.' + domain_split[0];
var MAPIC_SUBDOMAIN = domain_split.reverse()[0];
var MAPIC_BASE_URL = 'https://' + MAPIC_DOMAIN;

engineConfig.serverConfig.portalServer.uri = 'https://' + MAPIC_DOMAIN + '/';
engineConfig.clientConfig.servers.portal = 'https://' + MAPIC_DOMAIN + '/';
engineConfig.clientConfig.servers.subdomain = 'https://{s}.' + MAPIC_ROOT_DOMAIN + '/';
engineConfig.clientConfig.servers.tiles.uri = 'https://{s}.' + MAPIC_ROOT_DOMAIN + '/v2/tiles/';
engineConfig.clientConfig.servers.tiles.subdomains = [
    'tiles-a-' + MAPIC_SUBDOMAIN, 
    'tiles-b-' + MAPIC_SUBDOMAIN, 
    'tiles-c-' + MAPIC_SUBDOMAIN, 
    'tiles-d-' + MAPIC_SUBDOMAIN 
];
engineConfig.clientConfig.servers.cubes.uri = 'https://{s}.' + MAPIC_ROOT_DOMAIN + '/v2/cubes/';
engineConfig.clientConfig.servers.cubes.subdomains = engineConfig.clientConfig.servers.tiles.subdomains;
engineConfig.clientConfig.servers.proxy.uri = 'https://{s}.' + MAPIC_ROOT_DOMAIN + '/v2/tiles/';
engineConfig.clientConfig.servers.proxy.subdomains = [
    'proxy-a-' + MAPIC_SUBDOMAIN, 
    'proxy-b-' + MAPIC_SUBDOMAIN, 
    'proxy-c-' + MAPIC_SUBDOMAIN, 
    'proxy-d-' + MAPIC_SUBDOMAIN 
];
engineConfig.clientConfig.servers.utfgrid.uri = 'https://{s}.' + MAPIC_ROOT_DOMAIN + '/v2/tiles/';
engineConfig.clientConfig.servers.utfgrid.subdomains = [
    'grid-a-' + MAPIC_SUBDOMAIN, 
    'grid-b-' + MAPIC_SUBDOMAIN, 
    'grid-c-' + MAPIC_SUBDOMAIN, 
    'grid-d-' + MAPIC_SUBDOMAIN 
];

var engineJsonStr = 'module.exports = ' + JSON.stringify(engineConfig, null, 2);
fs.writeFileSync(ENGINE_CONFIG_PATH , engineJsonStr, 'utf-8');


// nginx
var nginxConfig = fs.readFileSync(NGINX_CONFIG_PATH);
nginxConfig = nginxConfig.toString('utf8');
var replace_text = 'server_name                 ' + MAPIC_DOMAIN + ';'
var result = nginxConfig.replace(/server_name                 localhost;/g, replace_text);
var result2 = result.replace(/server_name localhost;/g, replace_text);
fs.writeFileSync(NGINX_CONFIG_PATH, result2, 'utf8')

// redis
updateRedisConfig(REDIS_CONFIG_PATH);

var redis_layers_config_path = CONFIG_FOLDER + "redis.layers.conf";
var redis_tokens_config_path = CONFIG_FOLDER + "redis.tokens.conf";
var redis_stats_config_path = CONFIG_FOLDER + "redis.stats.conf";
var redis_temp_config_path = CONFIG_FOLDER + "redis.temp.conf";

fs.createReadStream(REDIS_CONFIG_PATH).pipe(fs.createWriteStream(redis_layers_config_path));
fs.createReadStream(REDIS_CONFIG_PATH).pipe(fs.createWriteStream(redis_tokens_config_path));
fs.createReadStream(REDIS_CONFIG_PATH).pipe(fs.createWriteStream(redis_stats_config_path));
fs.createReadStream(REDIS_CONFIG_PATH).pipe(fs.createWriteStream(redis_temp_config_path));

setTimeout(function () {

    // add saving to some redis dbs
    addLineToRedisConfig(redis_layers_config_path, 'appendonly yes')
    addLineToRedisConfig(redis_layers_config_path, 'appendfsync everysec')
    addLineToRedisConfig(redis_tokens_config_path, 'appendonly yes')
    addLineToRedisConfig(redis_tokens_config_path, 'appendfsync everysec')
    addLineToRedisConfig(redis_stats_config_path, 'appendonly yes')
    addLineToRedisConfig(redis_stats_config_path, 'appendfsync everysec')

}, 500) // need to wait for file system 
