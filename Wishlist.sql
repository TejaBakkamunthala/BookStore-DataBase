USE BOOKSTORE;


CREATE TABLE Wishlist (
 WishlistId INT PRIMARY KEY IDENTITY(1,1),
 UserId INT FOREIGN kEY REFERENCES Users(UserId),
 BookId INT FOREIGN KEY REFERENCES Books(BookId),
 Title VARCHAR(40),
 Author VARCHAR(40),
 Image VARCHAR(MAX),
 Price DECIMAL(10,2),
 OriginalPrice DECIMAL(10, 2),
); 


select * from  books;

select * from cart;

select * from Wishlist;

select * from users;

CREATE OR ALTER PROCEDURE Add_Book_To_Wishlist_SP
@UserId INT,
@BookId INT
AS
BEGIN
    DECLARE @Title VARCHAR(40),
            @Author VARCHAR(40),
            @Image VARCHAR(MAX),
            @Price DECIMAL(10,2),
            @OriginalPrice DECIMAL(10, 2);
    
    -- Get book details from the Books table
    SELECT @Title = Title,
           @Author = Author,
           @Image = Image,
           @Price = Price,
           @OriginalPrice = OriginalPrice
    FROM Books
    WHERE BookId = @BookId;
    
    -- Check if the book exists in the Books table
    IF @@ROWCOUNT > 0
    BEGIN
        -- Insert the book into the Wishlist table
        INSERT INTO Wishlist (UserId, BookId, Title, Author, Image, Price, OriginalPrice)
        VALUES (@UserId, @BookId, @Title, @Author, @Image, @Price, @OriginalPrice);
        
        PRINT 'Book added to wishlist successfully.';
    END
    ELSE
    BEGIN
        RAISERROR ('Book not found.', 16, 1);
    END 
END


select * from users;
select * from books;
select * from Wishlist;

exec Add_Book_To_Wishlist_SP 8,5;

CREATE OR ALTER PROCEDURE GETALLWHISHLIST(
    @UserId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if UserId exists
        IF EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            -- Select wishlist items for the user
            SELECT * FROM Wishlist WHERE UserId = @UserId;
        END
        ELSE
        BEGIN
            -- Raise an error if the UserId does not exist
            THROW 50001, 'UserId does not exist.', 1;
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


EXEC GETALLWHISHLIST 2;
 


CREATE OR ALTER PROCEDURE GETALLWISHLISTT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if there are any rows in the Wishlist table
        IF EXISTS (SELECT 1 FROM Wishlist)
        BEGIN
            -- Select all records from the Wishlist table
            SELECT * FROM Wishlist;
        END
        ELSE
        BEGIN
            -- Raise an error if the Wishlist table is empty
            THROW 50001, 'Wishlist is empty.', 1;
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

        -- Raise an error with the details of the exception
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;

EXEC GETALLWISHLISTT;




CREATE OR ALTER PROCEDURE DELETEWHISHLIST
    @WishlistId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if the Wishlist item exists
        IF EXISTS (SELECT 1 FROM Wishlist WHERE WishlistId = @WishlistId)
        BEGIN
            -- Delete the Wishlist item
            DELETE FROM Wishlist WHERE WishlistId = @WishlistId;

            -- Check if the row was deleted
            IF @@ROWCOUNT = 1
            BEGIN
                PRINT 'Wishlist item deleted successfully.';
            END
            ELSE
            BEGIN
                THROW 50002, 'Deletion failed. Please try again.', 1;
            END
        END
        ELSE
        BEGIN
            -- Raise an error if the Wishlist item does not exist
            THROW 50001, 'Wishlist item not found.', 1;
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

        -- Raise an error with the details of the exception
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;

EXEC GETALLWISHLISTT;

EXEC DELETEWHISLIST 7;