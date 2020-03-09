Get-EventLog -LogName Security -InstanceId 4624, 4625 | % {

  if ($_.EventId -eq 4624) #Login success
  {
    [PSCustomObject]@{
      TimeGenerated = $_.TimeGenerated
      Index = $_.Index     
      EventID = $_.EventID
      Account = $_.ReplacementStrings[5]
      LogonType = $_.ReplacementStrings[8]
      FromHost = $_.ReplacementStrings[18]
      FromIP = $_.ReplacementStrings[19]
      Domain = $_.ReplacementStrings[2]
      Process = $_.ReplacementStrings[18]
    }
  }

  if ($_.EventId -eq 4625) #Logon failed
  {
    [PSCustomObject]@{
      TimeGenerated = $_.TimeGenerated
      Index = $_.Index
      EventID = $_.EventID
      Account = $_.ReplacementStrings[5]
      LogonType = $_.ReplacementStrings[10]
      FromHost = $_.ReplacementStrings[6]
      FromIP = $_.ReplacementStrings[19]
      Domain = $_.ReplacementStrings[2]
      Process = $_.ReplacementStrings[18]
    }
  }
} | Format-Table
