using System.Web.Mvc;
using DiscHaven.Attributes;
using DiscHavenDataAccess;
using DiscHavenDataAccess.Models;

namespace DiscHaven.Controllers
{
    [ValidateSession]
    public class ForgottenController : Controller
    {
        private const string _failedAnswerMessage = "One or more of the answers did not match, please try again..";
        private const string _failedPasswordMessage = "The Passwords did not match or meet the minimum requirements";
        private string _usernameNotFoundMessage(string username) => $"We did not find a match for the username '{username}', please try again..";

        public JsonResult GetPasswordHint(string username)
        {
            string hint = DhDataAccess.GetPasswordHint(username);
            bool foundMatch = !string.IsNullOrEmpty(hint);

            return Json(new { foundMatch, message = foundMatch ? hint : _usernameNotFoundMessage(username) });
        }

        public ActionResult GetChallengeQuestions(string username)
        {
            SecQA[] qs = DhDataAccess.GetChallengeQuestions(username);

            if (qs.Length == 0)
            {
                string ErrorMessage = _usernameNotFoundMessage(username);
                return Json(new { ErrorMessage });
            }
            return PartialView("_ChallengeQuestions", qs);
        }

        public ActionResult SubmitChallengeAnswers()
        {
            SecQA[] qas = new SecQA[2];

            for (int i = 1; i <= qas.Length; i++)
            {
                qas[i - 1] = new SecQA() { ID = long.Parse(Request[$"question{i}ID"]), Answer = Request[$"answer{i}"] };
            }

            long cid = DhDataAccess.CheckChallengeAnswers(qas, Request["Username"]);

            if (cid > 0)
            {
                Session["ForgottenID"] = cid;
                return PartialView("_ResetPassword");
            }
            else
            {
                ViewBag.ErrorMessage = _failedAnswerMessage;
                SecQA[] qs = DhDataAccess.GetChallengeQuestions(Request["Username"]);
                return PartialView("_ChallengeQuestions", qs);
            }
        }

        public ActionResult SubmitForgottenPassword(string password, string confirmPassword)
        {
            // can check the ForgottenID session variable for null - if so,
            // a request has been made to this action without providing matching QAs
            // return an alternate error message
            if (string.Equals(password, confirmPassword) &&
                DtoValidator.TestPasswordStrength(password) &&
                Session["ForgottenID"] != null)
            {
                long cid = (long)Session["ForgottenID"];
                CommandResult res = DhDataAccess.ResetForgottenPassword(cid, password);

                return Json(res);
            }
            else
            {
                ViewBag.ErrorMessage = _failedPasswordMessage;
                return PartialView("_ResetPassword");
            }
        }
    }
}