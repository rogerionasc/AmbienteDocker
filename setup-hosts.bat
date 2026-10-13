@echo off
setlocal enabledelayedexpansion

:: Verifica permissões de Administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Solicitando permissoes de Administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set HOSTS_FILE=%WINDIR%\System32\drivers\etc\hosts

echo ======================================================
echo    Configuracao de DNS / Hosts Locais (Windows)
echo ======================================================
echo.

set DOMAINS=appweb.local webclinic.local matriz.webclinic.local

for %%d in (%DOMAINS%) do (
    findstr /i /c:"%%d" "%HOSTS_FILE%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] %%d ja esta configurado no hosts.
    ) else (
        echo [ADICIONANDO] 127.0.0.1  %%d ...
        echo 127.0.0.1       %%d >> "%HOSTS_FILE%"
    )
)

echo.
echo Limpando cache DNS...
ipconfig /flushdns >nul

echo [SUCESSO] Configuracao concluida com sucesso!
echo.
pause
