using System.Web.Mvc;
using System.Web.Routing;

namespace DiscHaven.Attributes
{
    //handles an HttpAntiForgeryException by performing a redirect
    //TODO: pass an error message to the destination view
    public class HandleAntiForgeryExceptionAttribute : HandleErrorAttribute
    {
        public override void OnException(ExceptionContext context)
        {
            if (context.Exception is HttpAntiForgeryException ex)
            {
                //context.RouteData.Values["ErrorMessage"] = ex.Message;
                RequestContext requestContext = new RequestContext(context.HttpContext, context.RouteData);

                string url =
                    RouteTable.Routes.GetVirtualPath(requestContext,
                        new RouteValueDictionary{
                            { "controller", "Home" },
                            { "action", "Unauthenticated" },
                            { "ErrorMessage", ex.Message }
                        }).VirtualPath;

                context.HttpContext.Response.Redirect(url, true);
            }
            else
            {
                base.OnException(context);
            }
        }
    }
}