using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.Models
{
    public class Product
    {
        public long ID { get; set; }
        public string MediaType { get; set; }
        public string Category { get; set; }
        public string Title { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public double RRP { get; set; }
        public float DiscountFactor { get; set; }
        public DateTime RelDate { get; set; }
        public string Image { get; set; }

        public double Discount => RRP * DiscountFactor;
        public double Price => RRP - Discount;

        public override string ToString()
        {
            return $"{ID} {MediaType} {Category} {Title} {Price} {RelDate}";
        }
    }
}