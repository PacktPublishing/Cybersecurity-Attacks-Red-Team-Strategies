### Instantiate the Watcher to listen for entries in the Security Event Log
$watcher = New-Object  System.Diagnostics.Eventing.Reader.EventLogWatcher("Security")
$watcher.Enabled = $true

### Event Handler which is invoked whenever a new Security event is triggered
$OnEventWritten =
{
   ### Configuration Settings
   $logfile               = "$env:USERPROFILE\sentinel.log"
   $honeypot_searchfilter = "*passwords.txt*"
   $email                 = "<youremailaddress>"
   $smtp_server           = "smtp-mail.outlook.com"
   $subject               = "[Sentinel Notification] Honeypot file accessed."

   $e = $event.sourceEventArgs.EventRecord

   ### Listen for Audit events that request a handle to the honeypot file
   if ($e.Id -eq 4656)
   {
     try
     {  
        ### Load the encrypted email credentials from PasswordVault
        [void][Windows.Security.Credentials.PasswordVault, Windows.Security.Credentials, ContentType=WindowsRuntime]
        $vault      = New-Object Windows.Security.Credentials.PasswordVault
        $emailpwd   = ($vault.Retrieve("Sentinel",$email).Password) | ConvertTo-SecureString -AsPlainText -Force
        $emailcreds = New-Object System.Management.Automation.PsCredential($email, $emailpwd)

        if ($e.FormatDescription() -like $honeypot_searchfilter)
        {
           ### write a log entry
           $e.FormatDescription() >> $logfile

           ### send a mail also
           Send-MailMessage -From $email -To $email -Subject $subject -Body $e.FormatDescription() -Priority High -SmtpServer $smtp_server -Port 587 -UseSSL -Credential $emailcreds
        }
     }
     catch
     {
        $_ >> $logfile
     } 
  }
}

### Register the Event Handler
Register-ObjectEvent -InputObject $watcher -EventName EventRecordWritten -Action $OnEventWritten -SourceIdentifier SentinelNotify
