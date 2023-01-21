START /W cmd.exe /k "cd Update/GenScripts/ & gen & exit"
START /W cmd.exe /k "cd Source/Startup/Gen/ & gen & exit"

git add .
git commit -m "gen"