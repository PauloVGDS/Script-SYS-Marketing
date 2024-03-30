$User = Read-Host "Nome de usuário: "
$Password = Read-Host "Senha: "
$Path = Read-Host "Diretorio do papel de parede: "

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
    Remove-Item -Path "C:$env:HOMEPATH\Desktop\*" -Exclude "Lixeira","Excel.lnk", "PowerPoint.lnk", "Word.lnk", "Google Chrome"
    Remove-Item -Path "C:$env:HOMEPATH\Downloads\*" -Recurse -Force
    Remove-Item -Path "C:$env:HOMEPATH\Documents\*" -Recurse -Force
    Remove-Item -Path "C:$env:HOMEPATH\Videos\*" -Recurse -Force
    Remove-Item -Path "C:$env:HOMEPATH\Pictures\*" -Recurse -Force
    
}
catch {
    Write-Host "Apagar arquivos de pastas desnecessarias: $($_.Exception.Message)"
}
else {
    Write-Host "Apagar arquivos de pastas desnecessarias: Sucesso!"
}





# Mudando nome e senha de usuário
try {
    Import-Module Microsoft.PowerShell.LocalAccounts
    Get-LocalUser -Name $env:USERNAME | Rename-LocalUser -NewName $User
    $senha = ConvertTo-SecureString $Password -Force
    Get-LocalUser -Name $User | Set-LocalUser -Password $senha
    
}
catch {
    Write-Host "Mudar nome e senha de usuário: $($_.Exception.Message)"
}
else {
    Write-Host "Mudar nome e senha de usuário: Sucesso!"
}


# Alterando papel de parede
try {
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChange = 0x02 
    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Path, $UpdateIniFile -bor $SendChange)
}
catch {
    Write-Host "Alterar papel de parede: $($_.Exception.Message)"
}
else {
    Write-Host "Alterar papel de parede: Sucesso!"
}


# Desativar Windows Update
Stop-Service -Name wuauserv -Force
Set-Service -Name wuauserv -StartupType Disabled
Write-Host "Windows Update: Desativado"

try {
    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Winget não está instalado!"
        exit
    }
    Write-Host "Winget está instalado!"

    $programa = ""
    while ($programa -ne "stop") {
        $programa = Read-Host "Nome do programa: "
        Write-Host "Desinstalando $programa"
        winget uninstall $programa   
    }

}
catch {
    Write-Host "Desinstalacao de programas desnecessarios: $($_.Exception.Message)"
}
else {
    Write-Host "Desinstalacao de programas desnecessarios: Sucesso!"
}