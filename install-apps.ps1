# ============================================================
#  install-apps.ps1
#  Instalador rapido de aplicaciones via winget
#  Uso: iwr -useb https://raw.githubusercontent.com/Pocholo95/utilidades/refs/heads/main/install-apps.ps1 | iex
# ============================================================

$apps = @(
    @{ Name = "Firefox";            Id = "Mozilla.Firefox"         },
    @{ Name = "Steam";              Id = "Valve.Steam"             },
    @{ Name = "LockHunter";         Id = "Crystal.LockHunter"      },
    @{ Name = "PeaZip";             Id = "Giorgiotani.Peazip"      },
    @{ Name = "Elgato Stream Deck"; Id = "Elgato.StreamDeck"       },
    @{ Name = "Revo Uninstaller";   Id = "VS.RevoUninstaller"      },
    @{ Name = "VLC";                Id = "VideoLAN.VLC"            },
    @{ Name = "FFmpeg";             Id = "Gyan.FFmpeg"             },
    @{ Name = "Discord";            Id = "Discord.Discord"         }
)

# ── Colores helpers ──────────────────────────────────────────
function Write-OK   { param($msg) Write-Host "  [OK] $msg"    -ForegroundColor Green  }
function Write-Fail { param($msg) Write-Host "  [!!] $msg"    -ForegroundColor Red    }
function Write-Info { param($msg) Write-Host "  [..] $msg"    -ForegroundColor Cyan   }
function Write-Skip { param($msg) Write-Host "  [--] $msg"    -ForegroundColor Yellow }

# ── Verificar winget ─────────────────────────────────────────
Write-Host "`n================================================" -ForegroundColor Yellow
Write-Host "   Instalador de apps - winget" -ForegroundColor Yellow
Write-Host "================================================`n" -ForegroundColor Yellow

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Fail "winget no esta instalado."
    Write-Host "  Instalalo desde: https://aka.ms/getwinget" -ForegroundColor Yellow
    exit 1
}

# Actualizar solo la fuente winget (rapido, sin msstore)
Write-Info "Actualizando fuente winget..."
winget source update --name winget 2>&1 | Out-Null

$ok      = 0
$skipped = 0
$fails   = @()

foreach ($app in $apps) {
    Write-Info "Instalando $($app.Name)..."

    $output = winget install --id $app.Id --source winget --silent --accept-package-agreements --accept-source-agreements 2>&1

    # 0 = exito | -1978335189 = ya instalado (No applicable update found)
    if ($LASTEXITCODE -eq 0) {
        Write-OK "$($app.Name)"
        $ok++
    } elseif ($LASTEXITCODE -eq -1978335189 -or ($output | Select-String "already installed")) {
        Write-Skip "$($app.Name) ya estaba instalado"
        $skipped++
    } else {
        Write-Fail "$($app.Name) (codigo: $LASTEXITCODE)"
        $fails += $app.Name
    }
}

# ── Resumen ──────────────────────────────────────────────────
Write-Host "`n------------------------------------------------" -ForegroundColor Yellow
Write-Host "  Instaladas: $ok | Omitidas: $skipped | Fallaron: $($fails.Count)" -ForegroundColor Yellow
if ($fails.Count -gt 0) {
    Write-Host "  Fallaron: $($fails -join ', ')" -ForegroundColor Red
}
Write-Host "------------------------------------------------`n" -ForegroundColor Yellow
