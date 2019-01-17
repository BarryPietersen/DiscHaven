using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DiscHavenDataAccess.Models
{
    public class SecQA
    {
        public long ID { get; set; } = 0;
        public string Question { get; set; } = "";
        public string Answer { get; set; } = "";

        public SecQA(string question, string answer, long id = 0)
        {
            ID = id;
            Question = question;
            Answer = answer;
        }

        public SecQA()
        { }
    }
}
