using System.Web.Mvc;
using System.Web.Routing;
using DiscHaven.WebModels;

namespace DiscHaven.Attributes
{
    public class AuthenticateClientAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            UserSession us = ((UserSession)filterContext.HttpContext.Session["UserSession"]);

            //check if there is a current user session
            //if not we create a new instance of UserSession
            //and store it on the HttpSessionStateBase        
            if (us == null)
            {
                us = new UserSession();
                filterContext.HttpContext.Session["UserSession"] = us;               
            }

            if (!us.IsAuthenticated)
            {
                //unauthorised access redirect to a login view
                filterContext.Result =
                    new RedirectToRouteResult(
                        new RouteValueDictionary{
                            { "controller", "home" },
                            { "action", "unauthenticated" }
                        });              
            }

            //make the customer object available to the action method as a parameter.
            //the object will be cast and passed to the action method if a parameter Customer is required.
            //this saves us casting the reference in the action method each time we need the Customer reference.
            filterContext.ActionParameters["customer"] = us.Customer;
        }
    }
}