using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Homefield.Sentinel
{
    class Logger
    {
        StreamWriter writer;
        public Logger(string filename)
        {
            writer = File.CreateText(filename);
        }

        public void WriteLine(string text)
        {
            string now = DateTime.Now.ToString("yyyy.MM.dd HH:mm:ss");
            lock (writer)
            {
                writer.WriteLine(now + ": " + text);
                writer.Flush();
            }
        }
    }
}
