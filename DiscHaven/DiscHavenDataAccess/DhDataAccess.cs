using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using Dapper;
using DiscHavenDataAccess.DhDto;
using DiscHavenDataAccess.Models;

namespace DiscHavenDataAccess
{
    /*
     Dapper is a simple object mapper for .NET and owns the title 'King of Micro ORM' in terms of speed - virtually as fast as using a raw ADO.NET data reader.
     An ORM is an Object Relational Mapper, which is responsible for mapping between database and programming language.
     Dapper extends the IDbConnection by providing useful extension methods to query your database.
     http://dapper-tutorial.net/dapper
    */

    //this class uses the dapper library for its lightweight object mapping services
    public static class DhDataAccess
    {
        //connection string will be scoped so that its value is retrieved from a config file each time a db connection is made
        private static readonly string ConnectionString = (ConfigurationManager.ConnectionStrings["discHavenDB"].ConnectionString);

        //shared calls to dapper
        //================================================================================================================================================

        private static T QuerySingle<T>(string command, object param = null, CommandType commandType = CommandType.StoredProcedure)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                return conn.QuerySingle<T>(sql: command, param: param, commandType: commandType);
            }
        }

        private static IEnumerable<T> Query<T>(string command, object param = null, CommandType commandType = CommandType.StoredProcedure)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                return conn.Query<T>(command, param, commandType: commandType);
            }
        }

        private static T ExecuteScalar<T>(string command, object param = null, CommandType commandType = CommandType.StoredProcedure)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                return conn.ExecuteScalar<T>(sql: command, param: param, commandType: commandType);
            }
        }

        private static int Execute(string command, object param = null, CommandType commandType = CommandType.StoredProcedure)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                return conn.Execute(sql: command, param: param, commandType: commandType);
            }
        }

        private static T QueryFirstOrDefault<T>(string command, object param = null, CommandType commandType = CommandType.StoredProcedure)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                return conn.QueryFirstOrDefault<T>(sql: command, param: param, commandType: commandType);
            }
        }



        //====================================================================================================================================================

        public static CommandResult CreateStaffMember(StaffDto staffDto)
        {
            DynamicParameters dp = new DynamicParameters(staffDto);
            dp.AddCommandResultParams();

            Execute("uspAddStaff", dp);

            return dp.GetCommandResult();
        }

        public static CommandResult UpdateStaffMember(StaffDto staffDto)
        {
            DynamicParameters dp = new DynamicParameters(staffDto);
            dp.AddCommandResultParams(staffDto.ID, ParameterDirection.InputOutput);

            Execute("uspUpdateStaff", dp);

            return dp.GetCommandResult(); ;
        }

        //get the full staff record 
        public static StaffDto GetStaffDto(long sid)
        {
            return QueryFirstOrDefault<StaffDto>("uspGetStaffDto", new { ID = sid });
        }

        public static StaffUser GetStaff(string username, string password)
        {
            return QueryFirstOrDefault<StaffUser>("uspGetStaff", new { Username = username, Password = password });
        }

        public static IEnumerable<StaffInfo> GetStaffRecords(StaffSearchParams qryParams)
        {
            return Query<StaffInfo>("uspGetStaffRecords", qryParams);
        }

        public static CommandResult AddStaffRole(long sid, long rid)
        {
            DynamicParameters dp = new DynamicParameters();
            dp.AddCommandResultParams();

            dp.Add("RoleID", rid, direction: ParameterDirection.Input);
            dp.Add("StaffID", sid, direction: ParameterDirection.Input);

            Execute("uspAddStaffRole", dp);

            return dp.GetCommandResult();
        }

        public static IEnumerable<Role> GetStaffRole(long id)
        {
            return Query<Role>("uspGetStaffRoles", new { ID = id });
        }

        public static int RemoveStaffRole(long id, long roleID)
        {
            return Execute("uspRemoveStaffRole", new { ID = id, RoleID = roleID });
        }

        //====================================================================================================================================================

        public static CommandResult CreateCustomer(CustomerDto customerDto)
        {
            DynamicParameters dp = new DynamicParameters(customerDto);
            dp.AddCommandResultParams();

            Execute("uspAddCustomer", param: dp);

            return dp.GetCommandResult();
        }

        public static CommandResult UpdateCustomer(CustomerDto customerDto)
        {
            DynamicParameters dp = new DynamicParameters(customerDto);
            dp.AddCommandResultParams(customerDto.ID, ParameterDirection.InputOutput);

            Execute("uspUpdateCustomer", param: dp);

            return dp.GetCommandResult(); ;
        }

        public static CustomerDto GetCustomerDto(long id)
        {
            return QueryFirstOrDefault<CustomerDto>("uspGetCustomerDto", new { ID = id });
        }

        /// <summary>
        /// Performs an athentication check on the username and password combination, returns null if no match is found.
        /// </summary>
        /// <param name="username">The unique username of the customer.</param>
        /// <param name="password">The raw text password of the customer, hashing is performed at the database.</param>
        /// <returns>Customer or null</returns>
        public static Customer GetCustomer(string username, string password)
        {
            return QueryFirstOrDefault<Customer>("uspGetCustomer", new { Username = username, Password = password });
        }

        //loop over the list and insert each record using the fkcustomer id
        public static CommandResult AddSecurityQAs(List<SecQA> qas, long cid)
        {
            var dp = new DynamicParameters();
            dp.AddCommandResultParams();
            dp.Add("CustomerID", cid, direction: ParameterDirection.Input);

            foreach (var qa in qas)
            {
                dp.AddDynamicParams(qa);

                Execute("uspAddSecurityQA", dp, CommandType.StoredProcedure);

                //check if the insert was successfull, if not return command result
                if (dp.Get<long>("ID") == 0)
                {
                    return dp.GetCommandResult();
                }
            }

            return new CommandResult { ID = 1, ErrorMessage = "" };
        }

        //loop over the list and update each record using the fkcustomer id
        public static CommandResult UpdateSecurityQAs(List<SecQA> qas)
        {
            var dp = new DynamicParameters();
            dp.AddCommandResultParams();

            foreach (var qa in qas)
            {
                dp.AddDynamicParams(qa);
                dp.Add("ID", qa.ID, direction: ParameterDirection.InputOutput);

                Execute("uspUpdateSecurityQA", dp);

                //check if the insert was successfull if not return command result
                if (dp.Get<long>("ID") == 0)
                {
                    return dp.GetCommandResult();
                }
            }

            //return a successful CommandResult
            return new CommandResult { ID = 1, ErrorMessage = "" };
        }

        public static List<SecQA> GetSecurityQuestions(long cid)
        {
            return Query<SecQA>("uspGetSecurityQAs", new { FKCustomerID = cid }).ToList();
        }

        public static string GetPasswordHint(string username)
        {
            return QueryFirstOrDefault<string>("uspGetPasswordHint", new { Username = username });
        }

        public static SecQA[] GetChallengeQuestions(string username)
        {
            return Query<SecQA>("uspGetChallengeQuestions", new { Username = username }).ToArray();
        }

        public static long CheckChallengeAnswers(SecQA[] qas, string username)
        {
            long cid = 0;
            foreach (var qa in qas)
            {
                cid = ExecuteScalar<long>("uspCheckChallengeAnswer", new { qa.ID, Username = username, qa.Answer });
                if (cid < 1) return cid;
            }

            return cid;
        }

        public static CommandResult ResetForgottenPassword(long cid, string password)
        {
            DynamicParameters dp = new DynamicParameters();
            dp.AddCommandResultParams();
            dp.Add("ID", cid);
            dp.Add("Password", password);

            Execute("uspUpdateForgottenPassword", dp);

            return dp.GetCommandResult();
        }

        //====================================================================================================================================================

        public static CommandResult CreateTitle(TitleDto title)
        {
            DynamicParameters dp = new DynamicParameters(title);
            dp.AddCommandResultParams(title.ID, ParameterDirection.InputOutput);

            Execute("uspCreateTitle", dp);

            return dp.GetCommandResult();
        }

        public static CommandResult UpdateTitle(TitleDto title)
        {
            DynamicParameters dp = new DynamicParameters(title);
            dp.AddCommandResultParams(title.ID, ParameterDirection.InputOutput);

            Execute("uspUpdateTitle", dp);

            return dp.GetCommandResult();
        }

        public static TitleDto GetTitleDto(long tid)
        {
            return QueryFirstOrDefault<TitleDto>("uspGetTitle", new { ID = tid });
        }

        public static IEnumerable<Title> GetTitles(long categoryID, string searchValue)
        {
            DynamicParameters dp = new DynamicParameters(new { CategoryID = categoryID, SearchValue = searchValue });

            return Query<Title>("uspGetTitles", dp);
        }

        public static CommandResult CreateProduct(ProductDto productDto)
        {
            DynamicParameters dp = new DynamicParameters(productDto);
            dp.AddCommandResultParams(productDto.ID, ParameterDirection.InputOutput);

            Execute("uspCreateProduct", dp);

            return dp.GetCommandResult();
        }

        public static CommandResult UpdateProduct(ProductDto productDto)
        {
            DynamicParameters dp = new DynamicParameters(productDto);
            dp.AddCommandResultParams(productDto.ID, ParameterDirection.InputOutput);

            Execute("uspUpdateProduct", dp);

            return dp.GetCommandResult(); ;
        }

        //this dynamic sql statement for getting prods based on criteria
        public static IEnumerable<Product> GetProducts(SearchParams searchParams)
        {
            return Query<Product>("uspGetProducts", searchParams);
        }

        //this dynamic sql statement for getting prods based on criteria
        public static IEnumerable<Product> GetActiveProducts(SearchParams searchParams, ref int requestedPage, ref int totalPages)
        {
            DynamicParameters dp = new DynamicParameters(searchParams);
            dp.Add("RequestedPage", requestedPage, DbType.Int32, ParameterDirection.InputOutput);
            dp.Add("TotalPages", totalPages, DbType.Int32, ParameterDirection.InputOutput);

            IEnumerable<Product> results =  Query<Product>("uspGetActiveProducts", dp);

            requestedPage = dp.Get<int>("RequestedPage");
            totalPages = dp.Get<int>("TotalPages");

            return results;
        }

        public static Product GetProduct(long id)
        {
            return QueryFirstOrDefault<Product>("uspGetProduct", new { ID = id });
        }

        public static Product GetActiveProduct(long id)
        {
            return QueryFirstOrDefault<Product>("uspGetActiveProduct", new { ID = id });
        }

        public static ProductDto GetProductDto(long id)
        {
            return QueryFirstOrDefault<ProductDto>("uspGetProductDto", new { ID = id });
        }

        public static IEnumerable<ProductQty> GetProductQuantities(long lid, SearchParams searchParams)
        {
            DynamicParameters dp = new DynamicParameters(searchParams);
            dp.Add("LocationID", lid);

            return Query<ProductQty>("uspGetProductQuantities", dp);
        }

        public static CommandResult UpdateProductStock(long pid, long lid, int qty)
        {
            DynamicParameters dp = new DynamicParameters();
            dp.AddCommandResultParams();
            dp.Add("ProductID", pid);
            dp.Add("LocationID", lid);
            dp.Add("Quantity", qty);

            int rows = Execute("uspUpdateProductStock", dp);

            return dp.GetCommandResult();
        }

        //====================================================================================================================================================

        //public static CommandResult AddToCart(long cid, long pid)
        //{
        //    DynamicParameters dp = new DynamicParameters();
        //    dp.AddCommandResultParams();

        //    dp.Add("CustomerID", cid, direction: ParameterDirection.Input);
        //    dp.Add("ProductID", pid, direction: ParameterDirection.Input);
        //    dp.Add("Quantity", (long)1, direction: ParameterDirection.Input);

        //    int affected = Execute("uspAddToCart", dp);

        //    return dp.GetCommandResult();
        //}

        public static CommandResult UpdateCart(long cid, long pid, long id = 0, int qty = 1)
        {
            DynamicParameters dp = new DynamicParameters();

            dp.AddCommandResultParams(id, ParameterDirection.InputOutput);

            dp.Add("CustomerID", cid);
            dp.Add("ProductID", pid);
            dp.Add("Quantity", qty);

            int affected = Execute("uspUpdateCart", dp);

            return dp.GetCommandResult();
        }

        public static LineItem UpdateCartItemQty(long cid, long scid, int qty)
        {
            return QueryFirstOrDefault<LineItem>("uspUpdateCartItemQty", new { ID = cid, ScID = scid, Quantity = qty });
        }

        public static List<CartLineItem> GetCartItems(long cid)
        {
            return Query<CartLineItem>("uspGetCartItems", new { ID = cid }).ToList();
        }

        public static int GetCartCount(long cid)
        {
            return ExecuteScalar<int>("uspGetCartCount", new { ID = cid });
        }

        public static int RemoveCartItem(long id, long cid)
        {
            return Execute("uspRemoveCartItem", new { ID = id, CustomerID = cid });
        }

        // Create a new order, empty the customers shopping cart into the order and update location stocks
        public static CommandResult CheckOut(long cid)
        {
            DynamicParameters dp = new DynamicParameters();

            dp.AddCommandResultParams();

            dp.Add("CustomerID", cid);

            // the location ID of Manjimup
            // is hard coded here
            dp.Add("LocationID", (long)4);

            Execute("uspCheckOut", dp);

            return dp.GetCommandResult();
        }

        //====================================================================================================================================================

        //using dappers querymultiple - returns a grid reader of multiple result sets,
        //the SqlMapper.GridReader object can perform reads from one set, advances to the next
        public static OrderDetails GetOrderDetails(long oid, long cid)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                using (var reader = conn.QueryMultiple("uspGetOrderDetails", new { ID = oid, CustomerID = cid }, commandType: CommandType.StoredProcedure))
                {
                    var orderSummary = reader.ReadFirst<OrderSummary>();
                    var lineItems = reader.Read<LineItem>().ToList();

                    return new OrderDetails { Summary = orderSummary, LineItems = lineItems };
                }
            }
        }

        public static List<OrderSummary> GetOrderSummary(long cid, long oid = 0)
        {
            return Query<OrderSummary>("uspGetOrderSummary", new { ID = oid, CustomerID = cid }).ToList();
        }

        public static List<LineItem> GetOrderLineItems(long oid, long cid)
        {
            return Query<LineItem>("uspGetOrderLineItems", new { ID = oid, CustomerID = cid }).ToList();
        }

        //====================================================================================================================================================

        public static List<string> GetSearchValues(long cid)
        {
            return Query<string>("uspGetSearchValues", new { CustomerID = cid }).ToList();
        }

        public static CommandResult AddSearchValue(long cid, string searchValue)
        {
            DynamicParameters dp = new DynamicParameters(new { CustomerID = cid, SearchValue = searchValue });
            dp.AddCommandResultParams();

            Execute("uspAddSearchValue", dp);

            return dp.GetCommandResult();
        }

        public static CommandResult UpdateConfigSettings(ConfigDto configDto)
        {
            DynamicParameters dp = new DynamicParameters(configDto);
            dp.AddCommandResultParams();

            Execute("uspInsertConfigSettings", dp);

            return dp.GetCommandResult();
        }

        public static ConfigDto GetConfigSettings()
        {
            return QueryFirstOrDefault<ConfigDto>("uspGetConfigSettings");
        }

        // returns the configurable number of search results per page
        public static int GetPaginationLimit()
        {
            return QuerySingle<int>("uspGetPaginationLimit");
        }

        // returns the configurable slide show interval
        public static float GetSlideInterval()
        {
            return QuerySingle<float>("uspGetSlideInterval");
        }

        public static dynamic GetGstFactor()
        {
            return QuerySingle<float>("uspGetGSTFactor");
        }

        public static IEnumerable<Location> GetLocations()
        {
            return Query<Location>("uspGetLocations");
        }

        public static IEnumerable<Category> GetCategories()
        {
            return Query<Category>("uspGetCategories");
        }

        public static IEnumerable<MediaType> GetMediaTypes()
        {
            return Query<MediaType>("uspGetMediaTypes");
        }

        public static IEnumerable<Role> GetRoles()
        {
            return Query<Role>("uspGetRoles");
        }

        //====================================================================================================================================================

        /// <summary>
        /// Adds 'ID', 'ErrorMessage' paramaters to the DynamicParameters collection. These are used by Disc Haven store procs and the CommandResult return value
        /// </summary>
        /// <param name="dp">the DynamicParameters instance to add the parameters to</param>
        /// <param name="id">the value for the ID parameter</param>
        /// <param name="idDirection">specify the ID parameter direction, defaults to 'Output'</param>
        private static void AddCommandResultParams(this DynamicParameters dp, long id = 0, ParameterDirection idDirection = ParameterDirection.Output)
        {
            dp.Add("ID", id, direction: idDirection);
            dp.Add("ErrorMessage", "", direction: ParameterDirection.Output);
        }

        /// <summary>
        /// Call this method on a DynamicParameters instance after it has performed its database action and has the parameters reqired for a CommandResult
        /// </summary>
        /// <param name="dp">the DynamicParameters instance to look the values up</param>
        /// <returns>CommandResult</returns>
        private static CommandResult GetCommandResult(this DynamicParameters dp)
        {
            long id = dp.Get<long>("ID");
            string er = dp.Get<string>("ErrorMessage");

            return new CommandResult { ID = dp.Get<long>("ID"), ErrorMessage = dp.Get<string>("ErrorMessage") };
        }
    }
}