@echo off

setlocal enableDelayedExpansion
setlocal

:: Override laragon settings

:: httpd.conf
Set item[0]=httpd.conf
Set file[0]=C:\laragon\bin\apache\httpd-2.4.48-o111k-x64-vs16\conf\httpd.conf
Set toFind[0]=/Apache24
Set toSet[0]=C:/laragon/bin/apache/httpd-2.4.48-o111k-x64-vs16

:: httpd.ssl.conf
Set item[1]=httpd.ssl.conf
Set file[1]=C:/laragon/etc/apache2/httpd-ssl.conf
Set toFind[1]=Listen 443
Set toSet[1]=#Listen 443

:: tpl\openssql.conf.tpl
Set item[2]=openssql.conf
Set file[2]=C:\laragon\bin\laragon\tpl\openssl.conf.tpl
Set toFind[2]=keyUsage = keyEncipherment, dataEncipherment
Set toSet[2]=keyUsage = nonRepudiation, digitalSignature, keyEncipherment

:: openssql.conf.tpl
Set item[3]=openssql.conf
Set file[3]=C:\laragon\usr\tpl\openssql.conf.tpl
Set toFind[3]=keyUsage = keyEncipherment, dataEncipherment
Set toSet[3]=keyUsage = nonRepudiation, digitalSignature, keyEncipherment

:: ssl\openssql.conf
Set item[3]=openssql.conf
Set file[3]=C:\laragon\etc\ssl\openssql.conf
Set toFind[3]=keyUsage = keyEncipherment, dataEncipherment
Set toSet[3]=keyUsage = nonRepudiation, digitalSignature, keyEncipherment

::  laragon/bin/mysql8.0.0.x/bin

:: 0,1,0 == start,step,end
for /L %%i in (0,1,2) do (
	echo [36mOverriding[0m !item[%%i]!
	powershell -c "(Get-Content -Path '!file[%%i]!') | ForEach-Object { $_ -Replace '!toFind[%%i]!', '!toSet[%%i]!' } | Set-Content -Path '!file[%%i]!'"
	echo [32mDone[0m !item[%%i]!
)

:: delete folder and files
echo [36mChecking[0m mysql data
if exist C:\laragon\bin\mysql\mysql-8.0.26-winx64\data\ (
	echo [91mDeleting:[0m mysql data
	Rmdir /s /q C:\laragon\bin\mysql\mysql-8.0.26-winx64\data
	echo [32mRemoved[0m mysql data
) else (
	echo [36mNot Found[0m mysql data
)

:: init
:: https://dev.mysql.com/doc/refman/5.7/en/data-directory-initialization.html
echo Runnning command: C:\laragon\bin\mysql\mysql-8.0.26-winx64\bin\mysqld.exe --initialize-insecure --console
C:\laragon\bin\mysql\mysql-8.0.26-winx64\bin\mysqld.exe --initialize-insecure --console
:: powershell -c "(Get-Content -Path C:\laragon\bin\apache\httpd-2.4.48-o111k-x64-vs16\conf\httpd.conf) | ForEach-Object { $_ -Replace '/Apache24', 'C:/laragon/bin/apache/httpd-2.4.48-o111k-x64-vs16' } | Set-Content -Path C:\laragon\bin\apache\httpd-2.4.48-o111k-x64-vs16\conf\httpd.conf"
:: th=OrWDtK2w&

:: General
Set laragon_bin=C:\laragon\bin\
Set php_exe=C:\laragon\bin\php\php-8.0.9-Win32-vs16-x64\php.exe

:: Install Composer
echo [36mInstalling[0m composer
cd C:\laragon\bin\composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --filename=%filename[0]% --install-dir=%laragon_bin%composer
php -r "unlink('composer-setup.php');"
echo @php "%~dp0composer" %*>C:\laragon\bin\composer\composer.bat
echo [32mInstalled[0m composer

:: Install Laravel globally
composer global require laravel/installer

:: Last manual instructions
echo Next is do the following and we are done!
echo Reload Apache - Laragon will generate new SAN certificate
echo Click Menu > Apache > SSL > Add laragon.crt to Trust Store

pause