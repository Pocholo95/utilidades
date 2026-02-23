# ============================================================
#  install-apps.ps1
#  Instalador rapido de aplicaciones via winget
#  Uso: iwr -useb https://raw.githubusercontent.com/Pocholo95/utilidades/refs/heads/main/install-apps.ps1 | iex
# ============================================================

# Evita que winget intente actualizar fuentes automaticamente al arrancar (causa cuelgues)
$env:WINGET_DISABLE_SOURCE_UPDATE = "1"

$apps = @(
    @{ Name = "Firefox";            Id = "Mozilla.Firefox"         }
    @{ Name = "Steam";              Id = "Valve.Steam"             }
    @{ Name = "LockHunter";         Id = "Crystal.LockHunter"      }
    @{ Name = "PeaZip";             Id = "Giorgiotani.Peazip"      }
    @{ Name = "Elgato Stream Deck"; Id = "Elgato.StreamDeck"       }
    @{ Name = "Revo Uninstaller";   Id = "VS.RevoUninstaller"      }
    @{ Name = "VLC";                Id = "VideoLAN.VLC"            }
    @{ Name = "FFmpeg";             Id = "Gyan.FFmpeg"             }
    @{ Name = "Discord";            Id = "Discord.Discord"         }
)

# ── Colores helpers ──────────────────────────────────────────
function Write-OK   { param($msg) Write-Host "  [OK] $msg"    -ForegroundColor Green  }
function Write-Fail { param($msg) Write-Host "  [!!] $msg"    -ForegroundColor Red    }
function Write-Info { param($msg) Write-Host "  [..] $msg"    -ForegroundColor Cyan   }
function Write-Skip { param($msg) Write-Host "  [--] $msg"    -ForegroundColor Yellow }

Write-Host "`n================================================" -ForegroundColor Yellow
Write-Host "   Instalador de apps - winget" -ForegroundColor Yellow
Write-Host "================================================`n" -ForegroundColor Yellow

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "  [!!] winget no encontrado. Instalalo desde: https://aka.ms/getwinget" -ForegroundColor Red
    exit 1
}

$ok      = 0
$skipped = 0
$fails   = @()

foreach ($app in $apps) {
    Write-Info "Procesando $($app.Name)..."

    $output = winget install `
        --id $app.Id `
        --source winget `
        --accept-package-agreements `
        --accept-source-agreements `
        2>&1 | Out-String

    switch ($LASTEXITCODE) {
        0           { Write-OK   "$($app.Name)"; $ok++      }
        -1978335189 { Write-Skip "$($app.Name) ya instalado"; $skipped++ }
        default {
            # Doble chequeo por si el mensaje dice "already installed"
            if ($output -match "already installed") {
                Write-Skip "$($app.Name) ya instalado"
                $skipped++
            } else {
                Write-Fail "$($app.Name) — codigo: $LASTEXITCODE"
                $fails += $app.Name
            }
        }
    }
}

# ── Resumen ──────────────────────────────────────────────────
Write-Host "`n------------------------------------------------" -ForegroundColor Yellow
Write-Host "  Instaladas : $ok" -ForegroundColor Green
Write-Host "  Omitidas   : $skipped" -ForegroundColor Yellow
Write-Host "  Fallaron   : $($fails.Count)" -ForegroundColor $(if ($fails.Count -gt 0) { "Red" } else { "Green" })
if ($fails.Count -gt 0) {
    Write-Host "  >> $($fails -join ', ')" -ForegroundColor Red
}
Write-Host "------------------------------------------------`n" -ForegroundColor Yellow
