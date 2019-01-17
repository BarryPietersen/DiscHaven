using System;
using System.Collections.Generic;
using System.Transactions;
using System.Web.Mvc;
using DiscHaven.Attributes;
using DiscHaven.ViewModels;
using DiscHavenDataAccess;
using DiscHavenDataAccess.DhDto;
using DiscHavenDataAccess.Models;
using System.Linq;

namespace DiscHaven.Controllers
{
    [AuthenticateClient]
    public class AccountController : Controller
    {
        //returns a view that displays all of the items inside the customers shopping cart
        public ActionResult ShoppingCart(Customer customer)
        {
            List<CartLineItem> lineItems = DhDataAccess.GetCartItems(customer.ID);
            ViewBag.GstFactor = DhDataAccess.GetGstFactor();
            return View(lineItems);
        }

        //returns an editable view that displays all of the customers personal and account details
        public ActionResult Details(Customer customer)
        {
            //try catch
            CustomerDto customerDto = DhDataAccess.GetCustomerDto(customer.ID);
            List<SecQA> secQAs = DhDataAccess.GetSecurityQuestions(customer.ID);

            CustomerDetailsViewModel customerDetailsVM = new CustomerDetailsViewModel()
            {
                IsNew = false,
                CustomerDto = customerDto,
                SecurityQuestions = secQAs
            };

            return View(customerDetailsVM);
        }

        //performs data validation and database transactions to update the customers details
        //https://docs.microsoft.com/en-us/aspnet/web-api/overview/security/preventing-cross-site-request-forgery-csrf-attacks   
        [HandleAntiForgeryException]
        [ValidateAntiForgeryToken]
        public ActionResult UpdateDetails(CustomerDto customerDto, Customer customer)
        {
            List<SecQA> qas = new List<SecQA>
            {
                new SecQA(Request["SecurityQuestion1"], Request["SecurityAnswer1"], long.Parse(Request["SecurityQuestion1ID"])),
                new SecQA(Request["SecurityQuestion2"], Request["SecurityAnswer2"], long.Parse(Request["SecurityQuestion2ID"])),
                new SecQA(Request["SecurityQuestion3"], Request["SecurityAnswer3"], long.Parse(Request["SecurityQuestion3ID"]))
            };

            CustomerDetailsViewModel customerDetailsVm = new CustomerDetailsViewModel()
            {
                IsNew = false,
                CustomerDto = customerDto,
                SecurityQuestions = qas,
                ValidationMessages = new Dictionary<string, string>()
            };

            if (DtoValidator.ValidateCustomerData(customerDto, customerDetailsVm.ValidationMessages, qas, false, Request["ConfirmPassword"]))
            {
                //attempt insert
                //return view if successfull, notify of error if not
                customerDto.ID = customer.ID;

                try
                {
                    using (TransactionScope ts = new TransactionScope())
                    {
                        CommandResult customerRes = DhDataAccess.UpdateCustomer(customerDto);

                        if (customerRes.ID > 0)
                        {
                            CommandResult secQARes = DhDataAccess.UpdateSecurityQAs(qas);
                            if (secQARes.ID > 0)
                            {
                                customer.FirstName = customerDto.FirstName;
                                customer.LastName = customerDto.LastName;

                                ts.Complete();
                                return RedirectToAction("Index", "Home");
                            }
                            else ViewBag.ErrorMessage = secQARes.ErrorMessage;
                        }
                        else ViewBag.ErrorMessage = customerRes.ErrorMessage;

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
            ViewBag.ErrorMessage = "One or more of the fields require editing, no changes have been made yet.";
            return View("Details", customerDetailsVm);
        }

        public ActionResult OrderHistory(Customer customer)
        {
            List<OrderSummary> orders = DhDataAccess.GetOrderSummary(customer.ID);

            return View(orders);
        }

        public JsonResult Order(long id, Customer customer)
        {
            OrderDetails od = DhDataAccess.GetOrderDetails(id, customer.ID);

            return Json(new { od.Summary, od.LineItems }, JsonRequestBehavior.AllowGet);
        }

        public PartialViewResult OrderItems(long id, Customer customer)
        {
            List<LineItem> items = DhDataAccess.GetOrderLineItems(id, customer.ID);
            return PartialView("_OrderLineItems", items);
        }

        public ActionResult Checkout(Customer customer)
        {
            //check if there is at least one item in the cart
            if (customer.CartCount > 0)
            {
                CommandResult cr = DhDataAccess.CheckOut(customer.ID);
                if (cr.ID > 0)
                {
                    //default the cart count variable
                    customer.CartCount = 0;
                    return RedirectToAction("Index", "Home");
                }
                ViewBag.ErrorMessage = cr.ErrorMessage;
            }
            return RedirectToAction("ShoppingCart", "Account");
        }

        public ActionResult Logout(Customer customer)
        {
            Session.Clear();
            return RedirectToAction("Index", "Home");
        }

        [HttpPost]
        public JsonResult AddShoppingCartItem(long id, Customer customer)
        {
            CommandResult commandResult = DhDataAccess.UpdateCart(customer.ID, id);

            if (commandResult.ID > 0) customer.CartCount = DhDataAccess.GetCartCount(customer.ID);

            //display appropriate message
            return Json(new { cartCount = customer.CartCount, commandResult }, JsonRequestBehavior.AllowGet);
        }

        //'id' is the PK of the shopping cart record
        [HttpPost]
        public ActionResult RemoveCartItem(long id, Customer customer)
        {
            //make db calls update cart table using
            //the cartitem id passed back from the client 
            //and the customer id on the current session

            ////make db call to update cart object
            int affected = DhDataAccess.RemoveCartItem(id, customer.ID);
            //customer.CartCount = DhDataAccess.GetCartCount(customer.ID);

            //return RedirectToAction("ShoppingCart");

            if (affected > 0) customer.CartCount = DhDataAccess.GetCartCount(customer.ID);

            return Json(new { removed = affected > 0, cartCount = customer.CartCount }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult UpdateCartItemQuantity(long id, long pid, int qty, Customer customer)
        {
            if (qty < 1)
            {
                int affected = DhDataAccess.RemoveCartItem(id, customer.ID);
                if (affected > 0) customer.CartCount = DhDataAccess.GetCartCount(customer.ID);
                return Json(new { success = affected > 0, removed = true, cartCount = customer.CartCount }, JsonRequestBehavior.AllowGet);
            }

            CommandResult commandResult = DhDataAccess.UpdateCart(customer.ID, pid, id, qty);
            if (commandResult.ID > 0)
                customer.CartCount = DhDataAccess.GetCartCount(customer.ID);
            else qty = DhDataAccess.GetCartItems(customer.ID).Where(i => i.ID == id).First().Quantity;
            return Json(new { success = commandResult.ID > 0, commandResult, cartCount = customer.CartCount, qty }, JsonRequestBehavior.AllowGet);
        }
    }
}