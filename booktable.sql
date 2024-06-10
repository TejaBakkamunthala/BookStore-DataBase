USE BOOKSTORE;

CREATE TABLE Books(
BookId INT PRIMARY KEY IDENTITY(1,1),
Title VARCHAR(40),
Author VARCHAR(40),
Rating float ,
RatingCount INT,
Price decimal(6,2),
OriginalPrice decimal(6,2),
DiscountPercentage float,
Description VARCHAR(MAX),
Image VARCHAR(MAX),
Quantity int,
);

select * from Books;

CREATE OR ALTER PROCEDURE InsertBook(
    @Title VARCHAR(40),
    @Author VARCHAR(40),
    @OriginalPrice DECIMAL(6,2),
    @DiscountPercentage FLOAT,
    @Description VARCHAR(MAX),
    @Image VARCHAR(MAX),
    @Quantity INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Title IS NULL OR 
           @Author IS NULL OR 
           @OriginalPrice IS NULL OR 
           @DiscountPercentage IS NULL OR 
           @Description IS NULL OR 
           @Image IS NULL OR 
           @Quantity IS NULL
        BEGIN
            THROW 50001, 'All parameters are required.', 1;
            RETURN;
        END

        IF @Quantity <= 0
        BEGIN
            THROW 50002, 'Quantity must be greater than zero.', 1;
            RETURN;
        END

        DECLARE @BookId INT;

        -- Inserting the book details
        INSERT INTO Books (Title, Author, OriginalPrice, DiscountPercentage, Description, Image, Quantity)
        VALUES (@Title, @Author, @OriginalPrice, @DiscountPercentage, @Description, @Image, @Quantity);

        -- Get the ID of the newly inserted book
        SET @BookId = SCOPE_IDENTITY();

        -- Update the discounted price of the book
        UPDATE Books
        SET Price = OriginalPrice - OriginalPrice * (@DiscountPercentage / 100) 
        WHERE BookId = @BookId;

        IF @@ROWCOUNT = 1
        BEGIN
            PRINT 'BOOK INSERTED SUCCESSFULLY';
        END
        ELSE
        BEGIN
            THROW 50004, 'BOOK INSERTION FAILED', 1;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;

EXEC InsertBook @Title='Treasure ', @Author='Robert', @OriginalPrice=5000,@DiscountPercentage=25, @Description='While going through the possessions of a deceased guest who owed them money', @Image='treasure.jpg', @Quantity=50;


select * from  Books;

select * from users;





--UPDATE BOOK

CREATE OR ALTER PROCEDURE UpdateBookDetails
    @BookId INT,
    @Title VARCHAR(40),
    @Author VARCHAR(40),
    @OriginalPrice DECIMAL(6,2),
    @DiscountPercentage FLOAT,
    @Description VARCHAR(MAX),
    @Image VARCHAR(MAX),
    @Quantity INT
AS
BEGIN
   SET NOCOUNT ON;
    BEGIN TRY
        -- Check if the BookId exists
        IF EXISTS (SELECT 1 FROM Books WHERE BookId = @BookId)
        BEGIN
            DECLARE @Price DECIMAL(10,2);

            -- Calculate the discounted price
            SET @Price = @OriginalPrice * (1 - @DiscountPercentage / 100);

            -- Update the book details
            UPDATE Books
            SET 
                Title = @Title,
                Author = @Author,
                OriginalPrice = @OriginalPrice,
                DiscountPercentage = @DiscountPercentage,
                Description = @Description,
                Image = @Image,
                Quantity = @Quantity,
                Price = @Price
            WHERE BookId = @BookId;

          -- Check the number of rows affected by the update
          IF @@ROWCOUNT=1
            BEGIN
                PRINT 'Book details updated successfully.';
            END
            ELSE
            BEGIN
                THROW 50002, 'Updation failed.', 1;
            END
        END
        ELSE
        BEGIN
            -- Throw an error if the BookId is not available
            THROW 50000, 'BookId is not available.', 1;
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

EXEC UpdateBookDetails
    @BookId = 4,
    @Title = 'Chirutha',
    @Author = 'Ram',
    @OriginalPrice = 3000,
    @DiscountPercentage =25,
    @Description = 'Its a war film',
    @Image = 'ram.jpg',
    @Quantity = 50;

	select *from books;



--DELETE BOOK
	CREATE OR ALTER PROCEDURE DeleteBook
    @BookId INT
AS
BEGIN
    BEGIN TRY
        -- Check if the BookId exists
        IF EXISTS (SELECT 1 FROM Books WHERE BookId = @BookId)
        BEGIN
            -- Delete the book
            DELETE FROM Books WHERE BookId = @BookId;

            PRINT 'Book deleted successfully.';
        END
        ELSE
        BEGIN
            -- Throw an error if the BookId is not available
            THROW 50000, 'BookId does not exist.', 1;
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


EXEC DeleteBook @BookId=2;

select * from books;




--GET ALL BOOKS
CREATE OR ALTER PROCEDURE GetAllBooks
AS
BEGIN
    BEGIN TRY
        -- Check if the BookId exists
        IF EXISTS (SELECT 1 FROM Books)
        BEGIN
            -- Select all books
            SELECT * FROM Books;
        END
        ELSE
        BEGIN
            -- Throw an error if no books are available
            THROW 50000, 'No books available.', 1;
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

EXEC GetAllBooks;




--GET BY BOOKID

CREATE OR ALTER PROCEDURE GetBookById
    @BookId INT
AS
BEGIN
    BEGIN TRY
        -- Check if the BookId exists
        IF EXISTS (SELECT 1 FROM Books WHERE BookId = @BookId)
        BEGIN
            -- Select the book details by BookId
            SELECT * FROM Books WHERE BookId = @BookId;
        END
        ELSE
        BEGIN
            -- Throw an error if the BookId is not available
            THROW 50000, 'BookId does not exist.', 1;
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


EXEC GetBookById @BookId=1;

