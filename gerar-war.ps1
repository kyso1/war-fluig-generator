<#
.SYNOPSIS
    Gera arquivos .war para widgets Fluig a partir do código-fonte.

.DESCRIPTION
    Este script empacota os widgets do diretório de workspace em arquivos .war
    prontos para deploy em massa no Fluig. Mapeia:
      src/main/resources/*  →  WEB-INF/classes/*
      src/main/webapp/*     →  raiz do WAR

.PARAMETER WidgetsDir
    Caminho da pasta raiz dos widgets (onde ficam as pastas WIDGET_*).
    Padrão: C:\Users\Gian.silva\fluig-workspace\widgets

.PARAMETER OutputDir
    Pasta de saída dos arquivos .war gerados.
    Padrão: diretório atual do script.

.PARAMETER Widgets
    Lista de widgets específicos para empacotar (nomes das pastas WIDGET_*).
    Se não informado, empacota todos os listados no mapeamento interno.

.EXAMPLE
    .\gerar-war.ps1
    .\gerar-war.ps1 -Widgets "WIDGET_nome","WIDGET_nome2"
    .\gerar-war.ps1 -WidgetsDir "C:\meu-workspace\widgets" -OutputDir "C:\wars"
#>

param(
    [string]$WidgetsDir = "C:\Users\Gian.silva\fluig-workspace\widgets",
    [string]$OutputDir  = $PSScriptRoot,
    [string[]]$Widgets  = @()
)

# ── Mapeamento: pasta WIDGET_* → nome interno do widget ──
$widgetMap = [ordered]@{
    "WIDGET_nome"                             = "w_nome"
    "WIDGET_nome2"                            = "w_nome2"
    "WIDGET_nome3"                            = "w_nome3"
    "WIDGET_nome4"                            = "w_nome4"
    "WIDGET_nome5"                            = "w_nome5"
    "WIDGET_nome6"                            = "w_nome6"
    "WIDGET_nome7"                            = "w_nome7"
    "WIDGET_nome8"                            = "w_nome8"
    "WIDGET_nome9"                            = "w_nome9"
}

# ── Filtra widgets se forem especificados ──
if ($Widgets.Count -gt 0) {
    $filtered = [ordered]@{}
    foreach ($w in $Widgets) {
        if ($widgetMap.Contains($w)) {
            $filtered[$w] = $widgetMap[$w]
        } else {
            Write-Warning "Widget '$w' nao encontrado no mapeamento. Ignorando."
        }
    }
    $widgetMap = $filtered
}

if ($widgetMap.Count -eq 0) {
    Write-Error "Nenhum widget para empacotar."
    exit 1
}

# ── Garante pasta de saída ──
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       Gerador de WAR - Widgets Fluig         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Origem:  $WidgetsDir" -ForegroundColor DarkGray
Write-Host "  Destino: $OutputDir" -ForegroundColor DarkGray
Write-Host "  Widgets: $($widgetMap.Count)" -ForegroundColor DarkGray
Write-Host ""

$sucesso = 0
$erro    = 0

foreach ($folder in $widgetMap.Keys) {
    $widgetName   = $widgetMap[$folder]
    $widgetRoot   = Join-Path $WidgetsDir "$folder\wcm\widget\$widgetName"
    $resourcesDir = Join-Path $widgetRoot "src\main\resources"
    $webappDir    = Join-Path $widgetRoot "src\main\webapp"
    $warFile      = Join-Path $OutputDir "$widgetName.war"

    if (!(Test-Path $widgetRoot)) {
        Write-Host "  ❌ $widgetName — pasta nao encontrada: $widgetRoot" -ForegroundColor Red
        $erro++
        continue
    }

    # Remove WAR antigo
    if (Test-Path $warFile) { Remove-Item $warFile -Force }

    try {
        $zip = [System.IO.Compression.ZipFile]::Open($warFile, [System.IO.Compression.ZipArchiveMode]::Create)
        $entryCount = 0

        # src/main/resources/* → WEB-INF/classes/*
        if (Test-Path $resourcesDir) {
            Get-ChildItem $resourcesDir -Recurse -File | ForEach-Object {
                $rel = $_.FullName.Substring($resourcesDir.Length + 1).Replace('\', '/')
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $zip, $_.FullName, "WEB-INF/classes/$rel",
                    [System.IO.Compression.CompressionLevel]::Optimal
                ) | Out-Null
                $entryCount++
            }
        }

        # src/main/webapp/* → raiz do WAR
        if (Test-Path $webappDir) {
            Get-ChildItem $webappDir -Recurse -File | ForEach-Object {
                $rel = $_.FullName.Substring($webappDir.Length + 1).Replace('\', '/')
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $zip, $_.FullName, $rel,
                    [System.IO.Compression.CompressionLevel]::Optimal
                ) | Out-Null
                $entryCount++
            }
        }

        $zip.Dispose()
        $fileSize = [math]::Round((Get-Item $warFile).Length / 1KB, 1)
        Write-Host "  ✅ $widgetName.war  ($entryCount arquivos, ${fileSize} KB)" -ForegroundColor Green
        $sucesso++
    }
    catch {
        Write-Host "  ❌ $widgetName — ERRO: $_" -ForegroundColor Red
        if ($zip) { $zip.Dispose() }
        if (Test-Path $warFile) { Remove-Item $warFile -Force -ErrorAction SilentlyContinue }
        $erro++
    }
}

Write-Host ""
Write-Host "══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Resultado: $sucesso OK / $erro erros" -ForegroundColor $(if ($erro -eq 0) { "Green" } else { "Yellow" })
Write-Host "  Arquivos em: $OutputDir" -ForegroundColor DarkGray
Write-Host "══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
