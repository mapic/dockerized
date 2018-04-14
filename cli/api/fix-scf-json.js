const fs = require('fs');

if (!process.argv[3]) return console.log('Usage: node fix-scf-json.js INFILE OUTFILE')

const INFILE = process.argv[2]
const OUTFILE = process.argv[3]

var data = JSON.parse(fs.readFileSync(INFILE, 'utf-8'));

var new_data = [];

data.forEach(function (d) {
    new_data.push(d);
});


data.forEach(function (d) {
    if (d.year == '2001') {
        var e = {
            year : '2016',
            doy : d.doy,
            scf : d.scf, 
            ccf : d.ccf, 
            age : d.age
        }
        new_data.push(e);
    }
});

data.forEach(function (d) {
    if (d.year == '2001') {
        var e = {
            year : '2017',
            doy : d.doy,
            scf : d.scf, 
            ccf : d.ccf, 
            age : d.age
        }
        new_data.push(e);
    }
});

data.forEach(function (d) {
    if (d.year == '2001' && parseInt(d.doy) < 100) {
        var e = {
            year : '2018',
            doy : d.doy,
            scf : d.scf, 
            ccf : d.ccf, 
            age : d.age
        }
        new_data.push(e);
    }
});


fs.writeFileSync(OUTFILE, JSON.stringify(new_data));
console.log('Wrote to ', OUTFILE);
