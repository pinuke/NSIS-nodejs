console.log( "This script is run at the end of the nodejs installation" )
console.log( "Bye!" )

fs = require('fs');
fs.writeFile( ".\\test.txt", "hello there" )
