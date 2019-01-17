using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.DhDto
{
    public class ProductDto
    {
        public long ID { get; set; }
        public long FKTitleID { get; set; }
        public long FKMediaTypeID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public double RRP { get; set; }
        public float DiscountFactor { get; set; }
        public DateTime RelDate { get; set; }
        public string Image { get; set; }
        public bool IsActive { get; set; }
    }
}