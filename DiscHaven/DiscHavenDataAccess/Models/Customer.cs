using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.Models
{
    public class Customer
    {
        public long ID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public List<string> SearchValues { get; set; }
        public int CartCount { get; set; }
        public string FullName => $"{FirstName} {LastName}";
    }
}