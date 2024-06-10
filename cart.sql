USE BOOKSTORE;


CREATE TABLE Carts (
    CartId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT FOREIGN kEY REFERENCES Users(UserId),
    BookId INT FOREIGN KEY REFERENCES Books(BookId),
	Title VARCHAR(40),
	Author VARCHAR(40),
	Image VARCHAR(40),
	Quantity INT,
	TotalPrice DECIMAL(10,2),
    TotalOriginalPrice DECIMAL(10, 2),
); 

SELECT * FROM CARTS;

select * from books;




--add bookk
create or alter procedure AddBook_ToCart_SP
(
    @UserId int,
    @BookId int,
    @Quantity int=1
)
as
begin
    SET NOCOUNT ON;
    begin try
     declare 
			@Title varchar(50),
			@Author varchar(50),
			@Image varchar(max),
			@Price decimal(10, 2), 
			@OriginalPrice decimal(10, 2)
	
	
    -- Get the details from the cart

    select 
           @BookId = b.BookId, 
		   @Title = b.Title,
		   @Author = b.Author,
		   @Image = b.Image,
           @Price = b.Price, 
           @OriginalPrice = b.OriginalPrice
    from  Books b
    where b.BookId = @BookId
		 
		 select * from books;

        -- Check if the book is already in the cart
        if not exists (select 1 from Carts where UserId = @UserId and BookId = @BookId)
        begin
            -- If book does not exist in the cart, insert new record
            insert into Carts (UserId, BookId,Title,Author,Image,Quantity, TotalPrice, TotalOriginalPrice)
            values            (@UserId, @BookId,@Title,@Author,@Image,@Quantity, @Quantity * @Price, @Quantity * @OriginalPrice);
        end
        else
        begin
            -- Raise an error if the book is already in the cart
            raiserror('The book is already in the cart. Use UpdateCart_SP to update the quantity.', 16, 1);
        end
    end try
    begin catch
        declare @ErrorMessage NVARCHAR(4000);
        declare @ErrorSeverity INT;
        declare @ErrorState INT;

        select @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    end catch
end


select * from carts;
select* from users;
select * from books;
select * from users;

exec AddBook_ToCart_SP @UserId=2,
                       @BookId=6;
				


--get cart items
CREATE OR ALTER PROCEDURE GetCartItems
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if UserId exists
        IF EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            -- Fetch cart items for the provided UserId
            SELECT c.CartId, c.UserId, c.BookId, b.Title, b.Image, b.Author,
                   c.TotalPrice,
                   c.TotalOriginalPrice,
                   c.Quantity
            FROM Carts c
            JOIN Books b ON c.BookId = b.BookId
            WHERE c.UserId = @UserId;
        END
        ELSE
        BEGIN
            THROW 50001, 'UserId does not exist.', 1;
        END
    END TRY
    BEGIN CATCH
        -- Re-throw the error
        THROW;
    END CATCH
END;

exec GetCartItems 2;


CREATE OR ALTER PROCEDURE GetCartItemss
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if there are any cart items
        IF EXISTS (SELECT 1 FROM Carts)
        BEGIN
            -- Fetch all cart items
            SELECT c.CartId, c.UserId, c.BookId, b.Title, b.Image, b.Author,
                   c.TotalPrice,
                   c.TotalOriginalPrice,
                   c.Quantity
            FROM Carts c
            JOIN Books b ON c.BookId = b.BookId;
        END
        ELSE
        BEGIN
            THROW 50001, 'No cart items found.', 1;
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
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

exec GetCartItemss ;



--updateeee(new one)
CREATE OR ALTER PROCEDURE UpdateCartItemByCartId
    @CartId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Price DECIMAL(6, 2);
        DECLARE @OriginalPrice DECIMAL(6, 2);
        DECLARE @BookId INT;
        DECLARE @ExistingQuantity INT;
        

        -- Get the existing quantity and BookId from the Cart
        SELECT @BookId = BookId, @ExistingQuantity = Quantity
        FROM Carts
        WHERE CartId = @CartId;

        -- Check if the cart item exists
        IF @BookId IS NULL
        BEGIN
            RAISERROR('The cart item does not exist.', 16, 1);
            RETURN;
        END

        -- Get the book prices from the Books table
        SELECT @Price = Price, @OriginalPrice = OriginalPrice
        FROM Books
        WHERE BookId = @BookId;

        -- Update the cart item with the new quantity and total prices
        UPDATE Carts
        SET 
            Quantity =@ExistingQuantity + @Quantity,
            TotalPrice =(@ExistingQuantity+@Quantity) * @Price,
            TotalOriginalPrice = (@ExistingQuantity+@Quantity) * @OriginalPrice
        WHERE CartId = @CartId;

        -- Check if the update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            -- If no rows were affected, raise an error
            RAISERROR ('No rows affected. Update failed.', 16, 1);
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
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


select * from carts;

exec UpdateCartItemByCartId 5,-40;






--delete stored procedure
CREATE OR ALTER PROCEDURE DeleteCartItem
    @CartId INT
AS
BEGIN
    BEGIN TRY
        -- Attempt to delete the cart item
        DELETE FROM Carts
        WHERE CartId = @CartId;

        -- Check if the delete was successful
        IF @@ROWCOUNT = 0
        BEGIN
            -- If no rows were affected, raise an error
            RAISERROR ('No rows affected. Delete failed. Cart item may not exist.', 16, 1);
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

        --Raise an error with the details of the exception
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

exec DeleteCartItem 6; 

select * from carts;