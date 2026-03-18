@echo off
@title nvm-windows Build Script

cd src 

REM Pull the versions the code expects
go get github.com/blang/semver@v3.5.1+incompatible
go get github.com/olekukonko/tablewriter@v0.0.5

REM Then build the CLI
go build -o ..\dist\nvm.exe

cd ..\..

echo nvm-windows build using go succeeded