using System.Web.Mvc;
using DiscHaven.WebModels;

namespace DiscHaven.Attributes
{
    public class ValidateSessionAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            //check if there is an active user session
            if (filterContext.HttpContext.Session["UserSession"] == null)
            {
                filterContext.HttpContext.Session["UserSession"] = new UserSession();
            }

            //make the usersession object available to the action method as a parameter.
            //the object will be cast and passed to the action method if a parameter UserSession is required.
            //this saves us casting the reference in the action method each time we need the UserSession reference.
            filterContext.ActionParameters["us"] = filterContext.HttpContext.Session["UserSession"];
        }
    }
}