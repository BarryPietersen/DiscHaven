using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DiscHavenDataAccess.DhDto
{
    public class TitleDto
    {
        public long ID { get; set; }
        public long FKCategoryID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
    }
}
