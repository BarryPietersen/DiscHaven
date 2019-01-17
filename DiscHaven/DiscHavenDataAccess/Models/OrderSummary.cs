using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.Models
{
    public class OrderSummary
    {
        public enum Status
        {
            Ordered = 1,
            Processing,
            Shipped,
            Delivered
        }

        public long ID { get; set; }
        public long FKCustomerID { get; set; }
        public string Location { get; set; }
        public Status StatusCode { get; set; }
        public int ItemCount { get; set; }
        public DateTime Date { get; set; }
        public double Total { get; set; }
        public double GstFactor { get; set; }
        public bool UseShippingAddress { get; set; }
        public double GrandTotal => Total * (1 + GstFactor);
        public double Gst => GstFactor * 100;

        public string StatusText => StatusCode.ToString();
    }
}