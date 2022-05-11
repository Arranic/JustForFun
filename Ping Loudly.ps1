
$username = Get-WMIObject -class Win32_ComputerSystem | Select-Object username
$full_name = Get-ADUser $username.username.split("\")[1] -Properties GivenName,Surname,personalTitle | Select-Object @{n='Name';e={$_.personalTitle + ' ' + $_.GivenName + ' ' + $_.Surname}}

function Ping-Loudly ($destination, [string]$message) {
    Add-Type -AssemblyName System.Speech
    $Speak = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    if(Test-Connection -Quiet -ComputerName $destination){
        $Speak.speak("Hello $full_name.name" + $message)
    }
}

Function Set-Speaker($Volume){
    $wshShell = New-Object -Com wscript.shell;1..50 | % {$wshShell.SendKeys([char]174)};1..$Volume | % {$wshShell.SendKeys([char]175)}
}

Set-Speaker -Volume 50
Ping-Loudly MUHJL-833G9S "I am the master of the world"