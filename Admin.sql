USE BOOKSTORE;

CREATE TABLE AdminDetails(
AdminId INT PRIMARY KEY IDENTITY(1,1),
FullName VARCHAR(50) NOT NULL,
EmailId VARCHAR(50) NOT NULL,
Password VARCHAR(20) NOT NULL,
MobileNumber VARCHAR(15) NOT NULL);



SELECT * FROM AdminDetails;

CREATE OR ALTER PROCEDURE  InsertAdmin(
    @FullName VARCHAR(50),
    @EmailId VARCHAR(50),
    @Password VARCHAR(20),
    @MobileNumber VARCHAR(15))
AS
BEGIN
    SET NOCOUNT ON;
	 IF @FullName IS NULL OR
	 @EmailId IS NULL OR 
	 @Password IS NULL OR
	 @MobileNumber IS NULL

    BEGIN
        PRINT 'All parameters are required';
        RETURN;
    END


    BEGIN TRY
        -- Validate EmailId existence
        IF EXISTS (SELECT 1 FROM AdminDetails WHERE EmailId = @EmailId)
        BEGIN
            PRINT 'Email ID already exists';
            RETURN;
        END

        IF LEN(@Password) <6
        BEGIN
            PRINT 'Password must be at least 6 characters ';
            RETURN;
        END

        
        IF LEN(@MobileNumber) <> 10 
        BEGIN
            PRINT 'Mobile number must be exactly 10 digits';
            RETURN;
        END

        -- Insert new user
        INSERT INTO AdminDetails(FullName, EmailId, Password, MobileNumber)
        VALUES (@FullName, @EmailId, @Password, @MobileNumber);

       IF @@ROWCOUNT=1
BEGIN
PRINT 'Admin REGISTERED SUCCESSFULLY';
END

ELSE

BEGIN
PRINT 'Admin REGISTERED FAILED'
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
        PRINT 'Error occurred: ' + @ErrorMessage;
    END CATCH
END;




exec InsertAdmin 'Teja','Teja@gmail.com','Teja@123','7984110718';

select * from AdminDetails

--adminLogin 

CREATE OR ALTER PROCEDURE AdminLogin(
    @EmailId VARCHAR(50),
    @Password VARCHAR(20)
)
AS
BEGIN 
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM AdminDetails WHERE EmailId = @EmailId AND Password = @Password)
        BEGIN
            SELECT * FROM AdminDetails WHERE EmailId = @EmailId AND Password = @Password;
            PRINT 'Admin LOGIN SUCCESSFULL';
        END
        ELSE
        BEGIN
            THROW 50001, 'LOGIN DETAILS ARE INCORRECT OR LOGIN DETAILS ARE NOT AVAILABLE', 1;
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

        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;





 exec AdminLogin 'Teja@gmail.com','Teja@123';

select * from AdminDetails