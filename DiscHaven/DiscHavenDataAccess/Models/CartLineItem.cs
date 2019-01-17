using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DiscHavenDataAccess.Models
{
    public class CartLineItem
    {
        public long ID { get; set; }
        public long FKProductID { get; set; }
        public string Name { get; set; }
        public double ItemPrice { get; set; }
        public DateTime DateAdded { get; set; }
        public int Quantity { get; set; }

        public double LineTotal => ItemPrice * Quantity;

        public double PriceIncGst(double gst)
        {
            if (gst < 0) { }//raise error

            return ItemPrice * (1 + gst);
        }
    }
}
