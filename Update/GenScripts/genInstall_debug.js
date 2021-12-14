// Node.js

const fs = require("fs");
const path = require("path");
const dataDir = "..\\..\\Source\\Data\\";
const search = `\\\\`;
const replacer = new RegExp(search, 'g');

var installArray = [];

function traverseDir(dir) {
    fs.readdirSync(dir).forEach(file => {
        let fullPath = path.join(dir, file);
        if (fs.lstatSync(fullPath).isDirectory()) {
            console.log(fullPath);
            installArray[installArray.length] = [2,fullPath.replace(dataDir,"").replace(replacer,"/")];
            traverseDir(fullPath);
        } else {
            installArray[installArray.length] = [1,fullPath.replace(dataDir,"").replace(replacer,"/")];
            console.log(fullPath);
        };
    });
};

traverseDir(dataDir);

console.log(installArray);

fs.writeFileSync("../Install.json.debug",JSON.stringify(installArray));