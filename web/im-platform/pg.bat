@echo off

rem %~dp0
rem set PGDATA=%~dp0data
rem set PGDATA=%~dp0../data
set PGDATA=/development/pgsql/data

if "%1"=="" goto :start
if "%1"=="init" (goto :init)
if "%1"=="stop" (goto :stop) else (goto :start)

:init
echo Init
initdb
pg_ctl start
createuser -dirS -P user
createdb -U user imdb
goto :stop

:start
echo Start
rem set LANG=C
pg_ctl -l /tmp/run.log restart
goto :end

:stop
echo Stop
pg_ctl stop

:end
