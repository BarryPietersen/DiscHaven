using System.Web.Mvc;
using DiscHaven.ViewModels;
using DiscHaven.WebModels;
using DiscHavenDataAccess.Models;

namespace DiscHaven.Controllers
{
    public class SiteController : Controller
    {
        //renders a navbar view for the layout page
        [ChildActionOnly]
        public PartialViewResult RenderNavBar()
        {
            ////get mediatypes from db
            //var mediaTypes = DhDataAccess.GetMediaTypes();

            var mediaTypes = new MediaTypes
            {
                new MediaType(1, "Blu Ray"),
                new MediaType(2, "DVD"),
                new MediaType(3, "CD"),
                new MediaType(4, "Vinyl")
            };

            ////get categories from db
            //var categories = DhDataAccess.GetCategories();

            var categories = new Categories
            {
                new Category(1, "Movies"),
                new Category(2, "Music"),
                new Category(3, "Games")
            };

            NavBarViewModel navBarViewModel = new NavBarViewModel()
            {
                MediaTypes = mediaTypes,
                Categories = categories,
                UserSession = (UserSession)Session["UserSession"]
            };

            return PartialView("_NavBar", navBarViewModel);
        }
    }
}