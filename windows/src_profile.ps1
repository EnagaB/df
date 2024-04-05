﻿Import-Module PSReadLine
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

Set-Alias -Name op -Value Invoke-Item
Set-Alias -Name vi -Value 'C:\Program Files\Neovim\bin\nvim.exe'
Set-Alias -Name skr -Value "${HOME}\apps\sakura\sakura.exe"
