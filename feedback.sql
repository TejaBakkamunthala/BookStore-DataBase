USE BOOKSTORE;


Create table Feedbacks(
FeedbackId INT PRIMARY KEY IDENTITY(1,1),
UserId INT FOREIGN KEY REFERENCES Users(UserId) ,
BookId INT FOREIGN KEY REFERENCES Books(BookId),
UserName VARCHAR(50),
Rating float,
Review VARCHAR(MAX));

SELECT * FROM Feedbacks;

select * from books;

 select * from users;


CREATE OR ALTER PROCEDURE AddFeedback (
    @UserId INT,
    @BookId INT,
    @Rating FLOAT,
    @Review VARCHAR(MAX)
)
AS
BEGIN
    -- Check if UserId and BookId exist
    IF EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId) AND EXISTS (SELECT 1 FROM Books WHERE BookId = @BookId)
    BEGIN
        -- Declare variable for UserName
        DECLARE @UserName NVARCHAR(255);

        -- Get the username from the Users table
        SELECT @UserName = FullName FROM Users WHERE UserId = @UserId;

        -- Insert the feedback into the Feedbacks table
        INSERT INTO Feedbacks (UserId, BookId, UserName, Rating, Review)
        VALUES (@UserId, @BookId, @UserName, @Rating, @Review);

        -- Update the rating and review count of the book
        UPDATE Books
        SET Rating = (SELECT AVG(Rating) FROM Feedbacks WHERE BookId = @BookId),
            RatingCount = (SELECT COUNT(*) FROM Feedbacks WHERE BookId = @BookId)
        WHERE BookId = @BookId;
    END
    ELSE
    BEGIN
        -- Throw an error if either User or Book doesn't exist
        THROW 50001, 'User or Book does not exist.', 1;
    END
END;

exec AddFeedback  @UserId=4,@BookId=9, @Rating=4, @Review='Good';

exec AddFeedback  @UserId=7,@BookId=9, @Rating=3, @Review='Average';


select * from users;
select * from Feedbacks;
select * from books;


--UPDATE FEEDBACK 

CREATE OR ALTER PROCEDURE UpdateFeedback (
    @FeedbackId INT,
    @Rating FLOAT,
    @Review VARCHAR(MAX)
)
AS
BEGIN
    BEGIN TRY
        -- Check if the FeedbackId exists
        IF EXISTS (SELECT 1 FROM Feedbacks WHERE FeedbackId = @FeedbackId)
        BEGIN
            -- Update the feedback
            UPDATE Feedbacks
            SET Rating = @Rating,
                Review = @Review
            WHERE FeedbackId = @FeedbackId;

            -- Update the rating and review count of the book
            DECLARE @BookId INT;
            SELECT @BookId = BookId FROM Feedbacks WHERE FeedbackId = @FeedbackId;

            UPDATE Books
            SET Rating = (SELECT AVG(Rating) FROM Feedbacks WHERE BookId = @BookId),
                RatingCount = (SELECT COUNT(*) FROM Feedbacks WHERE BookId = @BookId)
            WHERE BookId = @BookId;

            PRINT 'Feedback updated successfully.';
        END
        ELSE
        BEGIN
            -- Throw an error if the FeedbackId is not available
            THROW 50000, 'FeedbackId does not exist.', 1;
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


EXEC UpdateFeedback    @FeedbackId =1,
                        @Rating =2,
                        @Review ='Nice';

	select * from Feedbacks;


	--DELETE FEEDBACK

CREATE OR ALTER PROCEDURE DeleteFeedback
   @FeedbackId INT
AS
BEGIN
    BEGIN TRY
        -- Check if the FeedbackId exists
        IF EXISTS (SELECT 1 FROM Feedbacks WHERE FeedbackId = @FeedbackId)
        BEGIN
            -- Delete the feedback
            DELETE FROM Feedbacks WHERE FeedbackId = @FeedbackId;

            PRINT 'Feedback deleted successfully.';
        END
        ELSE
        BEGIN
            -- Throw an error if the FeedbackId is not available
            THROW 50000, 'FeedbackId does not exist.', 1;
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

select * from Feedbacks;

EXEC DeleteFeedback @FeedbackId=2;



--GET ALL FEEDBACKS
CREATE OR ALTER PROCEDURE GetAllFeedbacks
AS
BEGIN
    BEGIN TRY
        -- Select all feedbacks
        SELECT * FROM Feedbacks;
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


EXEC GetAllFeedbacks;



--Get All Feed Backs based on Book Id

CREATE OR ALTER PROCEDURE GetFeedbacksByBookId
    @BookId INT
AS
BEGIN
    BEGIN TRY
        -- Check if the BookId exists
        IF EXISTS (SELECT 1 FROM Books WHERE BookId = @BookId)
        BEGIN
            -- Select all feedbacks for the given BookId
            SELECT * FROM Feedbacks WHERE BookId = @BookId;
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


EXEC GetFeedbacksByBookId @BookId=1;





