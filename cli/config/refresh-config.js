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
var engineJsonStr = 'module.exports = ' + JSON.stringify(engineConfig, null, 2);
var content = fs.readFileSync(ENGINE_CONFIG_PATH);
content = content.toString('utf8');
fs.writeFileSync(ENGINE_CONFIG_PATH , engineJsonStr, 'utf-8');

// redis
updateRedisConfig(REDIS_CONFIG_PATH);

// nginx
var MAPIC_DOMAIN = process.env.MAPIC_DOMAIN;
var nginxConfig = fs.readFileSync(NGINX_CONFIG_PATH);
nginxConfig = nginxConfig.toString('utf8');
var replace_text = 'server_name                 ' + MAPIC_DOMAIN + ';'
var result = nginxConfig.replace(/server_name                 localhost;/g, replace_text);
var result2 = result.replace(/server_name localhost;/g, replace_text);
fs.writeFileSync(NGINX_CONFIG_PATH, result2, 'utf8')

// todo: 
// engine domains (localhost / dev.mapic.io)

