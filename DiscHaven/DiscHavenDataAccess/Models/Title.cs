using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DiscHavenDataAccess.Models
{
    public class Title
    {
        public long ID { get; set; }
        public string Category { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
    }
}
