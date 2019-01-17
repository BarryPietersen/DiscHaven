using System.Collections.Generic;
using DiscHavenDataAccess.DhDto;
using DiscHavenDataAccess.Models;

namespace DiscHavenDataAccess
{
    public static class DtoValidator
    {
        public static bool ValidateCustomerData(CustomerDto customerDto,
            Dictionary<string, string> validationMessages, List<SecQA> securityQuestions,
            bool isNew, string confirmPassword = "")
        {
            var c = customerDto;
            var vm = validationMessages;

            if (string.IsNullOrEmpty(c.FirstName) || c.FirstName.Trim().Length == 0) vm.Add("FirstName", "Please enter your first name here.");
            if (string.IsNullOrEmpty(c.LastName) || c.LastName.Trim().Length == 0) vm.Add("LastName", "Please enter your last name here.");
            if (string.IsNullOrEmpty(c.Email) || c.Email.Trim().Length == 0) vm.Add("Email", "Email address should contain '@' and '.' symbols.");
            if (string.IsNullOrEmpty(c.Address) || c.Address.Trim().Length == 0) vm.Add("Address", "Please enter your address name here.");
            if (string.IsNullOrEmpty(c.City) || c.City.Trim().Length == 0) vm.Add("City", "Please enter your city name here.");
            if (string.IsNullOrEmpty(c.State) || c.State.Trim().Length == 0) vm.Add("State", "Please enter your state here.");
            if (string.IsNullOrEmpty(c.PostCode) || c.PostCode.Trim().Length == 0) vm.Add("PostCode", "Please enter your post code here.");
            if (string.IsNullOrEmpty(c.ShipAddress) || c.ShipAddress.Trim().Length == 0) vm.Add("ShipAddress", "Please enter your shipping address here.");
            if (string.IsNullOrEmpty(c.ShipCity) || c.ShipCity.Trim().Length == 0) vm.Add("ShipCity", "Please enter your shipping city here.");
            if (string.IsNullOrEmpty(c.ShipState) || c.ShipState.Trim().Length == 0) vm.Add("ShipState", "Please enter your shipping state here.");
            if (string.IsNullOrEmpty(c.ShipPostCode) || c.ShipPostCode.Trim().Length == 0) vm.Add("ShipPostCode", "Please enter your shipping post code here.");
            if (string.IsNullOrEmpty(c.Username) || c.Username.Trim().Length == 0) vm.Add("Username", "Please enter an appropriate username here.");
            if (string.IsNullOrEmpty(c.PasswordHint) || c.PasswordHint.Trim().Length == 0) vm.Add("PasswordHint", "Please provide a valid password hint.");

            if (isNew || c.Password != null)
            {
                if (!TestPasswordStrength(c.Password))
                {
                    vm.Add("Password", @"Please provide a password that contains at least one of each uppercase character, lowercase character,
                                         number, 'special charater e.g '@ % ^' and has a length of at least 8 characters total.");
                    vm.Add("ConfirmPassword", "Please enter a matching strong password here.");
                }
                else if (string.IsNullOrEmpty(confirmPassword) || confirmPassword != c.Password)
                {
                    vm.Add("Password", "The given passwords did not match.");
                    vm.Add("ConfirmPassword", "The given passwords did not match.");
                }
            }

            if (securityQuestions.Count == 3)
            {
                byte i = 1;

                foreach (var qa in securityQuestions)
                {
                    if (string.IsNullOrEmpty(qa.Question) || qa.Question.Trim().Length == 0) vm.Add($"SecurityQuestion{i}", "Please provide a meaningful security question here.");
                    if (isNew && string.IsNullOrEmpty(qa.Answer)) vm.Add($"SecurityAnswer{i}", "Please provide matching security answer.");
                    i++;
                }
            }
            else { }// the number of supplied qas does not meet the requirements

            return vm.Count == 0;
        }

        //test password strength here, using ascii values
        public static bool TestPasswordStrength(string password)
        {
            if (string.IsNullOrEmpty(password)) return false;

            int up = 0, lo = 0, dig = 0, sp = 0;

            foreach (char ch in password)
            {
                if (ch > 96 && ch < 123) lo++;
                else if (ch > 64 && ch < 91) up++;
                else if (ch > 47 && ch < 58) dig++;

                else if ((ch > 32 && ch < 48) ||
                         (ch > 57 && ch < 65) ||
                         (ch > 90 && ch < 97) ||
                         (ch > 122 && ch < 127)) sp++;
            }
            return up > 0 && lo > 1 && dig > 1 && sp > 1;
        }

        private static bool ValidateEmail(string email)
        {
            int at = email.IndexOf('@');
            int dot = email.IndexOf('.');

            if (email.Length < 4 || at < 0 || dot < 0)
                return false;
            else
                return true;
        }
    }
}
