USE BOOKSTORE;

create table Orders(
OrderId INT PRIMARY KEY IDENTITY(1,1),
 UserId INT FOREIGN kEY REFERENCES Users(UserId),
 BookId INT FOREIGN KEY REFERENCES Books(BookId),
 Title VARCHAR(40),
 Author VARCHAR(40),
 Image VARCHAR(MAX),
 Quantity INT,
 TotalPrice DECIMAL(10,2),
 TotalOriginalPrice DECIMAL(10, 2),
 OrderDate DATETIME DEFAULT GETDATE()
); 


select * from Orders;

select * from Carts;



create or alter procedure Place_Order_SP
@CartId int
as
begin
    declare @UserId int, 
			@BookId int, 
			@Title varchar(50),
			@Author varchar(50),
			@Image varchar(max),
			@Quantity int, 
			@TotalPrice decimal(10, 2), 
			@TotalOriginalPrice decimal(10, 2)
	
    -- Get the details from the cart
    select @UserId = c.UserId, 
           @BookId = c.BookId, 
		   @Title = b.Title,
		   @Author = b.Author,
		   @Image = b.Image,
           @Quantity = c.Quantity, 
           @TotalPrice = c.TotalPrice, 
           @TotalOriginalPrice = c.TotalOriginalPrice
    from Carts c, Books b
    where c.BookId = b.BookId and
		  CartId = @CartId

    -- Check if the book is available in the required quantity
    if exists (select 1 from Books where BookId = @BookId and Quantity >= @Quantity)
	begin
		-- Check if the book is in the cart
		 if  exists (select 1 from Carts where BookId = @BookId)
			begin
				-- Insert into Orders
				insert into Orders (UserId, BookId, Title, Author, Image, Quantity, TotalPrice, TotalOriginalPrice)
				values (@UserId, @BookId, @Title, @Author, @Image, @Quantity, @TotalPrice, @TotalOriginalPrice);

				-- Decrease the quantity in Books table
				update Books
				set Quantity = Quantity - @Quantity
				where BookId = @BookId;

				-- Remove the item from the cart
				delete from Carts
				where CartId = @CartId;
			end
		else
		begin
			        RAISERROR ('The book is out of stock.', 16, 1);

		end
	end
	else
    begin
			RAISERROR ('The book is not available in the cart..', 16, 1);
    end
end


select * from orders;
select * from books;
select * from carts;

EXEC Place_Order_SP @CartId =4 ;



CREATE OR ALTER PROCEDURE GetAllOrders
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if the UserId exists
        IF EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId)
        BEGIN
            -- Select orders for the given UserId
            SELECT * FROM Orders WHERE UserId = @UserId;
        END
        ELSE
        BEGIN
            -- Throw an error if the UserId does not exist
            THROW 50000, 'UserId does not exist.', 1;
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

        -- Raise an error with the details of the exception
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


EXEC GetAllOrders 2;


CREATE OR ALTER PROCEDURE GetAllOrderss
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if there are any orders
        IF EXISTS (SELECT 1 FROM Orders)
        BEGIN
            -- Select all orders
            SELECT * FROM Orders;
        END
        ELSE
        BEGIN
            -- Print message if no orders are present
            PRINT 'No orders found.';
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

        -- Raise an error with the details of the exception
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


EXEC GetAllOrderss



--cancel Order
CREATE OR ALTER PROCEDURE CancelOrderAndRestoreToCartSP
@OrderId int
AS
BEGIN
    DECLARE @BookId int, 
            @Quantity int;
    
    -- Get BookId and Quantity from the order
    SELECT @BookId = BookId, @Quantity = Quantity
    FROM Orders
    WHERE OrderId = @OrderId;

    -- Check if the order exists
    IF EXISTS (SELECT 1 FROM Orders WHERE OrderId = @OrderId)
    BEGIN

        -- Delete the order
        DELETE FROM Orders WHERE OrderId = @OrderId;

        -- Restore the quantity of the book in the Books table
        UPDATE Books
        SET Quantity = Quantity + @Quantity
        WHERE BookId = @BookId;
        PRINT 'Order deleted successfully and book restored to cart.';
    END
    ELSE
    BEGIN
        RAISERROR ('Order not found.', 16, 1);
    END
END

SELECT * FROM BOOKS;
SELECT * FROM ORDERS;

EXEC CancelOrderAndRestoreToCartSP 8


