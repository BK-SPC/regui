// Node.js

const fs = require("fs");
const path = require("path");
const dataDir = "..\\..\\Source\\Data\\";
const search = `\\\\`;
const replacer = new RegExp(search, 'g');
const miniTempDir = "luaMiniTempDir";
var luamin = require('luamin');

var installArray = [];

function traverseDir(dir) {
    fs.readdirSync(dir).forEach(file => {
        let fullPath = path.join(dir, file);
        if (fs.lstatSync(fullPath).isDirectory()) {
            console.log(fullPath);
            installArray[installArray.length] = [2,fullPath.replace(dataDir,"").replace(replacer,"/")];
            traverseDir(fullPath);
        } else {
            if (path.extname(fullPath) == ".lua") {
                console.log("luamin (minify) " + fullPath)
                var fileData = fs.readFileSync(fullPath,"utf-8")
                var writePath = miniTempDir + "/" + (installArray.length + 1).toString() + ".lua"
                var writeData = luamin.minify(fileData)
                console.log("luamin (write) " + writePath)
                console.log(writeData.length)
                fs.writeFileSync(
                    writePath,
                    writeData,
                    "utf8"
                )
            }
            installArray[installArray.length] = [1,fullPath.replace(dataDir,"").replace(replacer,"/")];
            console.log(fullPath);
        };
    });
};

traverseDir(dataDir);

console.log(installArray);

fs.writeFileSync("../Install.json",JSON.stringify(installArray));