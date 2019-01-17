using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DiscHavenDataAccess.Models
{
    public class OrderDetails
    {
        public OrderSummary Summary { get; set; }
        public List<LineItem> LineItems { get; set; }
    }
}
