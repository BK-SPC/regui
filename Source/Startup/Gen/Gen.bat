node GenJSON.js "1" "Start.json"
luajit GenFinal.lua "Start.json" "Start.data"
del Start.json
node GenJSON.js "0" "Start.json.debug"
luajit GenFinal.lua "Start.json.debug" "Start.data.debug"
del Start.json.debug