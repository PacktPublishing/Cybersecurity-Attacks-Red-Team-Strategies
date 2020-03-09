Get-Process | % { 
    procdump.exe -ma $_.Id } #make sure to install procdump from Systeinternals and have it in your path
    gci *.dmp | % { strings.exe -n 17 $_.Name | 
       Select-String "password=" | Out-File ($_.Name+".txt") 
}
