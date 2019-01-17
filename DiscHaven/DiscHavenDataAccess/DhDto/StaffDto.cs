using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.DhDto
{
    public class StaffDto : PersonDto
    {
        public long FKLocationID { get; set; }
        public DateTime DOB { get; set; }
        public string PhoneNumber { get; set; }
        public string Comments { get; set; }
        public string Image { get; set; }
        public bool IsActive { get; set; }
    }
}