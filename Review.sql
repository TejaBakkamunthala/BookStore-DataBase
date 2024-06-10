--1)fetch book using book name and author name


USE BOOKSTORE;

select * from AdminDetails;

SELECT * FROM BOOKS;

CREATE OR ALTER PROCEDURE FecthBookByName(
@Title VARCHAR(40),
@Author VARCHAR(40))
AS
BEGIN
SELECT * FROM Books where Title=@Title AND Author=@Author
END;

EXEC FecthBookByName 'Eagle','ravi';


--2) check how many books is there in a cart for a specific user and print it alongwith user details(name and number + cart info)

select * from users;
select * from carts;


CREATE OR ALTER PROCEDURE GetCartItemsByUserId
    @UserId INT
AS
BEGIN
     
        SELECT c.UserId,b.BookId,c.CartId,u.FullName,u.MobileNumber,b.Title,b.Image, b.Author,c.TotalPrice,c.TotalOriginalPrice,c.Quantity
        FROM Users u
        JOIN Carts c ON u.UserId = c.UserId
		JOIN Books b on c.BookId=b.BookId
        WHERE c.UserId = @UserId;
	 END;

	 exec GetCartItemsByUserId 1;
