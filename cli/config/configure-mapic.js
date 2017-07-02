// var fs = require("fs");
// var crypto = require("crypto");

// // this is the main script to make all MAPIC_ENV_FILE config options be reflected in the 
// // various config files
// // it's all or nothing, ENV and config files should always be mirrored


// // set config folder
// var CONFIG_FOLDER           = process.env.MAPIC_CONFIG_FOLDER + '/';
// var MONGO_JSON_PATH         = CONFIG_FOLDER + "mongo.json";
// var MILE_CONFIG_PATH        = CONFIG_FOLDER + "mile.config.js";
// var ENGINE_CONFIG_PATH      = CONFIG_FOLDER + "engine.config.js";
// var REDIS_LAYERS_CONF_PATH  = CONFIG_FOLDER + "redis.layers.conf";
// var REDIS_STATS_CONF_PATH   = CONFIG_FOLDER + "redis.stats.conf";
// var REDIS_TOKENS_CONF_PATH  = CONFIG_FOLDER + "redis.tokens.conf";
// var REDIS_TEMP_CONF_PATH    = CONFIG_FOLDER + "redis.temp.conf";

// // check if folder exists
// if (!fs.existsSync(CONFIG_FOLDER)) {
//     console.log('Config folder', CONFIG_FOLDER, 'does not exist. Quitting!');
//     process.exit(1);
// }

// // helper fn
// var updateRedisConfig = function (filePath) {
//     var lines = fs.readFileSync(filePath).toString().split("\n");
//     for(var i in lines) {
//         var lineText = lines[i];
//         if (lineText.indexOf('requirepass') > -1){
//             lines[i] = "requirepass " + redisPassString;
//             break;
//         }
//     }
//     lines = lines.join('\n');
//     fs.writeFileSync(filePath, lines, 'utf-8');  
// };

// // create fresh auth
// var mongoPassString = crypto.randomBytes(64).toString('hex');
// var redisPassString = crypto.randomBytes(64).toString('hex');

// // adding auth to mongo
// var mongo_json = fs.readFileSync(MONGO_JSON_PATH);
// var mongo_config = JSON.parse(mongo_json);
// mongo_config.password = mongoPassString;
// fs.writeFileSync(MONGO_JSON_PATH, JSON.stringify(mongo_config, null, 2) , 'utf-8');

// // adding redis auth to mile
// var mileConfig = require(MILE_CONFIG_PATH);
// mileConfig.redis.layers.auth = redisPassString;
// mileConfig.redis.stats.auth = redisPassString;
// mileConfig.redis.temp.auth = redisPassString;
// var mileJsonStr = 'module.exports = ' + JSON.stringify(mileConfig, null, 2);
// fs.writeFileSync(MILE_CONFIG_PATH, mileJsonStr , 'utf-8');

// // adding mongo/redis pass to engine
// var engineConfig = require(ENGINE_CONFIG_PATH);
// engineConfig.serverConfig.mongo.url =  'mongodb://' + mongo_config.user + ':' + mongoPassString + '@mongo/' + mongo_config.database;
// engineConfig.serverConfig.redis.layers.auth = redisPassString;
// engineConfig.serverConfig.redis.stats.auth = redisPassString;
// engineConfig.serverConfig.redis.temp.auth = redisPassString;
// var engineJsonStr = 'module.exports = ' + JSON.stringify(engineConfig, null, 2);
// var content = fs.readFileSync(ENGINE_CONFIG_PATH);
// content = content.toString('utf8');
// fs.writeFileSync(ENGINE_CONFIG_PATH , engineJsonStr, 'utf-8');

// // updating redis 
// updateRedisConfig(REDIS_LAYERS_CONF_PATH);
// updateRedisConfig(REDIS_STATS_CONF_PATH);
// updateRedisConfig(REDIS_TOKENS_CONF_PATH);
// updateRedisConfig(REDIS_TEMP_CONF_PATH);

// // engine
// var engineConfig = require(ENGINE_CONFIG_PATH);

// // updating domains
// engineConfig.serverConfig.portalServer.uri = 'https://' + MAPIC_DOMAIN;
// engineConfig.serverConfig.instance = MAPIC_DOMAIN;
// engineConfig.clientConfig.servers.portal = 'https://' + MAPIC_DOMAIN;

// // updating subdomains
// var subdomain = MAPIC_DOMAIN.split('.')[0];
// var main_domain = MAPIC_DOMAIN.split(subdomain)[1];
// engineConfig.clientConfig.servers.subdomain = 'https://{s}' + main_domain;
// var tiles_sub = ["tiles-a-" + subdomain, "tiles-b-" + subdomain, "tiles-c-" + subdomain, "tiles-d-" + subdomain];
// engineConfig.clientConfig.servers.tiles.subdomains = tiles_sub;
// var proxy_sub = ["proxy-a-" + subdomain, "proxy-b-" + subdomain, "proxy-c-" + subdomain, "proxy-d-" + subdomain];
// engineConfig.clientConfig.servers.proxy.subdomains = proxy_sub;
// var grid_sub = ["grid-a-" + subdomain, "grid-b-" + subdomain, "grid-c-" + subdomain, "grid-d-" + subdomain];
// engineConfig.clientConfig.servers.utfgrid.subdomains = grid_sub;
// var tiles_url = engineConfig.clientConfig.servers.subdomain + '/v2/tiles/';
// var cubes_url = engineConfig.clientConfig.servers.subdomain + '/v2/cubes/';
// engineConfig.clientConfig.servers.tiles.uri = tiles_url;
// engineConfig.clientConfig.servers.cubes.uri = cubes_url;
// engineConfig.clientConfig.servers.proxy.uri = tiles_url;
// engineConfig.clientConfig.servers.utfgrid.uri = tiles_url;

// var engineJsonStr = 'module.exports = ' + JSON.stringify(engineConfig, null, 2);
// var content = fs.readFileSync(ENGINE_CONFIG_PATH);
// content = content.toString('utf8');
// fs.writeFileSync(ENGINE_CONFIG_PATH , engineJsonStr, 'utf-8');




var fs = require("fs");
var crypto = require("crypto");

// set config folder
// var CONFIG_FOLDER           = process.env.MAPIC_ROOT_FOLDER + '/cli/config/files/';
var CONFIG_FOLDER           = '/config/';
var MONGO_JSON_PATH         = CONFIG_FOLDER + "mongo.json";
var MILE_CONFIG_PATH        = CONFIG_FOLDER + "mile.config.js";
var ENGINE_CONFIG_PATH      = CONFIG_FOLDER + "engine.config.js";
var REDIS_LAYERS_CONF_PATH  = CONFIG_FOLDER + "redis.layers.conf";
var REDIS_STATS_CONF_PATH   = CONFIG_FOLDER + "redis.stats.conf";
var REDIS_TOKENS_CONF_PATH  = CONFIG_FOLDER + "redis.tokens.conf";
var REDIS_TEMP_CONF_PATH    = CONFIG_FOLDER + "redis.temp.conf";

// check if folder exists
if (!fs.existsSync(CONFIG_FOLDER)) {
    console.log(CONFIG_FOLDER, 'does not exist. Quitting!');
    process.exit(1);
}

// helper fn
var updateRedisConfig = function (filePath) {
    var lines = fs.readFileSync(filePath).toString().split("\n");
    for(var i in lines) {
        var lineText = lines[i];
        if (lineText.indexOf('requirepass') > -1){
            lines[i] = "requirepass " + redisPassString;
            break;
        }
    }
    lines = lines.join('\n');
    fs.writeFileSync(filePath, lines, 'utf-8');  
};

var mongoPassString = crypto.randomBytes(64).toString('hex');
var redisPassString = crypto.randomBytes(64).toString('hex');

console.log("Configuring MongoDB...");
var mongo_json = fs.readFileSync(MONGO_JSON_PATH);
var mongo_config = JSON.parse(mongo_json);
mongo_config.password = mongoPassString;
fs.writeFileSync(MONGO_JSON_PATH, JSON.stringify(mongo_config, null, 2) , 'utf-8');

console.log("Configuring Mapic Tile Server...");
var mileConfig = require(MILE_CONFIG_PATH);
mileConfig.redis.layers.auth = redisPassString;
mileConfig.redis.stats.auth = redisPassString;
mileConfig.redis.temp.auth = redisPassString;
var mileJsonStr = 'module.exports = ' + JSON.stringify(mileConfig, null, 2);
fs.writeFileSync(MILE_CONFIG_PATH, mileJsonStr , 'utf-8');

console.log("Configuring Mapic Web Server...");
var engineConfig = require(ENGINE_CONFIG_PATH);
engineConfig.serverConfig.mongo.url =  'mongodb://' + mongo_config.user + ':' + mongoPassString + '@mongo/' + mongo_config.database;
engineConfig.serverConfig.redis.layers.auth = redisPassString;
engineConfig.serverConfig.redis.stats.auth = redisPassString;
engineConfig.serverConfig.redis.temp.auth = redisPassString;
var engineJsonStr = 'module.exports = ' + JSON.stringify(engineConfig, null, 2);
var content = fs.readFileSync(ENGINE_CONFIG_PATH);
content = content.toString('utf8');
fs.writeFileSync(ENGINE_CONFIG_PATH , engineJsonStr, 'utf-8');

console.log("Configuring Redis...");
updateRedisConfig(REDIS_LAYERS_CONF_PATH);
updateRedisConfig(REDIS_STATS_CONF_PATH);
updateRedisConfig(REDIS_TOKENS_CONF_PATH);
updateRedisConfig(REDIS_TEMP_CONF_PATH);
















