using DiscHavenDataAccess.Models;

namespace DiscHaven.WebModels
{
    public class UserSession
    {
        public Customer Customer { get; set; }
        public SearchParams SearchParams { get; set; }
        public bool IsAuthenticated => Customer != null;

        public UserSession()
        {
            Customer = null;
            SearchParams = new SearchParams();
        }
    }
}