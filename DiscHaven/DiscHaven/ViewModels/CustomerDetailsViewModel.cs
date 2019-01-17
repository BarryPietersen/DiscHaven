using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DiscHavenDataAccess.DhDto;
using DiscHavenDataAccess.Models;

namespace DiscHaven.ViewModels
{
    public class CustomerDetailsViewModel
    {
        public bool IsNew { get; set; }
        public CustomerDto CustomerDto { get; set; }
        public List<SecQA> SecurityQuestions { get; set; }
        public Dictionary<string, string> ValidationMessages { get; set; }
    }
}