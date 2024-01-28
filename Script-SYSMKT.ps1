param (
    [string]$User,
    [string]$Password,
    [string]$Path

)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@




# Apagar arquivos das pastas: Download, Documentos, Imagens, Vídeos e Área de Trabalho(menos os atalhos básicos)
try {
    Remove-Item -Path "C:$env:HOMEPATH\Desktop\*" -Exclude "Lixeira","Excel.lnk", "PowerPoint.lnk", "Word.lnk", "Google Chrome", "Script-SYSMKT.ps1"
    Remove-Item -Path "C:$env:HOMEPATH\Downloads\*" -Recurse -Force
    Remove-Item -Path "C:$env:HOMEPATH\Documents\*" -Recurse -Force
    Remove-Item -Path "C:$env:HOMEPATH\Videos\*" -Recurse -Force
    Remove-Item -Path "C:$env:HOMEPATH\Pictures\*" -Recurse -Force
    
}
catch {
    Write-Host "Ocorreu um erro na etapa 1: $($_.Exception.Message)"
}
finally {
    Write-Host "Etapa 1 concluida com sucesso!"
}





# Mudando nome e senha de usuário
try {
    Import-Module Microsoft.PowerShell.LocalAccounts
    Get-LocalUser -Name $env:USERNAME | Rename-LocalUser -NewName $User
    $senha = ConvertTo-SecureString $Password -Force
    Get-LocalUser -Name $User | Set-LocalUser -Password $senha
    
}
catch {
    Write-Host "Ocorreu um erro na etapa 2: $($_.Exception.Message)"
}
finally {
    Write-Host "Etapa 2 concluida com sucesso!"
}


# Alterando papel de parede
try {
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChange = 0x02 
    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Path, $UpdateIniFile -bor $SendChange)
}
catch {
    Write-Host "Ocorreu um erro na etapa 3: $($_.Exception.Message)"
}
finally {
    Write-Host "Etapa 3 concluida com sucesso!"
}


# Desativar Windows Update
Stop-Service -Name wuauserv -Force
Set-Service -Name wuauserv -StartupType Disabled




