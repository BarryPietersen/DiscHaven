using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.Models
{
    public class SearchParams
    {
        public long MediaTypeID { get; set; } = 0;
        public long CategoryID { get; set; } = 0;
        public string SearchValue { get; set; } = "";
    }
}