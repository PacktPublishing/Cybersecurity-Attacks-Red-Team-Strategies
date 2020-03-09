$watcher = New-Object System.Diagnostics.Eventing.Reader.EventLogWatcher("Security")
$watcher.Enabled = $true

$OnEventWritten =
{
   $e = $event.sourceEventArgs.EventRecord
   if ($e.Id -eq 4656)
   {
     if ($e.FormatDescription() -like "*passwords.txt*")
     {
       Add-Type -AssemblyName System.Windows.Forms
       $notification = New-Object System.Windows.Forms.NotifyIcon
       $notification.Icon = [System.Drawing.SystemIcons]::Warning
       $notification.Visible = $true
       $notification.ShowBalloonTip(10000, "[Sentinel] – Honeypot file accessed!", "Review the Security Event Log for more details", [System.Windows.Forms.ToolTipIcon]::Warning)   
     }
   }
}

Register-ObjectEvent -InputObject $watcher -EventName EventRecordWritten -Action $OnEventWritten -SourceIdentifier SentinelNotify


#Unregister-Event -SourceIdentifier SentinelNotify