using System.Collections.Generic;
using System.Web.Mvc;
using DiscHaven.Attributes;
using DiscHaven.WebModels;
using DiscHavenDataAccess;
using DiscHavenDataAccess.Models;

namespace DiscHaven.Controllers
{
    [ValidateSession]
    public class HomeController : Controller
    {
        private static readonly HashSet<string> _redirectRequesters = new HashSet<string>() { "http://localhost:52075/register/details", "http://localhost:52075/home/unauthenticated" };
        public ActionResult Index()
        {
            //get interval for slider from db - tblConfiguration
            float slideInterval = DhDataAccess.GetSlideInterval() * 1000;

            return View(slideInterval);
        }

        public ActionResult About()
        {
            return View();
        }

        public ActionResult Store()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Login(string username, string password, UserSession us)
        {
            Customer customer = DhDataAccess.GetCustomer(username, password);

            if (customer != null)
            {
                customer.SearchValues = DhDataAccess.GetSearchValues(customer.ID);
                us.Customer = customer;
            }
            else
            {
                // the login attempt failed
                // return error
                ViewBag.ErrorMessage = "The username or password did not match please try again";
                return RedirectToAction("unauthenticated");
            }

            string url = Request.UrlReferrer.ToString();

            // check if we have just logged in from the register view,
            // it would ne be intuitive to return to this view
            if (_redirectRequesters.Contains(url.ToLower()))
            {
                // http://localhost:52075/Register/Details
                url = "http://localhost:52075";
            }

            return Redirect(url);
        }

        [HttpPost]
        public JsonResult LoginUsingAjax(string username, string password, UserSession us)
        {
            Customer customer = DhDataAccess.GetCustomer(username, password);

            if (customer != null)
            {
                customer.SearchValues = DhDataAccess.GetSearchValues(customer.ID);
                us.Customer = customer;
                return Json(new { authenticated = true });
            }
            else
            {
                return Json(new { authenticated = false, message = "The username or password did not match please try again" });
            }
        }

        public ActionResult Unauthenticated()
        {
            Response.StatusCode = 401;
            return View("_Unauthenticated");
        }
    }
}