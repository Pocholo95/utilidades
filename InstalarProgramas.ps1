# Script de PowerShell para instalar programas con Winget y otros métodos personalizados

# Configurar la política de ejecución
Write-Host "Configurando la política de ejecución a RemoteSigned..." -ForegroundColor Yellow
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

# Lista de programas a instalar con Winget (ID de Winget)
$programasWinget = @(
    "Mozilla.Firefox",
    "RevoUninstaller.RevoUninstaller",
    "Discord.Discord",
    "Vendicated.Vencord",
    "Gyan.FFmpeg",
    "CrystalRich.LockHunter",
    "Spotify.Spotify",
    "Valve.Steam",
    "EpicGames.EpicGamesLauncher",
    "Ollama.Ollama",
    "Git.Git",
    "CherubicSoftware.SageThumbs",
    "VideoLAN.VLC",
    "OpenJS.NodeJS",
    "pinokiocomputer.pinokio"
)

# Lista de instaladores personalizados (nombre, comando y validación)
$instaladoresPersonalizados = @(
    @{
        Nombre = "pyenv-win"
        Validacion = { Test-Path "$env:USERPROFILE\.pyenv" } # Cambia esto a la lógica que valide si está instalado
        Comando = 'Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"; Remove-Item "./install-pyenv-win.ps1" -Force'
    },
    @{
        Nombre = "Spicetify"
        Validacion = { Test-Path "$env:APPDATA\spicetify" }
        Comando = 'iwr -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | iex'
    }
)

# Instalar .NET Framework 3.5 si no está habilitado
Write-Host "Verificando si .NET Framework 3.5 está habilitado..." -ForegroundColor Yellow
$netFramework35 = Get-WindowsFeature -Name NET-Framework-Features

if (-not $netFramework35.Installed) {
    Write-Host ".NET Framework 3.5 no está habilitado. Procediendo con la instalación..." -ForegroundColor Yellow
    try {
        # Habilitar .NET Framework 3.5 mediante DISM
        dism.exe /online /enable-feature /featurename:NetFx3 /all /limitaccess /source:D:\sources\sxs
        Write-Host ".NET Framework 3.5 instalado correctamente." -ForegroundColor Green
    } catch {
        Write-Host "Error al habilitar .NET Framework 3.5. Por favor, verifica la fuente o conexión." -ForegroundColor Red
    }
} else {
    Write-Host ".NET Framework 3.5 ya está habilitado." -ForegroundColor Cyan
}

# Comprobación de si Winget está instalado
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget no está instalado. Por favor, instala Winget antes de ejecutar este script." -ForegroundColor Red
    exit 1
}

# Instalación de programas con Winget
foreach ($programa in $programasWinget) {
    # Validar si el programa ya está instalado
    $programaInstalado = winget list | Select-String -Pattern $programa
    if ($programaInstalado) {
        Write-Host "$programa ya está instalado. Saltando..." -ForegroundColor Cyan
        continue
    }
    
    Write-Host "Instalando $programa con Winget..." -ForegroundColor Green
    try {
        winget install --id $programa -e --silent --accept-package-agreements --accept-source-agreements
    } catch {
        Write-Host "Error al instalar $programa. Por favor, verifica el ID del programa." -ForegroundColor Red
    }
}

# Instalación de programas personalizados
foreach ($instalador in $instaladoresPersonalizados) {
    # Validar si el programa personalizado ya está instalado
    if (& $instalador.Validacion) {
        Write-Host "$($instalador.Nombre) ya está instalado. Saltando..." -ForegroundColor Cyan
        continue
    }
    
    Write-Host "Instalando $($instalador.Nombre)..." -ForegroundColor Yellow
    try {
        Invoke-Expression $instalador.Comando
        Write-Host "$($instalador.Nombre) instalado correctamente." -ForegroundColor Green
    } catch {
        Write-Host "Error al instalar $($instalador.Nombre). Por favor, verifica el comando." -ForegroundColor Red
    }
}

Write-Host "Instalación completada." -ForegroundColor Green
