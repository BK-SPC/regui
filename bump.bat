@echo off

for /f "Tokens=* Delims=" %%x in (Source\Startup\Content\latestVer) do set _build=%%x
set /A _buildInt=%_build%
set /A _bumpedBuildInt=%_buildInt% + 1

echo current build is: %_build%
echo build %_buildInt% will be bumped to build %_bumpedBuildInt%

echo %_bumpedBuildInt%>Source\Startup\Content\latestVer

git add .
git commit -m "bump"