using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DiscHaven.WebModels;
using DiscHavenDataAccess.Models;
using DiscHavenDataAccess.DhDto;
using DiscHavenDataAccess;

namespace DiscHaven.ViewModels
{
    public class OrderDetailsViewModel
    {
        OrderSummary OrderSummary { get; set; }
        List<LineItem> OrderLineItems { get; set; }
    }
}