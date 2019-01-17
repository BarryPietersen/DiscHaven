using System;
using System.Collections.Generic;
using System.Transactions;
using System.Web.Mvc;
using DiscHaven.Attributes;
using DiscHaven.ViewModels;
using DiscHaven.WebModels;
using DiscHavenDataAccess;
using DiscHavenDataAccess.DhDto;
using DiscHavenDataAccess.Models;


namespace DiscHaven.Controllers
{
    [ValidateSession]
    public class RegisterController : Controller
    {
        public ActionResult Details()
        {
            CustomerDetailsViewModel customerDetailsVm = new CustomerDetailsViewModel()
            {
                IsNew = true,
                CustomerDto = new CustomerDto()
                {
                    FirstName = "Barry", LastName = "Pietersen", Email = "barry@gmail.com",
                    Address = "5 Hard Drive", City = "Albany", State = "Western Australia", PostCode = "6330",
                    Username = "barrypietersen", PasswordHint = "secret password hint"
                }
            };

            return View(customerDetailsVm);
        }

        [HandleAntiForgeryException]
        [ValidateAntiForgeryToken]
        public ActionResult ValidateDto(CustomerDto customerDto, UserSession us)
        {
            List<SecQA> sqas = new List<SecQA>
            {
                new SecQA { Question = Request["SecurityQuestion1"], Answer = Request["SecurityAnswer1"]},
                new SecQA { Question = Request["SecurityQuestion2"], Answer = Request["SecurityAnswer2"]},
                new SecQA { Question = Request["SecurityQuestion3"], Answer = Request["SecurityAnswer3"]},
            };

            CustomerDetailsViewModel customerDetailsVm = new CustomerDetailsViewModel()
            {
                IsNew = true,
                CustomerDto = customerDto,
                SecurityQuestions = sqas,
                ValidationMessages = new Dictionary<string, string>()
            };

            if (DtoValidator.ValidateCustomerData(customerDto, customerDetailsVm.ValidationMessages, sqas, true, Request["ConfirmPassword"]))
            {
                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        CommandResult cr = DhDataAccess.CreateCustomer(customerDto);
                        if (cr.ID > 0)
                        {
                            cr = DhDataAccess.AddSecurityQAs(sqas, cr.ID);

                            if (cr.ID > 0)
                            {
                                us.Customer = DhDataAccess.GetCustomer(customerDto.Username, customerDto.Password);

                                ts.Complete();
                                return RedirectToAction("Index", "Home");
                            }
                            else ViewBag.ErrorMessage = cr.ErrorMessage;
                        }
                        else
                        {
                            ViewBag.ErrorMessage = cr.ErrorMessage;
                            customerDetailsVm.ValidationMessages.Add("Username", "That username already exists in the database, please try again with a different one.");
                        }

                        return View("Details", customerDetailsVm);
                    }
                }
                catch (Exception ex)
                {
                    ViewBag.ErrorMessage = ex.Message;
                    return View("Details", customerDetailsVm);
                }
            }

            //there was invalid input
            ViewBag.ErrorMessage = "One or more of the fields require editing";
            return View("Details", customerDetailsVm);
        }
    }
}