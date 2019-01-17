using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.DhDto
{
    public abstract class PersonDto
    {
        public long ID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string PostCode { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public string PasswordHint { get; set; }
    }
}