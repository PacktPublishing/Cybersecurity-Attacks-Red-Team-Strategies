using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Net.Mail;
using System.Diagnostics.Eventing.Reader;
using System.Net;
using Homefield.Sentinel;

namespace HomefieldSentinel
{
    class TheSentinel
    {
        SmtpClient smtpClient;
        EventLogWatcher logWatcher;
        Logger log;

        //event log query to retrieve event id 4656 (Audit ACLs)
        EventLogQuery logQuery =
                new EventLogQuery("Security", PathType.LogName,
                                              "*[System/EventID=4656]");
        public void StartWatching()
        {
            try
            {
                // location ends up being \windows\syswow64\sentinel.log
                log = new Logger("sentinel.log");
                log.WriteLine("Starting...");

                this.smtpClient = new SmtpClient(
                                         "smtp-mail.outlook.com", 587);
                this.logWatcher = new EventLogWatcher(logQuery);
                this.logWatcher.EventRecordWritten +=
                                this.logWatcher_EventRecordWritten;
                this.logWatcher.Enabled = true;
                this.smtpClient.EnableSsl = true;

                //project on github encrypts the credentials     
                this.smtpClient.Credentials = new NetworkCredential(
                                                   "<youremail>", "<yourpassword>");
                //fyi - the version at https://github.com/wunderwuzzi23/Sentinel
                //shows how to use a configuration file and encrypted credentials

                log.WriteLine("Started.");
            }
            catch (Exception e)
            {
                log.WriteLine(
                      "Unexpected Error during startup: " + e.ToString());
            }
        }

        /// Event Handler for the watcher
        /// Double check Event ID and see if the access is related
        /// to the passwords.txt file we have setup
        private void logWatcher_EventRecordWritten(object sender,
                               EventRecordWrittenEventArgs e)
        {
            if (e.EventRecord.Id == 4656)
            {
                //Is this is for the file of interest 
                if (e.EventRecord.FormatDescription().Contains("passwords.txt"))
                {
                    try
                    {
                        log.WriteLine("Honeypot file accessed");
                        log.WriteLine(e.EventRecord.FormatDescription());
                        log.WriteLine("****************************************");

                        //Send Mail
                        string email =
                          ((NetworkCredential)this.smtpClient.Credentials).UserName;
                        MailMessage mail = new MailMessage(email, email);
                        mail.Subject =
                              "[Sentinel Notification] Honeypot file accessed.";
                        mail.Body = e.EventRecord.FormatDescription();
                        mail.Priority = MailPriority.High;
                        mail.IsBodyHtml = false;
                        smtpClient.Send(mail);
                    }
                    catch (Exception ex)
                    {
                        log.WriteLine(
                             "Unexpected Error OnEventWritten: " + ex.ToString());
                    }
                }
            }
        }
        public void StopWatching()
        {
            this.logWatcher.Enabled = false;
            log.WriteLine("Stopped.");
        }
    }

}
