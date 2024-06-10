USE BOOKSTORE;


CREATE TABLE ADDRESS(
AddressId INT PRIMARY KEY IDENTITY(1,1),
UserId INT FOREIGN KEY REFERENCES Users(UserId),
FullName VARCHAR(50),
Mobile VARCHAR(15),
Address VARCHAR(MAX),
City VARCHAR(50),
State VARCHAR(50),
Type VARCHAR(15));

SELECT * FROM ADDRESS;

--CREATE

CREATE OR ALTER PROCEDURE AddAddress
    @UserId INT,
    @FullName VARCHAR(50),
    @Mobile VARCHAR(15),
    @Address VARCHAR(MAX),
    @City VARCHAR(50),
    @State VARCHAR(50),
    @Type VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

     IF @UserId IS NULL OR 
	 @FullName IS NULL OR 
	 @Mobile IS NULL OR 
	 @Address IS NULL OR 
	 @City IS NULL OR 
	 @State IS NULL OR 
	 @Type IS NULL
    BEGIN
        THROW 50001, 'All parameters are required', 1;
        RETURN;
    END

    -- Validate Mobile number length
     IF LEN(@Mobile) <> 10
    BEGIN
        THROW 50002, 'Mobile number must be exactly 10 digits', 1;
        RETURN;
    END


	 BEGIN TRY

    INSERT INTO ADDRESS (UserId, FullName, Mobile, Address, City, State, Type)
    VALUES (@UserId, @FullName, @Mobile, @Address, @City, @State, @Type);

	 
        IF @@ROWCOUNT = 1
        BEGIN
            PRINT 'Address inserted successfully';
        END
        ELSE
        BEGIN
            THROW 50003, 'Address insertion failed', 1;
        END
    END TRY
    BEGIN CATCH
        -- Capture the error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Return error message
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;


EXEC AddAddress @UserId=4,
                 @FullName='Surya',
				 @Mobile='1234567890',
				 @Address='hsrlayout',
				 @City='Banglore',
				 @State='Karnataka',
				 @Type='Home';

select * from address;

--GET  BY ADDRESS ID

CREATE  or ALTER PROCEDURE GetAddressByAddressId
    @AddressId INT
AS
BEGIN
 SET NOCOUNT ON;

   -- Check if AddressId is provided
    IF @AddressId IS NULL
    BEGIN
        THROW 50009, 'AddressId is required', 1;
        RETURN;
    END

    BEGIN TRY
        IF EXISTS(SELECT 1 FROM ADDRESS)
        BEGIN
            SELECT * FROM ADDRESS WHERE AddressId=@AddressId;
        END
        ELSE
        BEGIN
            THROW 50001, 'No addresses found', 1;
        END
    END TRY
    BEGIN CATCH
        -- Capture the error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Return error message
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;


EXEC GetAddressByAddressId 1;




--GET ADDRESS BY USERID
CREATE OR ALTER PROCEDURE GetAddressByUserId
    @userId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if UserId is provided
    IF @userId IS NULL
    BEGIN
        THROW 50001, 'UserId is required', 1;
        RETURN;
    END

     BEGIN TRY
        IF EXISTS(SELECT 1 FROM ADDRESS)
        BEGIN
            SELECT * FROM ADDRESS WHERE UserId=@userId;
        END
        ELSE
        BEGIN
            THROW 50001, 'No addresses found', 1;
        END
    END TRY
    BEGIN CATCH
        -- Capture the error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Return error message
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;


EXEC GetAddressByUserId 4;

SELECT * FROM ADDRESS;


--GET ALL ADDRESS 
CREATE OR ALTER PROCEDURE GetAllAddresses
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS(SELECT 1 FROM ADDRESS)
        BEGIN
            SELECT * FROM ADDRESS;
        END
        ELSE
        BEGIN
            THROW 50001, 'No addresses found', 1;
        END
    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        -- Throw error
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;


EXEC GetAllAddresses ;



--UPADTE
CREATE OR ALTER PROCEDURE UpdateAddressByAddressId
    @AddressId INT,
    @UserId INT,
    @FullName VARCHAR(50),
    @Mobile VARCHAR(15),
    @Address VARCHAR(MAX),
    @City VARCHAR(50),
    @State VARCHAR(50),
    @Type VARCHAR(15)
AS
BEGIN
    BEGIN TRY
        -- Check if AddressId is provided
        IF @AddressId IS NULL
        BEGIN
            THROW 50001, 'AddressId is required', 1;
            RETURN;
        END

        -- Check if AddressId exists
        IF EXISTS (SELECT 1 FROM ADDRESS WHERE AddressId = @AddressId)
        BEGIN
            -- Update address
            UPDATE ADDRESS
            SET UserId = @UserId,
                FullName = @FullName,
                Mobile = @Mobile,
                Address = @Address,
                City = @City,
                State = @State,
                Type = @Type
            WHERE AddressId = @AddressId;
        END
        ELSE
        BEGIN
            THROW 50002, 'AddressId does not exist', 1;
            RETURN;
        END
    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

select * from address;

EXEC UpdateAddressByAddressId @AddressId=6,
                                     @UserId=4,
									 @FullName='Suresh',
									 @Mobile='1234567899',
									 @Address='HSR LayOut',
									 @City='bng',
									 @State='Karnataka',
									 @Type='Work';


select * from address;

--delete

CREATE OR ALTER PROCEDURE DeleteAddressByAddressId
    @AddressId INT
AS
BEGIN
    BEGIN TRY
        -- Check if AddressId is provided
        IF @AddressId IS NULL
        BEGIN
            THROW 50001, 'AddressId is required', 1;
            RETURN;
        END

        -- Check if AddressId exists
        IF EXISTS (SELECT 1 FROM ADDRESS WHERE AddressId = @AddressId)
        BEGIN
            -- Delete address
            DELETE FROM ADDRESS
            WHERE AddressId = @AddressId;
        END
        ELSE
        BEGIN
            THROW 50002, 'AddressId does not exist', 1;
            RETURN;
        END
    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;



EXEC  DeleteAddressByAddressId 4;

SELECT * FROM ADDRESS;








