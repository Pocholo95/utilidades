# ============================================================
#  install-apps.ps1
#  Instalador rapido de aplicaciones via winget
#  Uso: iwr -useb https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/install-apps.ps1 | iex
# ============================================================

$apps = @(
    @{ Name = "Firefox";            Id = "Mozilla.Firefox"         },
    @{ Name = "Steam";              Id = "Valve.Steam"             },
    @{ Name = "LockHunter";         Id = "Crystal.LockHunter"      },
    @{ Name = "PeaZip";             Id = "Giorgiotani.Peazip"      },
    @{ Name = "Elgato Stream Deck"; Id = "Elgato.StreamDeck"       },
    @{ Name = "Revo Uninstaller";   Id = "VS.RevoUninstaller"      },
    @{ Name = "VLC";                Id = "VideoLAN.VLC"            },
    @{ Name = "FFmpeg";             Id = "Gyan.FFmpeg"             }
)

# ── Colores helpers ──────────────────────────────────────────
function Write-OK   { param($msg) Write-Host "  [OK] $msg"    -ForegroundColor Green  }
function Write-Fail { param($msg) Write-Host "  [!!] $msg"    -ForegroundColor Red    }
function Write-Info { param($msg) Write-Host "  [..] $msg"    -ForegroundColor Cyan   }

# ── Verificar winget ─────────────────────────────────────────
Write-Host "`n================================================" -ForegroundColor Yellow
Write-Host "   Instalador de apps - winget" -ForegroundColor Yellow
Write-Host "================================================`n" -ForegroundColor Yellow

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Fail "winget no esta instalado."
    Write-Host "  Instalalo desde: https://aka.ms/getwinget" -ForegroundColor Yellow
    exit 1
}

$ok    = 0
$fails = @()

foreach ($app in $apps) {
    Write-Info "Instalando $($app.Name)..."
    winget install --id $app.Id --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
        # -1978335189 = ya estaba instalado (WINGET_INSTALLED_STATUS_ALREADY_INSTALLED)
        Write-OK "$($app.Name)"
        $ok++
    } else {
        Write-Fail "$($app.Name) (codigo: $LASTEXITCODE)"
        $fails += $app.Name
    }
}

# ── Resumen ──────────────────────────────────────────────────
Write-Host "`n------------------------------------------------" -ForegroundColor Yellow
Write-Host "  Resultado: $ok/$($apps.Count) apps instaladas" -ForegroundColor Yellow
if ($fails.Count -gt 0) {
    Write-Host "  Fallaron: $($fails -join ', ')" -ForegroundColor Red
}
Write-Host "------------------------------------------------`n" -ForegroundColor Yellow
