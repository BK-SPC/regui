START cmd.exe /k "cd Update/GenScripts/ & gen & exit"
START cmd.exe /k "cd Source/Startup/Gen/ & gen & exit"
git add .
git commit -m "gen"