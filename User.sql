CREATE DATABASE BOOKSTORE;

USE BOOKSTORE;

CREATE TABLE Users(
UserId INT PRIMARY KEY IDENTITY(1,1),
FullName VARCHAR(50) NOT NULL,
EmailId VARCHAR(50) NOT NULL,
Password VARCHAR(20) NOT NULL,
MobileNumber VARCHAR(15) NOT NULL);


SELECT * FROM Users;




CREATE OR ALTER PROCEDURE User_Registration(
    @FullName VARCHAR(50),
    @EmailId VARCHAR(50),
    @Password VARCHAR(20),
    @MobileNumber VARCHAR(15)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input parameters
    IF @FullName IS NULL OR @EmailId IS NULL OR @Password IS NULL OR @MobileNumber IS NULL
    BEGIN
        THROW 50000, 'All parameters are required', 1;
        RETURN;
    END

    BEGIN TRY
        -- Validate EmailId existence
        IF EXISTS (SELECT 1 FROM Users WHERE EmailId = @EmailId)
        BEGIN
            THROW 50001, 'Email ID already exists', 1;
            RETURN;
        END

        -- Validate Password length
        IF LEN(@Password) < 6
        BEGIN
            THROW 50002, 'Password must be at least 6 characters', 1;
            RETURN;
        END

        -- Validate MobileNumber length
        IF LEN(@MobileNumber) <> 10 
        BEGIN
            THROW 50003, 'Mobile number must be exactly 10 digits', 1;
            RETURN;
        END

        -- Insert new user
        INSERT INTO Users (FullName, EmailId, Password, MobileNumber)
        VALUES (@FullName, @EmailId, @Password, @MobileNumber);

        -- Check if the row was inserted
        IF @@ROWCOUNT = 1
        BEGIN
            PRINT 'User registered successfully';
        END
        ELSE
        BEGIN
            THROW 50005, 'User registration failed', 1;
        END

    END TRY
    BEGIN CATCH
        -- Capture and throw the error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Raise an error with the details of the exception
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;

EXEC User_Registration 'jadeja','jad@gmail.com','jad@123','1234567890';

SELECT * FROM USERS



--GET ALL USERS
CREATE OR ALTER PROCEDURE GETALLUSERS
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Users)
        BEGIN
            SELECT * FROM Users;
        END
        ELSE
        BEGIN
			PRINT 'NO USERS FOUND'
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

       
        PRINT 'Error: ' + @ErrorMessage;
    END CATCH
END

EXEC GETALLUSERS;


--LOGIN


CREATE OR ALTER PROCEDURE LOGIN_SP(
    @EmailId VARCHAR(50),
    @Password VARCHAR(20)
)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Users WHERE EmailId = @EmailId AND Password = @Password)
        BEGIN
            SELECT * FROM Users WHERE EmailId = @EmailId AND Password = @Password;
            PRINT 'Login successful.';
        END
        ELSE
        BEGIN
            THROW 50002, 'Login details are incorrect or not available.', 1;
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

        -- Raise an error with the details of the exception
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;



 EXEC LOGIN_SP 'vir@gmail.com', 'vir@123';

 select * from users;




 --FORGOT PASSWORD

CREATE OR ALTER PROCEDURE Forgot_Password_SP(
@EmailId VARCHAR(50))
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Users WHERE EmailId = @EmailId)
        BEGIN
            SELECT * FROM Users WHERE EmailId=@EmailId;
        END
        ELSE
        BEGIN
		THROW 5000,'USER IS NOT FOUND BY THIS EMAILID',1;
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

        PRINT 'Error: ' + @ErrorMessage;
    END CATCH
END



--RESET PASSWORD

CREATE OR ALTER PROCEDURE Reset_Password_SP
    @EmailId VARCHAR(50),
    @NewPassword VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Update the password for the given email
        UPDATE Users
        SET Password = @NewPassword
        WHERE EmailId = @EmailId;

        -- Check if the update was successful
        IF @@ROWCOUNT = 1
        BEGIN
            THROW 50001, 'Password reset successful.', 1;
        END
        ELSE
        BEGIN
            THROW 50002, 'Reset failed: Email not found.', 1;
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

        -- Raise an error with the details of the exception
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;


select * from users;

 exec Reset_Password_SP 'ram@gmail.com', 'ramm@123'


 --UPDATE User Details


 CREATE PROCEDURE Update_User_Details_SP
    @UserId INT,
    @FullName VARCHAR(50),
    @EmailId VARCHAR(50),
    @Password VARCHAR(20),
    @MobileNumber VARCHAR(15)
AS
BEGIN
    BEGIN TRY
        -- Check if the user ID exists
        IF EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            -- Update the user details
            UPDATE Users
            SET 
                FullName = @FullName,
                EmailId = @EmailId,
                Password = @Password,
                MobileNumber = @MobileNumber
            WHERE UserId = @UserId;

            PRINT 'User details updated successfully.';
        END
        ELSE
        BEGIN
            -- Throw an error if the user ID is not available
            THROW 50000, 'UserID is not available.', 1;
        END
    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Re-throw the error
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;


select * from users;

EXEC Update_User_Details_SP @UserId=1, 
                    @FullName='Raj', 
					@EmailId='raj@gmail.com',
					@Password='raj@123',
					@MobileNumber=1234567890;




--DELETE

CREATE OR ALTER PROCEDURE Delete_User_SP
    @UserId INT
AS
BEGIN
    BEGIN TRY
        -- Check if the user ID exists
        IF EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            -- Delete the user
            DELETE FROM Users
            WHERE UserId = @UserId;

            PRINT 'User deleted successfully.';
        END
        ELSE
        BEGIN
            -- Throw an error if the user ID is not available
            THROW 50000, 'UserID is not available.', 1;
        END
    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Re-throw the error
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;


exec Delete_User_SP @UserId=5;
                
					
				
					


