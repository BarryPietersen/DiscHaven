using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.Models
{
    public class Category
    {
        public long ID { get; set; }
        public string Value { get; set; }

        public Category(long id, string value)
        {
            ID = id;
            Value = value;
        }
    }

    public class Categories : List<Category>
    {
        public Categories(IEnumerable<Category> categories)
        {
            this.AddRange(categories);
        }

        public Categories()
        {

        }
    }
}