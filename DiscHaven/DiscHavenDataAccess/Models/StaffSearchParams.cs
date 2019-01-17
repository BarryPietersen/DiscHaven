using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DiscHavenDataAccess.Models
{
    public class StaffSearchParams
    {
        public long LocationID { get; set; }
        public long RoleID { get; set; }
        public string LastName { get; set; }
    }
}
