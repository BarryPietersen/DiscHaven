using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DiscHavenDataAccess.Models
{
    public class ProductQty
    {
        public long ID { get; set; }
        public long FKLocationID { get; set; }
        public string City { get; set; }
        public string MediaType { get; set; }
        public string Category { get; set; }
        public string Title { get; set; }
        public string Name { get; set; }

        public int Quantity { get; set; }
    }
}
