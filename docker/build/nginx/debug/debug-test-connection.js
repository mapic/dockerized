var http = require('http');


// engine
var req = http.get({
  host: 'engine',
  port : '3001',
}, function(res) {
    console.log('ENGINE:');
    console.log('STATUS: ' + res.statusCode);
    console.log('HEADERS: ' + JSON.stringify(res.headers));


    // mile
    var req2 = http.get({
      host: 'mile',
      port : '3003',
    }, function(res) {
        console.log('MILE:');
        console.log('STATUS: ' + res.statusCode);
        console.log('HEADERS: ' + JSON.stringify(res.headers));
    });


});
