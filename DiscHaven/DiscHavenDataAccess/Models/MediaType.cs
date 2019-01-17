using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DiscHavenDataAccess.Models
{
    public class MediaType
    {
        public long ID { get; set; }
        public string Value { get; set; }

        public MediaType(long id, string value)
        {
            ID = id;
            Value = value;
        }
    }

    public class MediaTypes : List<MediaType>
    {
        public MediaTypes(IEnumerable<MediaType> mediaTypes)
        {
            this.AddRange(mediaTypes);
        }

        public MediaTypes()
        {

        }
    }
}