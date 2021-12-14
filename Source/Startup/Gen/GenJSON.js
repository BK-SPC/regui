// this is later used by GenFinal.lua

const fs = require("fs")
const path = require("path")
const luamin = require('luamin');
const contentPath = "..\\Content\\"
const initPath = "..\\Init.lua"
const cliArgs = process.argv.slice(2);
const mini = cliArgs[0] == "1";

var output = {}

if (mini == true) {
    output.InitScr = Buffer.from(luamin.minify(fs.readFileSync(initPath,"binary")),"utf8").toString('hex')
}
else {
    output.InitScr = fs.readFileSync(initPath,"hex")
}

output.Files = {}

function traverseDir(dir) {
    console.log("TRAV", dir)
    fs.readdirSync(dir).forEach(file => {
        let fullPath = path.join(dir, file);
        let RelativePath = fullPath.replace(contentPath,"")
        if (fs.lstatSync(fullPath).isDirectory()) {
            console.log("DIR", fullPath);
            traverseDir(fullPath);
        } else {
            console.log("FILE", fullPath);
            let ext = path.extname(fullPath)
            let fileData = "what"
            if (ext == ".lua") {
                if (mini == true) {
                    console.log("minify",fullPath)
                    fileData = luamin.minify(fs.readFileSync(fullPath,"binary"))
                    fileData = Buffer.from(fileData,"utf8").toString('hex')
                }
                else {
                    fileData = fs.readFileSync(fullPath,"hex")
                }
            }
            else if (ext == ".json") {
                if (mini == true) {
                    fileData = JSON.stringify(JSON.parse(fs.readFileSync(fullPath,"binary")))
                    fileData = Buffer.from(fileData,"utf8").toString('hex')
                }
                else {
                    fileData = fs.readFileSync(fullPath,"hex")
                }
            }
            else {
                fileData = fs.readFileSync(fullPath,"hex")
            }
            output.Files[RelativePath] = fileData
        };
    });
};

traverseDir(contentPath)

output.JSON = JSON.stringify(output)

fs.writeFileSync(cliArgs[1],output.JSON)
//fs.writeFileSync("../../../Update/Start.data")

//console.log(output.JSON)