using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.Models
{
    public class LineItem
    {
        public long ID { get; set; }
        public long FKProductID { get; set; }
        public string Name { get; set; }
        public double Quantity { get; set; }
        public double ItemPrice { get; set; }

        public double LineTotal => ItemPrice * Quantity;

        public double PriceIncGst(double gst)
        {
            if (gst < 0) { }//raise error

            return ItemPrice * (1 + gst);
        }
    }
}