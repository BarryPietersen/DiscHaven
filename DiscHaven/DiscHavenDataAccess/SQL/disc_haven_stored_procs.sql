/*
	Developed By: Barry Pietersen, Z018771
	Purpose: Store procedures for disc haven database
	Date Created: 16/08/2018
*/

USE db_disc_haven;
GO

------------------------------ ENCRYPTION / DECRYPTION ------------------------------
------------------------------ STORED PROC & FUNCTIONS ------------------------------
CREATE PROCEDURE uspOpenKeys
AS
BEGIN
    -- Symmetric keys use time-based sessions and can't be opened inside user-defined
	-- functions usfEncrypt and usfDecrypt (below). So any calls to these user-defined  
	-- functions must be preceded by a call to this stored procedure.
	SET NOCOUNT ON

    OPEN SYMMETRIC KEY DiscHaven_SymmetricKey DECRYPTION BY CERTIFICATE DiscHaven_Certificate
END
GO


-- Function that encrypts the incoming plain-value parameter and returns the scrambled result...
CREATE FUNCTION usfEncrypt
(
	@pPlainValue	NVARCHAR(MAX)
)
	RETURNS VARBINARY(256)
AS
BEGIN
	RETURN EncryptByKey(Key_GUID('DiscHaven_SymmetricKey'), @pPlainValue)
END
GO


-- Function that decrypts the incoming scrambled-value parameter and returns its plain-value result...
CREATE FUNCTION usfDecrypt
(
	@pEncryptedValue	VARBINARY(256)
)
	RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN DecryptByKey(@pEncryptedValue)
END
GO

-------------------------------------------------------
--customer

--find out how to capture the error code using @@ERROR emmidiately after the statement
CREATE PROCEDURE uspAddCustomer
	@ID				BIGINT OUTPUT,
	@FirstName		NVARCHAR(250),
	@LastName		NVARCHAR(250),
	@Email			NVARCHAR(250),
	@Address		NVARCHAR(50),
	@City			NVARCHAR(250),
	@State			NVARCHAR(250),
	@PostCode		NVARCHAR(10),
	@ShipAddress	NVARCHAR(250),
	@ShipCity		NVARCHAR(250),
	@ShipState		NVARCHAR(250),
	@ShipPostCode	NVARCHAR(10),
	@Username		NVARCHAR(250),
	@Password		NVARCHAR(250),
	@PasswordHint	NVARCHAR(250),
	@ErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	DECLARE @Salt UNIQUEIDENTIFIER = NEWID() 

	SET NOCOUNT ON
	EXEC uspOpenKeys
	DECLARE @Hint VARBINARY(256)
	SELECT @Hint = dbo.usfEncrypt(@PasswordHint)

	DECLARE @TransStartLevel INT = @@TRANCOUNT;
	IF (@TransStartLevel > 0)
		SAVE TRANSACTION T_UpdatePerson
	ELSE
	BEGIN TRANSACTION T_UpdatePerson

	BEGIN TRY	
		INSERT INTO tblCustomer (FirstName, LastName, Email, [Address], City, [State], PostCode, ShipAddress, ShipCity, ShipState, ShipPostCode, Username, PasswordHash, PasswordHint, Salt)
		VALUES				(@FirstName, @LastName, @Email, @Address, @City, @State, @PostCode, @ShipAddress, @ShipCity, @ShipState, @ShipPostCode, @Username, HASHBYTES( 'SHA2_512', @Password + CAST(@Salt AS NVARCHAR(36))), @Hint, @Salt)

		SET @ID = SCOPE_IDENTITY()
		IF (@TransStartLevel = 0)
			COMMIT TRANSACTION	-- Commit only if the transaction began in this procedure
	END TRY
	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE(); 
		IF (@TransStartLevel = 0) OR (XACT_STATE() = 1)
			ROLLBACK TRANSACTION T_UpdatePerson
	END CATCH
END
GO

--performs an authentication check and selects
--very basic customer info including
--current shopping cart count has hard coded value for testing
CREATE PROCEDURE uspGetCustomer
	@Username		NVARCHAR(250),
	@Password		NVARCHAR(250)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ID BIGINT 
	SET @ID = (SELECT C.ID
    FROM tblCustomer C
    WHERE C.Username = @Username 
	AND C.PasswordHash = HASHBYTES( 'SHA2_512', @Password + CAST(Salt AS NVARCHAR(36))))

	DECLARE @Count BIGINT = (SELECT Count(*) FROM tblCart CT WHERE CT.FKCustomerID = @ID)

	SELECT C.ID, C.FirstName, C.LastName, C.Username, @Count AS CartCount
	FROM tblCustomer C
	WHERE C.ID = @ID

END
GO

--requires further implementation
CREATE PROCEDURE uspGetCustomerDto
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	EXEC uspOpenKeys
	SELECT C.ID, C.FirstName, C.LastName, C.Email, C.[Address], C.City, C.[State], C.PostCode, C.ShipAddress, C.ShipCity, C.ShipState, C.ShipPostCode, C.Username, dbo.usfDecrypt(C.PasswordHint) AS PasswordHint
    FROM tblCustomer C
    WHERE C.ID = @ID
END
GO

CREATE PROCEDURE uspUpdateForgottenPassword
	@ID				BIGINT OUTPUT,
	@Password		NVARCHAR(250),
	@ErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY

	UPDATE tblCustomer
	SET PasswordHash = HASHBYTES( 'SHA2_512', @Password + CAST(Salt AS NVARCHAR(36)))
	WHERE ID = @ID
			
	END TRY

	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

CREATE PROCEDURE uspGetPasswordHint
	@Username AS NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON
	EXEC uspOpenKeys

	SELECT dbo.usfDecrypt(C.PasswordHint) AS PasswordHint
	FROM tblCustomer C
	WHERE C.Username = @Username
END
GO

CREATE PROCEDURE uspUpdateCustomer
	@ID				BIGINT OUTPUT,
	@FirstName		NVARCHAR(250),
	@LastName		NVARCHAR(250),
	@Email			NVARCHAR(250),
	@Address		NVARCHAR(25),
	@City			NVARCHAR(250),
	@State			NVARCHAR(250),
	@PostCode		NVARCHAR(10),
	@ShipAddress	NVARCHAR(250),
	@ShipCity		NVARCHAR(250),
	@ShipState		NVARCHAR(250),
	@ShipPostCode	NVARCHAR(10),
	@Username		NVARCHAR(250),
	@Password		NVARCHAR(250) = '',
	@PasswordHint	NVARCHAR(250),
	@ErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	EXECUTE uspOpenKeys
	DECLARE @Hint VARBINARY(256)
	SELECT @Hint = dbo.usfEncrypt(@PasswordHint)

	DECLARE @TransStartLevel INT = @@TRANCOUNT;
	IF (@TransStartLevel > 0)
		SAVE TRANSACTION T_UpdatePerson
	ELSE
	BEGIN TRANSACTION T_UpdatePerson

	BEGIN TRY
		UPDATE tblCustomer
		SET
			FirstName =		@FirstName,
			LastName =		@LastName,
			Email =			@Email,
			[Address] =		@Address,
			City =			@City,
			[State] =		@State,
			PostCode =		@PostCode,
			ShipAddress =	@ShipAddress,
			ShipCity =		@ShipCity,
			ShipState =		@ShipState,
			ShipPostCode =	@ShipPostCode,
			Username =		@Username,
			PasswordHint =	@Hint
			WHERE ID =		@ID

			IF @Password != NULL OR @Password != ''
			BEGIN
				UPDATE tblCustomer
				SET PasswordHash = HASHBYTES( 'SHA2_512', @Password + CAST(Salt AS NVARCHAR(36)))
				WHERE ID = @ID
			END

		IF (@TransStartLevel = 0)
		COMMIT TRANSACTION	-- Commit only if the transaction began in this procedure
	END TRY

	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE();
		IF (@TransStartLevel = 0) OR (XACT_STATE() = 1)
			ROLLBACK TRANSACTION T_UpdatePerson
	END CATCH
END
GO

CREATE PROCEDURE uspDeleteCustomer
	@ID BIGINT OUTPUT,
	@ErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		DELETE tblCustomer
		WHERE ID = @ID

		SET @ErrorMessage = ''
	END TRY

	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

-------------------------------------------------------
--staff
CREATE PROCEDURE uspAddStaff
	@ID				BIGINT OUTPUT,
	@FKLocationID	BIGINT,
	@FirstName		NVARCHAR(250),
	@LastName		NVARCHAR(250),
	@Email			NVARCHAR(250),
	@Address		NVARCHAR(250),
	@City			NVARCHAR(250),
	@State			NVARCHAR(250),
	@PostCode		NVARCHAR(10),
	@DOB			NVARCHAR(250),
	@PhoneNumber	NVARCHAR(250),
	@Comments		NVARCHAR(250),
	@Image			NVARCHAR(250),
	@Username		NVARCHAR(250),
	@Password		NVARCHAR(250),
	@PasswordHint	NVARCHAR(250),
	@IsActive		BIT,
	@ErrorMessage	NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	EXECUTE uspOpenKeys
	DECLARE @Hint VARBINARY(256)
	SELECT @Hint = dbo.usfEncrypt(@PasswordHint)
	DECLARE @Salt UNIQUEIDENTIFIER = NEWID()	
	DECLARE @PasswordHash Binary(64) = HASHBYTES( 'SHA2_512', @Password + CAST(@Salt AS NVARCHAR(36)))

	BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO tblStaff(FKLocationID, FirstName, LastName, Email, [Address], City, [State], PostCode, DOB,PhoneNumber, Comments, [Image], Username, PasswordHash, PasswordHint, Salt, IsActive)
		VALUES			(@FKLocationID,@FirstName,@LastName,@Email,@Address,@City, @State, @PostCode, @DOB, @PhoneNumber, @Comments, @Image, @Username, @PasswordHash, @Hint, @Salt, @IsActive)

		SET @ID = CAST(SCOPE_IDENTITY() AS BIGINT)
		SET @ErrorMessage = ''
		
		COMMIT
	END TRY

	BEGIN CATCH
		ROLLBACK
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

--performs an authentication check and
--selects very basic staff information
CREATE PROCEDURE uspGetStaff
	@Username		NVARCHAR(250),
	@Password		NVARCHAR(250)
AS
BEGIN
	SET NOCOUNT ON
	SELECT S.ID, S.FirstName, S.LastName, S.Username, MAX(R.Ranking) AS [Role]
    FROM tblStaff S
	INNER JOIN tblStaffRole SR ON S.ID = SR.FKStaffID
	INNER JOIN tblRole R ON SR.FKRoleID = R.ID
    WHERE S.Username = @Username
	AND S.PasswordHash = HASHBYTES( 'SHA2_512', @Password + CAST(S.Salt AS NVARCHAR(36)))
	AND S.IsActive = 'TRUE'
	GROUP BY S.ID, S.FirstName, S.LastName, S.Username
END
GO

--requires further implementation
CREATE PROCEDURE uspGetStaffRecords
	@LocationID BIGINT,
	@RoleID BIGINT,
	@LastName NVARCHAR(250)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @sql NVARCHAR(MAX) = N'
	SELECT DISTINCT S.ID, S.FirstName, S.LastName, S.Username, S.Email, S.PhoneNumber AS Contact
    FROM tblStaff S
    INNER JOIN tblLocation L ON S.FKLocationID = L.ID
    LEFT OUTER JOIN tblStaffRole SR ON S.ID = SR.FKStaffID
    LEFT OUTER JOIN tblRole R ON SR.FKRoleID = R.ID
    WHERE 1 = 1 '

	IF @LocationID > 0
	SET @sql = @sql + ' AND L.ID = @LocationID '

	IF @RoleID > 0
	SET @sql = @sql + ' AND R.ID = @RoleID '

	IF LEN(ISNULL(@LastName, '')) > 0 
	BEGIN
		SET @LastName = '%' + @LastName + '%'
		SET @sql = @sql + ' AND S.LastName LIKE @LastName '
	END

	EXEC sp_executesql @sql, N'@LocationID BIGINT, @RoleID BIGINT, @LastName NVARCHAR(250)', @LocationID, @RoleID, @LastName
END
GO

CREATE PROCEDURE uspGetStaffRoles
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	SELECT R.ID, R.[Name], R.Ranking
    FROM tblRole R
    INNER JOIN tblStaffRole SR ON SR.FKRoleID = R.ID
    INNER JOIN tblStaff S ON S.ID = SR.FKStaffID
	WHERE S.ID = @ID
END
GO

--requires further implementation
CREATE PROCEDURE uspGetStaffDto
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	EXEC uspOpenKeys
	SELECT S.ID, S.FKLocationID, S.FirstName, S.LastName, S.Email, S.[Address], S.City, S.[State], S.PostCode, S.DOB, S.PhoneNumber, S.Comments, S.[Image], S.Username, dbo.usfDecrypt(S.PasswordHint) AS PasswordHint, S.IsActive
    FROM tblStaff S
    WHERE S.ID = @ID
END
GO

CREATE PROCEDURE uspUpdateStaff
	@ID				BIGINT,
	@FirstName		NVARCHAR(250),
	@LastName		NVARCHAR(250),
	@Email			NVARCHAR(250),
	@Address		NVARCHAR(25),
	@City			NVARCHAR(250),
	@State			NVARCHAR(250),
	@PostCode		NVARCHAR(10),
	@DOB			NVARCHAR(250),
	@PhoneNumber	NVARCHAR(250),
	@Comments		NVARCHAR(250),
	@Image			NVARCHAR(10),
	@Username		NVARCHAR(250),
	@Password		NVARCHAR(250),
	@PasswordHint	NVARCHAR(250),
	@IsActive		BIT,
	@ErrorMessage	NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	EXECUTE uspOpenKeys
	DECLARE @Hint VARBINARY(256)
	SELECT @Hint = dbo.usfEncrypt(@PasswordHint)
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE tblStaff
		SET
		FirstName =		@FirstName,
		LastName =		@LastName,
		Email =			@Email,
		[Address] =		@Address,
		City =			@City,
		[State] =		@State,
		PostCode =		@PostCode,
		DOB =			@DOB,
		PhoneNumber =	@PhoneNumber,
		Comments =		@Comments,
		[Image] =		@Image,
		Username =		@Username,
		PasswordHint =	@Hint,
		IsActive =		@IsActive
		WHERE ID =		@ID

		IF LEN(@Password) > 0
			UPDATE tblStaff
			SET
			PasswordHash = HASHBYTES( 'SHA2_512', @Password + CAST(Salt AS NVARCHAR(36)))
			WHERE ID = @ID

		SET @ErrorMessage = ''
		COMMIT
	END TRY

	BEGIN CATCH
		ROLLBACK
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE(); 
	END CATCH
END
GO

CREATE PROCEDURE uspStaffActivationStatus
	@ID BIGINT,
	@IsActive BIT,
	@ErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		UPDATE tblStaff
		SET IsActive = @IsActive
		WHERE ID = @ID
		SET @ErrorMessage = ''
	END TRY
	BEGIN CATCH
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

CREATE PROCEDURE uspAddStaffRole
	@ID				BIGINT OUTPUT,
	@StaffID		BIGINT,
	@RoleID			BIGINT,
	@ErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		INSERT INTO tblStaffRole (FKStaffID, FKRoleID)
		VALUES (@StaffID, @RoleID)	
		SET @ID = CAST(SCOPE_IDENTITY() AS BIGINT)		
	END TRY
	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

CREATE PROCEDURE uspRemoveStaffRole
	@ID			BIGINT,
	@RoleID		BIGINT
AS
BEGIN
	SET NOCOUNT ON
	DELETE
	FROM tblStaffRole
	WHERE FKStaffID = @ID AND FKRoleID = @RoleID		
END
GO

------------------------------------------------------------------------------------------------------------------
--products

--this procedure accepts the title by value, the category id as well as all other product data.
--first we check if there is a matching entry in tblTitle by checking the title and categry values:
--if it exist - we use the id stored in this record, if it does not - we create a new record in tblTitle.
--i suspect we will use a transaction here to ensure the state of the tables if an error occurs  
CREATE PROCEDURE uspCreateProduct
	@ID					BIGINT OUTPUT,
	@FKTitleID			BIGINT,
	@FKMediaTypeID		BIGINT,
	@Name				NVARCHAR(250),
	@Description		NVARCHAR(MAX),
	@RRP				SMALLMONEY,
	@DiscountFactor		FLOAT,
	@RelDate			DATETIME,
	@IsActive			BIT,
	@Image				VARCHAR(250),
	@ErrorMessage		NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @DateDeact DATETIME

			IF @IsActive = 0
				SET @DateDeact = GETDATE();
			ELSE
				SET @DateDeact = null

			--perform an insert into the product table
			INSERT INTO tblProduct (FKTitleID, FKMediaTypeID, [Name], [Description], RRP, DiscountFactor, RelDate, IsActive, [Image], DateDeactivated)
			VALUES (@FKTitleID , @FKMediaTypeID, @Name, @Description, @RRP, @DiscountFactor, @RelDate, @IsActive, @Image, @DateDeact);

			SET @ID = SCOPE_IDENTITY()
		
			INSERT INTO tblLocationStock(FKLocationID, FKProductID, Quantity)
			SELECT tblLocation.ID, @ID, 0
			FROM tblLocation

			SET @ErrorMessage = ''
		COMMIT
	END TRY
	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE();
		ROLLBACK
	END CATCH
END
GO

CREATE PROCEDURE uspUpdateProduct
	@ID					BIGINT OUTPUT,
	@FKTitleID			BIGINT,
	@FKMediaTypeID		BIGINT,
	@Name				NVARCHAR(250),
	@Description		NVARCHAR(MAX),
	@RRP				SMALLMONEY,
	@DiscountFactor		FLOAT,
	@RelDate			DATETIME,
	@IsActive			BIT,
	@Image				VARCHAR(250),	
	@ErrorMessage		NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @DateDeact DATETIME
	IF @IsActive = 0 AND (SELECT IsActive FROM tblProduct WHERE ID = @ID) = 1
		SET @DateDeact = GETDATE()
	ELSE IF @IsActive = 0
		SET @DateDeact = (SELECT DateDeactivated FROM tblProduct WHERE ID = @ID)
	ELSE
		SET @DateDeact = null
	
	BEGIN TRY
		BEGIN TRANSACTION
		UPDATE tblProduct
		SET
		FKTitleID = @FKTitleID,
		FKMediaTypeID = @FKMediaTypeID,
		[Name] = @Name,
		[Description] = @Description,
		RRP = @RRP,
		DiscountFactor = @DiscountFactor,
		RelDate = @RelDate,
		IsActive = @IsActive,
		[Image] = @Image
		--[DateDeactivated] = @DateDeact
		WHERE ID = @ID

		IF @IsActive = 0 AND (SELECT IsActive FROM tblProduct WHERE ID = @ID) = 1
		BEGIN
		UPDATE tblProduct
		SET DateDeactivated = GETDATE()
		END
		ELSE IF @IsActive = 1
		BEGIN
		UPDATE tblProduct
		SET DateDeactivated = null
		END

		SET @ErrorMessage = ''
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		SET @ID = 0;
		SET @ErrorMessage = ERROR_MESSAGE(); 
	END CATCH
END
GO

--get products matching search criteria and IsActive = true
--implementation is incomplete
CREATE PROCEDURE uspGetActiveProducts
	@MediaTypeID BIGINT,
	@CategoryID BIGINT,
	@SearchValue NVARCHAR(50),
	@RequestedPage INT OUTPUT,
	@TotalPages	INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	--Lookup the number of items per page from the configuration table.
	DECLARE @MaxItemsPerPage INT;

	SELECT @MaxItemsPerPage = NumPageItemsToDisplay
    FROM tblConfiguration
    WHERE ID = (SELECT MAX(ID) FROM tblConfiguration)

	-- Capture the total count of rows that meet the query (i.e. before pagination is applied)
	DECLARE @TotalRows INT;

	--===========================================================================================================
	DECLARE @select NVARCHAR (MAX) = 'SELECT @RowCount = COUNT(*)
									  FROM tblProduct P
									  INNER JOIN tblTitle T ON P.FKTitleID = T.ID '
									  
	DECLARE @where NVARCHAR(150) = ' WHERE P.IsActive = 1 '

	IF @MediaTypeID > 0
		SET @where += ' AND P.FKMediaTypeID = @MediaTypeID ';
	IF @CategoryID > 0 
		SET @where += ' AND T.FKCategoryID = @CategoryID ';
	IF LEN(ISNULL(@SearchValue, '')) > 0 
	BEGIN
		SET @where += ' AND T.[Name] LIKE @SearchValue OR P.[Name] LIKE @SearchValue '
		SET @SearchValue = '%' + @SearchValue + '%'
	END

	SET @select += @where

	DECLARE @ParamDefinition NVARCHAR(MAX) = ' @MediaTypeID BIGINT, @CategoryID BIGINT, @SearchValue NVARCHAR(50), @RowCount INT OUTPUT '

	EXECUTE sp_executesql @select, @ParamDefinition, @MediaTypeID, @CategoryID, @SearchValue, @RowCount = @TotalRows OUTPUT

	--===========================================================================================================

	-- Calculate the total number of pages
	-- Must round UP to the next highest integer to calculate total pages,
	-- to cater for the remainder of the following division operation...
	SET @TotalPages = CEILING( CAST(@TotalRows AS FLOAT) / @MaxItemsPerPage );

	-- The requested page number may not be valid, so test its bounds...
	IF (@RequestedPage < 1)
		SET @RequestedPage = 1
	ELSE IF (@RequestedPage > @TotalPages)
		SET @RequestedPage = @TotalPages

	-- Declare a variable to act as the starting row (Note: zero-based)...
	DECLARE @StartingRowNumber INT = ((@RequestedPage - 1) * @MaxItemsPerPage)

	IF (@StartingRowNumber < 0)
		SET @StartingRowNumber = 0;
	
	--===========================================================================================================

	/*
	here we use dynamic sql to perform a search on the product table
	the criteria passed as params will need to be checked for value 
	to determine if the search will include it is part of the query
	the built in sp_executesql procedure is use to the the sql string
	*/

	DECLARE @sql AS NVARCHAR(MAX) = 'SELECT P.ID, T.[Name] AS Title, P.[Name] AS Name, P.[Description], C.[Description] AS Category, M.[Description] AS [MediaType], P.RRP, P.Discount, P.DiscountFactor, P.Price, P.[Image]
									 FROM tblProduct P
									 INNER JOIN tblTitle T ON P.FKTitleID = T.ID
									 INNER JOIN tblCategory C ON T.FKCategoryID = C.ID
									 INNER JOIN tblMediaType M ON P.FKMediaTypeID = M.ID ' + @where;


	SET @sql += ' ORDER BY 
				  T.FKCategoryID ASC, 
				  P.FKMediaTypeID ASC
				  OFFSET @StartingRowNumber ROWS 
				  FETCH NEXT @MaxItemsPerPage ROWS ONLY '

	SET @ParamDefinition = ' @MediaTypeID BIGINT, @CategoryID BIGINT, @SearchValue NVARCHAR(100), @StartingRowNumber INT, @MaxItemsPerPage INT '

	EXECUTE sp_executesql @sql, @ParamDefinition, @MediaTypeID, @CategoryID, @SearchValue, @StartingRowNumber, @MaxItemsPerPage
END
GO

CREATE PROCEDURE uspGetProducts
	@MediaTypeID BIGINT,
	@CategoryID BIGINT,
	@SearchValue NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON
	/*
	here we use dynamic sql to perform a search on the product table
	the criteria passed as params will need to be checked for value 
	to determine if the search will include it is part of the query
	the built in sp_executesql procedure is use to the the sql string
	*/
	DECLARE @ParamDefinition NVARCHAR(100) = ' @MediaTypeID BIGINT, @CategoryID BIGINT, @SearchValue NVARCHAR(50) '
	DECLARE @sql AS NVARCHAR(max) = N'SELECT P.ID,  M.[Description] AS [MediaType], C.[Description] AS Category, T.[Name] AS Title, P.[Name], P.[Description], P.RRP, P.DiscountFactor, P.RelDate, P.[Image]
									 FROM tblProduct P
									 INNER JOIN tblTitle T ON P.FKTitleID = T.ID
									 INNER JOIN tblCategory C ON T.FKCategoryID = C.ID
									 INNER JOIN tblMediaType M ON P.FKMediaTypeID = M.ID
									 WHERE 1 = 1';

	IF @MediaTypeID > 0 
		SET @sql = @sql + ' AND P.FKMediaTypeID = @MediaTypeID ';
	IF @CategoryID > 0 
		SET @sql = @sql + ' AND T.FKCategoryID = @CategoryID ';
	IF LEN(ISNULL(@SearchValue, '')) > 0 
	BEGIN
		SET @sql = @sql + ' AND T.[Name] LIKE @SearchValue OR P.[Name] LIKE @SearchValue ';
		SET @SearchValue = '%' + @SearchValue + '%'
	END

	EXEC sp_executesql @sql, @ParamDefinition, @MediaTypeID, @CategoryID, @SearchValue
END
GO

--get product by id and IsActive = true
CREATE PROCEDURE uspGetProduct
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	SELECT P.ID, M.[Description] AS [MediaType], C.[Description] AS Category, T.[Name] AS Title, P.[Name], P.[Description], P.RRP, P.DiscountFactor, P.RelDate, P.[Image]
    FROM tblProduct P
    INNER JOIN tblTitle T ON P.FKTitleID = T.ID
    INNER JOIN tblCategory C ON T.FKCategoryID = C.ID
    INNER JOIN tblMediaType M ON P.FKMediaTypeID = M.ID
    WHERE P.ID = @ID 
END
GO

CREATE PROCEDURE uspGetProductQuantities
	@LocationID BIGINT,
	@MediaTypeID BIGINT,
	@CategoryID BIGINT,
	@SearchValue NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ParamDefinition NVARCHAR(100) = ' @LocationID BIGINT, @MediaTypeID BIGINT, @CategoryID BIGINT, @SearchValue NVARCHAR(50) '
	DECLARE @sql AS NVARCHAR(max) = N'SELECT P.ID, LS.FKLocationID, L.City, M.[Description] AS [MediaType], C.[Description] AS Category, T.[Name] AS Title, P.[Name], LS.Quantity
									 FROM tblProduct P
									 INNER JOIN tblTitle T ON P.FKTitleID = T.ID
									 INNER JOIN tblCategory C ON T.FKCategoryID = C.ID
									 INNER JOIN tblMediaType M ON P.FKMediaTypeID = M.ID
									 INNER JOIN tblLocationStock LS ON P.ID = LS.FKProductID
									 INNER JOIN tblLocation L ON LS.FKLocationID = L.ID
									 WHERE 1 = 1';

	IF @LocationID > 0
		SET @sql = @sql + ' AND L.ID = @LocationID '
	IF @MediaTypeID > 0 
		SET @sql = @sql + ' AND P.FKMediaTypeID = @MediaTypeID ';
	IF @CategoryID > 0 
		SET @sql = @sql + ' AND T.FKCategoryID = @CategoryID ';
	IF LEN(ISNULL(@SearchValue, '')) > 0 
	BEGIN
		SET @sql = @sql + ' AND T.[Name] LIKE @SearchValue OR P.[Name] LIKE @SearchValue ';
		SET @SearchValue = '%' + @SearchValue + '%'
	END

	EXEC sp_executesql @sql, @ParamDefinition, @LocationID, @MediaTypeID, @CategoryID, @SearchValue
END
GO
--get product by id and IsActive = true
CREATE PROCEDURE uspGetActiveProduct
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	SELECT P.ID, M.[Description] AS [MediaType], C.[Description] AS Category, T.[Name] AS Title, P.[Name], P.[Description], P.RRP, P.DiscountFactor, P.RelDate, P.[Image]
    FROM tblProduct P
    INNER JOIN tblTitle T ON P.FKTitleID = T.ID
    INNER JOIN tblCategory C ON T.FKCategoryID = C.ID
    INNER JOIN tblMediaType M ON P.FKMediaTypeID = M.ID
    WHERE P.ID = @ID 
    AND P.IsActive = 'TRUE'
END
GO

--get productdto by id 
CREATE PROCEDURE uspGetProductDto
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	SELECT P.ID, P.FKTitleID, P.FKMediaTypeID, P.[Name], P.[Description], P.RRP, P.DiscountFactor, P.RelDate, P.DateDeactivated, P.[Image], P.IsActive
    FROM tblProduct P
    WHERE P.ID = @ID 
END
GO

--update a products active status
CREATE PROCEDURE uspUpdateProductStatus
	@ID			BIGINT,
	@IsActive	Bit
AS
BEGIN
	SET NOCOUNT ON
	UPDATE tblProduct
	SET
	IsActive = @IsActive
	WHERE ID = @ID
END
GO

CREATE PROCEDURE uspGetTitle
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	SELECT T.ID, T.FKCategoryID, T.[Name], T.[Description]
    FROM tblTitle T
	WHERE T.ID = @ID
END
GO

CREATE PROCEDURE uspCreateTitle
	@ID				BIGINT OUTPUT,
	@FKCategoryID	BIGINT,
	@Description	NVARCHAR(MAX),
	@Name			NVARCHAR(50),
	@ErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		INSERT INTO tblTitle (FkCategoryID, [Name], [Description])
		VALUES (@FKCategoryID, @Name, @Description)

		SET @ID = CAST(SCOPE_IDENTITY() AS BIGINT);
	END TRY
	BEGIN CATCH
		SET @ID = 0;
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

CREATE PROCEDURE uspUpdateTitle
	@ID				BIGINT OUTPUT,
	@FKCategoryID	BIGINT,
	@Description	NVARCHAR(MAX),
	@Name			NVARCHAR(50),
	@ErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		UPDATE tblTitle 
		SET
		FkCategoryID = @FKCategoryID,
		[Name] = @Name, 
		[Description] = @Description
		WHERE ID = @ID
	END TRY
	BEGIN CATCH
		SET @ID = 0;
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

--get title names and IDs
CREATE PROCEDURE uspGetTitles
	@CategoryID		BIGINT,
	@SearchValue	NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @sql NVARCHAR(MAX) = N'
	SELECT T.ID, T.[Name], T.[Description], C.[Description] AS Category
    FROM tblTitle T
	INNER JOIN tblCategory C ON T.FKCategoryID = C.ID
	WHERE 1 = 1'

	IF @CategoryID > 0
	SET @sql = @sql + ' AND C.ID = @CategoryID '

	IF LEN(ISNULL(@SearchValue, '')) > 0
	BEGIN
		SET @sql = @sql + ' AND T.[Name] LIKE @SearchValue '
		SET @SearchValue = '%' + @SearchValue + '%'
	END
	EXEC sp_executesql @sql, N' @CategoryID BIGINT, @SearchValue NVARCHAR(50) ', @CategoryID, @SearchValue
END
GO

CREATE PROCEDURE uspGetTitleDtos
	@CategoryID		BIGINT,
	@SearchValue	NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @sql NVARCHAR(MAX) = N'
	SELECT T.ID, T.FKCategoryID, T.[Name], T.[Description]
    FROM tblTitle T
	INNER JOIN tblCategory C ON T.FKCategoryID = C.ID
	WHERE 1 = 1'

	IF @CategoryID > 0
	SET @sql = @sql + ' AND C.ID = @CategoryID '

	IF LEN(ISNULL(@SearchValue, '')) > 0
	BEGIN
		SET @sql = @sql + ' AND T.[Name] LIKE @SearchValue '
		SET @SearchValue = '%' + @SearchValue + '%'
	END
	EXEC sp_executesql @sql, N' @CategoryID BIGINT, @SearchValue NVARCHAR(50) ', @CategoryID, @SearchValue
END
GO

------------------------------------------------------------------------------------------------------------------
--orders


--the check out procedure performs a number of transaction based operations affecting multiple tables
CREATE PROCEDURE uspCheckOut
	@ID				 BIGINT OUTPUT, --the id of the newly created order
	@CustomerID		 BIGINT,
	@LocationID		 BIGINT,
	--@PaymentOptionID BIGINT = 0,
	@ErrorMessage	 NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		IF (SELECT count(ID) FROM tblCart WHERE FKCustomerID = @CustomerID) = 0
		BEGIN
			SET @ID = 0
			SET @ErrorMessage = 'There are no records in tblCart to match @CustomerID parameter, no checkout was performed.'
			RETURN -1
		END

		BEGIN TRANSACTION
		DECLARE @gstfactor FLOAT = (SELECT tblConfiguration.GSTFactor
									FROM tblConfiguration
									WHERE ID = (SELECT MAX(ID) FROM tblConfiguration))

		--create an order for the customer
		INSERT INTO tblOrder(FKCustomerID, FKLocationID, FKStatusID, [DateTime], GST, UseShippingAddress)
		VALUES				(@CustomerID, @LocationID, 1, GETDATE(), @gstfactor, 1)

		--store the order id
		SET @ID = SCOPE_IDENTITY()

		--batch insert into the orderline table select values from the cart table matching customer id
		INSERT INTO tblOrderLine(FKOrderID, FKProductID, [Name], Quantity, ItemPrice)
		SELECT @ID, P.ID, P.[Name], C.Quantity, P.Price
		FROM tblProduct P
		INNER JOIN tblCart C ON C.FKProductID = P.ID
		WHERE C.FKCustomerID = @CustomerID

		UPDATE LS 
		SET 
			LS.Quantity = LS.Quantity - C.Quantity
		FROM
			tblLocationStock LS INNER JOIN
			tblCart C ON LS.FKProductID = C.FKProductID
		WHERE
			LS.FKLocationID = @LocationID
			AND C.FKCustomerID = @CustomerID

		--delete cart contents matching customer id
		DELETE FROM tblCart
		WHERE FKCustomerID = @CustomerID

		--UPDATE LS 
		--SET 
		--	LS.Quantity = LS.Quantity - OL.Quantity
		--FROM
		--	tblLocationStock LS
		--	INNER JOIN tblOrderLine OL ON LS.FKProductID = OL.FKProductID
		--WHERE
		--	LS.FKLocationID = @LocationID
		--	AND OL.FKOrderID = @ID

		COMMIT 
	END TRY
	BEGIN CATCH
		ROLLBACK
		SET @ID = 0;
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

CREATE PROC uspUpdateLocationStock
	@FKLocation BIGINT,
	@FKProduct  BIGINT,
	@Quantity	INTEGER
AS
BEGIN
	UPDATE tblLocationStock
	SET
	Quantity = Quantity - @Quantity
	WHERE FKLocationID = @FKLocation
	AND FKProductID = @FKProduct
END
GO

CREATE PROCEDURE uspGetOrderSummary
	@ID BIGINT = 0,
	@CustomerID BIGINT = 0
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @sql NVARCHAR(MAX) = N' 
	SELECT O.ID, O.FKCustomerID, L.City AS [Location], OS.StatusCode, O.[DateTime] AS [Date], O.GST AS GstFactor, O.UseShippingAddress, 
		(SELECT SUM(LineTotal) FROM tblOrderLine OL WHERE OL.FKOrderID = O.ID) AS Total, 
		(SELECT COUNT(ID) FROM tblOrderLine OL WHERE OL.FKOrderID = O.ID) AS ItemCount
	FROM tblOrder O
	INNER JOIN tblLocation L ON O.FKLocationID = L.ID
	INNER JOIN tblOrderStatus OS ON O.FKStatusID = OS.ID
	WHERE 1 = 1 '
	
	IF @ID > 0
		SET @sql = @sql + ' AND O.ID = @ID '

	ELSE IF @CustomerID > 0
		SET @sql = @sql + ' AND O.FKCustomerID = @CustomerID '

	EXEC sp_executesql @sql, N' @ID BIGINT, @CustomerID BIGINT ', @ID, @CustomerID	
END
GO

CREATE PROCEDURE uspGetOrderLineItems
	@ID BIGINT,
	@CustomerID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	SELECT OL.ID, OL.FKProductID, OL.[Name], OL.Quantity, OL.ItemPrice
	FROM tblOrderLine OL
	INNER JOIN tblOrder O ON OL.FKorderID = O.ID
	WHERE OL.FKOrderID = @ID
	AND O.FKCustomerID = @CustomerID
END
GO

--return multiple result sets which represent an order summary and its line items
CREATE PROCEDURE uspGetOrderDetails
	@ID BIGINT,
	@CustomerID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	EXEC uspGetOrderSummary @ID, @CustomerID
	EXEC uspGetOrderLineItems @ID, @CustomerID
END
GO

------------------------------------------------------------------------------------------------------------------
--reports
CREATE PROCEDURE uspGetStockReport
	@LocationID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	SELECT P.ID,  M.[Description] AS [MediaType], C.[Description] AS Category, T.[Name] AS Title, P.[Name], P.[Description], P.RRP, P.DiscountFactor, P.RelDate, P.[Image], LS.Quantity
	FROM tblProduct P
	INNER JOIN tblTitle T ON P.FKTitleID = T.ID
	INNER JOIN tblCategory C ON T.FKCategoryID = C.ID
	INNER JOIN tblMediaType M ON P.FKMediaTypeID = M.ID
	INNER JOIN tblLocationStock LS ON LS.FKProductID = P.ID
	WHERE LS.ID = @LocationID
	--GROUP BY C.ID
END
GO

------------------------------------------------------------------------------------------------------------------
--shopping cart and orders

CREATE PROCEDURE uspGetCartItems
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	SELECT C.ID, C.FKProductID, P.[Name], C.Quantity, P.Price AS ItemPrice, C.DateAdded
	FROM tblCart C
	INNER JOIN tblProduct P ON P.ID = C.FKProductID
	WHERE C.FKCustomerID = @ID
END
GO

CREATE PROCEDURE uspGetCartCount
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON
	SELECT Sum(C.Quantity) AS CartCount
	FROM tblCart C
	WHERE C.FKCustomerID = @ID
END
GO

CREATE PROCEDURE uspAddToCart
	@ID				BIGINT OUTPUT,
	@ProductID		BIGINT,
	@CustomerID		BIGINT,
	@Quantity		INTEGER,
	@ErrorMessage	NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		SET @ID = (SELECT C.ID FROM tblCart C WHERE C.FKCustomerID = @CustomerID AND C.FKProductID = @ProductID)

		IF @ID IS NULL
			BEGIN
				INSERT INTO tblCart (FKCustomerID, FKProductID, Quantity, DateAdded)
				VALUES				(@CustomerID, @ProductID, @Quantity, GetDate())
				SET @ID = SCOPE_IDENTITY();
			END
		ELSE
			BEGIN
				UPDATE tblCart 
				SET Quantity = Quantity + @Quantity
				WHERE
					ID = @ID
			END
		SET @ErrorMessage = '';
	END TRY
	BEGIN CATCH
		SET @ID = 0;
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

--where the parameter ID is the cart record ID
--confirm this approach
CREATE PROCEDURE uspRemoveCartItem
	@ID		BIGINT,
	@CustomerID BIGINT
AS
BEGIN
	SET NOCOUNT OFF
	DELETE tblCart
	WHERE ID = @ID
	AND FKCustomerID = @CustomerID

	RETURN @@ROWCOUNT
END
GO

--updates an existing cart items quantity,
--we will need to check if @Quantity param
--is >= 1 else we will remove the item
CREATE PROCEDURE uspUpdateCart
	@ID				BIGINT = 0 OUTPUT,
	@ProductID		BIGINT,
	@CustomerID		BIGINT,
	@Quantity		INTEGER,
	@ErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY

		IF @ID > 0
		BEGIN
			UPDATE tblCart
			SET
			Quantity = @Quantity
			WHERE ID = @id AND FKCustomerID = @CustomerID
		END
		ELSE
			BEGIN
				SET @ID = (SELECT C.ID FROM tblCart C WHERE C.FKCustomerID = @CustomerID AND C.FKProductID = @ProductID)

				IF @ID IS NULL
					BEGIN
						INSERT INTO tblCart (FKCustomerID, FKProductID, Quantity, DateAdded)
						VALUES				(@CustomerID, @ProductID, @Quantity, GetDate())
						SET @ID = SCOPE_IDENTITY();
					END
				ELSE
					BEGIN
						UPDATE tblCart 
						SET Quantity = Quantity + @Quantity
						WHERE ID = @ID
					END
				SET @ErrorMessage = ''
			END
	END TRY
	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

--updates an existing cart items quantity,
--we will need to check if @Quantity param
--is >= 1 else we will remove the item
CREATE PROCEDURE uspUpdateCartItemQty
	@ProductID		BIGINT,
	@CustomerID		BIGINT,
	@Quantity		INTEGER,
	@ErrorMessage	NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		UPDATE tblCart
		SET
		Quantity = @Quantity
		WHERE tblCart.FKProductID = @ProductID
		AND tblCart.FKCustomerID = @CustomerID
		SET @ErrorMessage = '';
	END TRY
	BEGIN CATCH
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

------------------------------------------------------------------------------------------------------------------
--configuration and miscellaneous

CREATE PROCEDURE uspAddLocation
	@ID				BIGINT OUTPUT,
	@Description	NVARCHAR(MAX),
	@Address		NVARCHAR(250),
	@PhoneNumber	NVARCHAR(250),
	@Email			NVARCHAR(250),
	@City			NVARCHAR(250),
	@State			NVARCHAR(250),
	@ErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		SET NOCOUNT ON

		INSERT INTO tblLocation ([Description], [Address], PhoneNumber, Email, City, [State])
		VALUES					(@Description, @Address, @PhoneNumber, @Email, @City, @State)

		SET @ID = CAST(SCOPE_IDENTITY() AS BIGINT);

		INSERT INTO tblLocationStock(FKLocationID, FKProductID, Quantity)
		SELECT @ID, ID, 0
		FROM tblProduct

		COMMIT
	END TRY
	BEGIN CATCH
		SET @ID = 0;
		SET @ErrorMessage = ERROR_MESSAGE();
		ROLLBACK
	END CATCH
END
GO

CREATE PROCEDURE uspAddSecurityQA
	@ID BIGINT OUTPUT,
	@CustomerID BIGINT,
	@Question NVARCHAR(MAX),
	@Answer NVARCHAR(250),
	@ErrorMessage NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	-- Before calling the encryption stored function (in the INSERT below),
	-- we MUST call our custom-defined stored procedure uspOpenKeys...
	DECLARE @EncryptQ VARBINARY(256)
	EXECUTE uspOpenKeys	
	SELECT @EncryptQ = dbo.usfEncrypt(@Question)
	DECLARE @Salt UNIQUEIDENTIFIER;
	DECLARE @HashA BINARY(256)

	DECLARE @TransStartLevel INT = @@TRANCOUNT;
	IF (@TransStartLevel > 0)
		SAVE TRANSACTION T_UpdatePerson
	ELSE
		BEGIN TRANSACTION T_UpdatePerson

	BEGIN TRY
		SET @Salt = NEWID();
		SET @HashA = HASHBYTES( 'SHA2_512', @Answer + CAST(@Salt AS NVARCHAR(36)))
		INSERT INTO tblSecurityQuestion(FKCustomerID, Question, Answer, AnswerSalt)
		VALUES(@CustomerID, @EncryptQ, @HashA, @Salt)

		SET @ID = SCOPE_IDENTITY()
		IF (@TransStartLevel = 0)
			COMMIT TRANSACTION	-- Commit only if the transaction began in this procedure
	END TRY
	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE();
		IF (@TransStartLevel = 0) OR (XACT_STATE() = 1)
			ROLLBACK TRANSACTION T_UpdatePerson
	END CATCH
END
GO

CREATE PROCEDURE uspUpdateSecurityQA
	@ID BIGINT OUTPUT,
	@Question NVARCHAR(MAX),
	@Answer NVARCHAR(250),
	@ErrorMessage NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	-- Before calling the encryption stored function (in the INSERT below),
	-- we MUST call our custom-defined stored procedure uspOpenKeys...
	DECLARE @EncryptQ VARBINARY(256)
	EXECUTE uspOpenKeys	
	SELECT @EncryptQ = dbo.usfEncrypt(@Question)
	DECLARE @Salt UNIQUEIDENTIFIER;
	DECLARE @HashA BINARY(256)

	DECLARE @TransStartLevel INT = @@TRANCOUNT;
	IF (@TransStartLevel > 0)
		SAVE TRANSACTION T_UpdatePerson
	ELSE
		BEGIN TRANSACTION T_UpdatePerson

	BEGIN TRY
		UPDATE tblSecurityQuestion
		SET
		Question = @EncryptQ
		WHERE ID = @ID

		IF LEN(ISNULL(@Answer, '')) > 0
		BEGIN
			SELECT @Salt = (SELECT AnswerSalt FROM tblSecurityQuestion WHERE ID = @ID);
			SET @HashA = HASHBYTES( 'SHA2_512', @Answer + CAST(@Salt AS NVARCHAR(36)))
			UPDATE tblSecurityQuestion
			SET
			Answer = @HashA
			WHERE ID = @ID
		END

		IF (@TransStartLevel = 0)
			COMMIT TRANSACTION	-- Commit only if the transaction began in this procedure
	END TRY
	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE();
		IF (@TransStartLevel = 0) OR (XACT_STATE() = 1)
			ROLLBACK TRANSACTION T_UpdatePerson
	END CATCH
END
GO

CREATE PROCEDURE uspGetChallengeQuestions
	@Username NVARCHAR(100)
AS
BEGIN
	EXECUTE uspOpenKeys
	SELECT TOP 2 sq.ID, dbo.usfDecrypt(sq.Question) AS Question
	FROM tblSecurityQuestion sq
	INNER JOIN tblCustomer C ON sq.FKCustomerID = C.ID
	WHERE C.Username = @Username
	ORDER BY NEWID()
END
GO

CREATE PROCEDURE uspCheckChallengeAnswer
	@ID BIGINT,
	@Username NVARCHAR(100),
	@Answer NVARCHAR(250)
AS
BEGIN
	SET NOCOUNT ON
	EXECUTE uspOpenKeys	
	SET @ID = 
	(SELECT C.ID FROM tblCustomer C
	INNER JOIN tblSecurityQuestion SQ ON C.ID = SQ.FKCustomerID
	WHERE SQ.ID = @ID AND Answer = HASHBYTES( 'SHA2_512', @Answer + CAST(AnswerSalt AS NVARCHAR(36)))
	AND C.Username = @Username)

	--customersID
	SELECT @ID
END
GO

CREATE PROCEDURE uspGetSecurityQAs
	@FKCustomerID BIGINT = 0
AS
BEGIN
	EXECUTE uspOpenKeys
	SELECT sq.ID, dbo.usfDecrypt(sq.Question) AS Question
	FROM tblSecurityQuestion sq
	WHERE FKCustomerID = @FKCustomerID
END
GO

CREATE PROCEDURE uspUpdateProductStock
	@ID			BIGINT OUTPUT,
	@ProductID  BIGINT,
	@LocationID BIGINT,
	@Quantity	INTEGER,
	@ErrorMessage NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		UPDATE tblLocationStock
		SET
		Quantity = @Quantity,
		@ID = ID
		WHERE FKProductID = @ProductID AND FKLocationID = @LocationID
	END TRY
	BEGIN CATCH
		SET @ID = 0
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

CREATE PROCEDURE uspGetSlideInterval
AS
BEGIN
	SET NOCOUNT ON
	SELECT (SlideShowDelaySec)
	FROM tblConfiguration
	WHERE ID = (SELECT MAX(ID) FROM tblConfiguration)
END
GO

CREATE PROCEDURE uspGetPaginationLimit
AS
BEGIN
	SET NOCOUNT ON
	SELECT NumPageItemsToDisplay
    FROM tblConfiguration
    WHERE ID = (SELECT MAX(ID) FROM tblConfiguration)
END
GO

CREATE PROCEDURE uspGetGSTFactor
AS
BEGIN
	SET NOCOUNT ON
	SELECT tblConfiguration.GSTFactor
    FROM tblConfiguration
    WHERE ID = (SELECT MAX(ID) FROM tblConfiguration)
END
GO

CREATE PROCEDURE uspGetConfigSettings
AS
BEGIN
	SET NOCOUNT ON
	SELECT C.GST, C.NumPageItemsToDisplay, C.SlideShowDelaySec
    FROM tblConfiguration C
    WHERE ID = (SELECT MAX(ID) FROM tblConfiguration)
END
GO

CREATE PROCEDURE uspInsertConfigSettings
	@ID						BIGINT OUTPUT,
	@NumPageItemsToDisplay	INT,
	@SlideShowDelaySec		FLOAT,
	@GST					FLOAT,
	@ErrorMessage			NVARCHAR(MAX) OUTPUT
AS
BEGIN	
	SET NOCOUNT ON
	BEGIN TRY
		INSERT INTO tblConfiguration (GST, NumPageItemsToDisplay, SlideShowDelaySec)
		VALUES ( @GST, @NumPageItemsToDisplay, @SlideShowDelaySec)

		SET @ID = CAST(SCOPE_IDENTITY() AS BIGINT)
		SET @ErrorMessage = '';
	END TRY
	BEGIN CATCH
		SET @ID = 0;
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

CREATE PROCEDURE uspGetCategories
AS
BEGIN
	SET NOCOUNT ON
	SELECT ID, [Description] AS [Value]
    FROM tblCategory
END
GO

CREATE PROCEDURE uspGetMediaTypes
AS
BEGIN
	SET NOCOUNT ON
	SELECT ID, [Description] AS [Value]
    FROM tblMediaType
END
GO

CREATE PROCEDURE uspGetLocations
AS
BEGIN
	SET NOCOUNT ON
	SELECT ID, [City]
    FROM tblLocation
END
GO

CREATE PROCEDURE uspGetRoles
AS
BEGIN
	SET NOCOUNT ON
	SELECT ID, [Ranking], [Name]
    FROM tblRole
END
GO

CREATE PROCEDURE uspGetSearchValues
	@CustomerID BIGINT
AS
BEGIN
	SELECT TOP 10 [Description]
	FROM tblSearch 
	WHERE FKCustomerID = @CustomerID
	ORDER BY [DateTime] DESC
END
GO

CREATE PROCEDURE uspAddSearchValue
	@ID BIGINT = 0 OUTPUT,
	@CustomerID BIGINT,
	@SearchValue NVARCHAR(100),
	@ErrorMessage NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	BEGIN TRY
	INSERT INTO tblSearch (FKCustomerID, [DateTime], [Description])
	VALUES (@CustomerID, GETDATE(), @SearchValue)

	SET @ID = SCOPE_IDENTITY()
	END TRY
		BEGIN CATCH
		SET @ID = 0;
		SET @ErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

use master;
-------------------------------------------------------