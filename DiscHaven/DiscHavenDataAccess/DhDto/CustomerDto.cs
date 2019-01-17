using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DiscHavenDataAccess.Models;

namespace DiscHavenDataAccess.DhDto
{
    public class CustomerDto : PersonDto
    {
        public string ShipAddress { get; set; }
        public string ShipCity { get; set; }
        public string ShipState { get; set; }
        public string ShipPostCode { get; set; }
        //public List<SecQA> SecurityQuestions { get; set; }
    }
}