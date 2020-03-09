
using HomefieldSentinel;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace Homefield.Sentinel
{
    public partial class SentinelService : ServiceBase
    {
        TheSentinel sentinel;

        public SentinelService()
        {
            InitializeComponent();

            /// create the sentinel 
            sentinel = new TheSentinel();
        }

        protected override void OnStart(string[] args)
        {
            sentinel.StartWatching();
        }

        protected override void OnStop()
        {
            sentinel.StopWatching();
        }
    }
}

