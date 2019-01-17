using System.Collections.Generic;
using System.Web.Mvc;
using DiscHaven.Attributes;
using DiscHaven.WebModels;
using DiscHavenDataAccess;
using DiscHavenDataAccess.Models;

namespace DiscHaven.Controllers
{
    [ValidateSession]
    public class ProductController : Controller
    {
        public ActionResult Search(SearchParams searchParams, UserSession us)
        {
            int totalPages = 0;
            int requestedPage = 1;

            if (us.IsAuthenticated &&
                !string.IsNullOrEmpty(Request["SearchValue"]) &&
                us.SearchParams.SearchValue != Request["SearchValue"])
            {
                CommandResult cr = DhDataAccess.AddSearchValue(us.Customer.ID, Request["SearchValue"]);

                if (cr.ID > 0) us.Customer.SearchValues = DhDataAccess.GetSearchValues(us.Customer.ID);
            }

            us.SearchParams = searchParams;

            //get matching prods from db - error handling will be applied here
            IEnumerable<Product> products = DhDataAccess.GetActiveProducts(searchParams, ref requestedPage, ref totalPages);

            ViewBag.requestedPage = requestedPage;
            ViewBag.totalPages = totalPages;

            return View("SearchResults", products);
        }

        public PartialViewResult LoadPage(int requestedPage, UserSession us)
        {
            int totalPages = 0;

            IEnumerable<Product> products = DhDataAccess.GetActiveProducts(us.SearchParams, ref requestedPage, ref totalPages);
            ViewBag.requestedPage = requestedPage;
            ViewBag.totalPages = totalPages;

            return PartialView("_ProductResults", products);
        }

        public ActionResult ViewProduct(long id)
        {
            //get specific product from db
            Product product = DhDataAccess.GetProduct(id);

            return View("Product", product);
        }

        public JsonResult GetJsonProduct(long id)
        {
            //get product from db and 
            Product product = DhDataAccess.GetProduct(id);
            return Json(product, JsonRequestBehavior.AllowGet);
        }
    }
}