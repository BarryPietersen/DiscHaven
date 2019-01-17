using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DiscHavenDataAccess.Models
{
    public class StaffUser
    {
        public enum StaffRole
        {
            SalesStaff = 1,
            Manager,
            Admin
        }

        public StaffUser()
        { }

        public long ID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public StaffRole Role { get; set; }
    }
}
