using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DiscHaven.WebModels;
using DiscHavenDataAccess.Models;
using DiscHavenDataAccess.DhDto;
using DiscHavenDataAccess;

namespace DiscHaven.ViewModels
{
    public class NavBarViewModel
    {
        public UserSession UserSession { get; set; }
        public MediaTypes MediaTypes { get; set; }
        public Categories Categories { get; set; }
    }
}