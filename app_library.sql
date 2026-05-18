-- Library System Management SQL Project

-- CREATE DATABASE library;

-- Create table "Branch"
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);


-- Project TASK


-- ### 2. CRUD Operations


-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

-- Task 2: Update an Existing Member's Address
select * from members m;
update members  set member_address ='124 Main St' WHERE member_id ='C101';

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS106' from the issued_status table.
select * from issued_status;

delete from issued_status where issued_id='IS106';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * FROM  issued_status where issued_emp_id ='E101';


-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

select * from members;
select issued_emp_id ,emp_name, count(*) as count FROM issued_status ist join employees e on 
ist.issued_emp_id =e.emp_id group by 1 having  count>1;


-- ### 3. CTAS (Create Table As Select)


-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

drop table if exists tbs;
CREATE  TABLE tbs AS
select b.isbn,b.book_title,count(issued_id) as count from issued_status ist join books  b on ist.issued_book_isbn= b.isbn group by b.isbn,book_title
;

select name from sqlite_master where type='table' order by name;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

select * from books group by category;

-- Task 8: Find Total Rental Income by Category:

select category,sum(rental_price) as total_rental,  COUNT(*) from books group by 1;

-- Task 9. **List Members Who Registered in the Last 180 Days**:

select * from members where reg_date >=DATE('NOW','-180 days');


-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:

SELECT e1.* ,e2.emp_name as branch_manger,b.* from employees e1 join branch b on e1.branch_id =b.branch_id 
join  employees e2 on b.manager_id =e2.emp_id ;



-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD

create table Book as
select * from books where rental_price>7;

-- Task 12: Retrieve the List of Books Not Yet Returned

    select t.issued_book_name  from issued_status t left join return_status rs on t.issued_id =rs.issued_id
    where return_id is NULL ;
    
   

--### Advanced SQL Operations

--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

    -- issued_status== members== books == return_status
    -- filter which is return 
    -- over due > 30 days
    
    INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
--('IS151', 'C118', 'The Catcher in the Rye', DATE('NOW' ,'-24 days'),  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', DATE('NOW' ,'-13 days'),  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', DATE('NOW' ,'-7 days'),  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', DATE('NOW' ,'-32 days'),  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;

select t.issued_member_id  ,m.member_name ,b.book_title ,t.issued_date  ,--rs.return_date,
round((julianday('now') - julianday(t.issued_date)),0) as over_due_days
from issued_status t join  members m on t.issued_member_id =m.member_id
join books b on t.issued_book_isbn  = b.isbn
 left join return_status rs on rs.issued_id = t.issued_id
where rs.return_date is null and over_due_days >30;

-- date as current date
select  julianday();


--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "yes" when they are returned (based on entries in the return_status table).

-- book == issued _status via isb = return_status
-- update status as "available" in book if we found book not returned.
-- create a procedure to screate the above logic in a call func.



CREATE TRIGGER update_book_status_on_return
AFTER INSERT ON return_status
FOR EACH ROW
BEGIN

  UPDATE books
  SET status = 'yes'
  WHERE isbn = (SELECT issued_book_isbn
  FROM issued_status
  WHERE issued_id = NEW.issued_id);
END;

INSERT INTO return_status (return_id, issued_id, return_date)
VALUES ('RS119', 'IS134', date('now'));

delete FROM return_status where issued_id='IS134';

--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

create table bank_report as
SELECT b.branch_id ,b.manager_id , count(t.issued_id) as num_book_issued,count(rs.return_id ) as num_book_returned,sum(bk.rental_price ) as total_revenue
from issued_status t join employees e on t.issued_emp_id = e.emp_id
join branch b on b.branch_id =e.branch_id
left join return_status rs on rs.issued_id =t.issued_id 
join books bk on bk.isbn =t.issued_book_isbn group by 1,2;

select * from bank_report;

--Task 16: CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.


select * from members m where m.member_id in 
(select distinct issued_member_id from issued_status t where t.issued_date >= DATE('2024-05-21','-60 days'));


--Task 17: Find Employees with the Most Book Issues Processed
--Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select e.emp_name ,count(t.issued_id ) as num_book_issued ,b.* from employees e 
join issued_status t on e.emp_id = t.issued_emp_id 
join branch b on b.branch_id = e.branch_id  group by emp_name order by num_book_issued desc limit 3;


--Task 18: Identify Members Issuing High-Risk Books
--Write a query to identify members who have issued books more than twice with the status "yes" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

select m.member_name ,t.issued_book_name as book_title,count(t.issued_id) as issued_books
from issued_status t join books b on t.issued_book_isbn=b.isbn
join members m on t.issued_member_id =m.member_id 
join return_status rs on rs.issued_id =t.issued_id 
where b.status ='yes' and rs.book_quality='Good' group by 1,2 having issued_books >=2;

m.member_name ,t.issued_book_name as book_title,count(t.issued_id) as issued_books



--Task 19: Stored Procedure
--Objective: Create a stored procedure to manage the status of books in a library system.
--    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
--    If a book is issued, the status should change to 'no'.
--    If a book is returned, the status should change to 'yes'.


select * from books;
select * from issued_status;

CREATE TRIGGER check_book_availability_before_issue
BEFORE INSERT ON issued_status
FOR EACH ROW
WHEN (SELECT status FROM books WHERE isbn = NEW.issued_book_isbn) != 'yes'
BEGIN
    SELECT RAISE(ABORT, 'Sorry, the requested book is currently unavailable.');
END;

CREATE TRIGGER update_book_status_after_issue
AFTER INSERT ON issued_status
FOR EACH ROW
BEGIN
    UPDATE books
    SET status = 'no'
    WHERE isbn = NEW.issued_book_isbn;
END;

-- Assuming this book has status = 'yes'
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_isbn, issued_emp_id)
VALUES ('IS155', 'C108', '978-0-553-29698-2', 'E104');

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_isbn, issued_emp_id)
VALUES ('IS156', 'C107', '978-0-375-41398-8', 'E106');


SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

--Task 20: Create Table As Select (CTAS)
--Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
--
--Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
--    The number of overdue books.
--    The total fines, with each day's fine calculated at $0.50.
--    The number of books issued by each member.
--    The resulting table should show:
--    Member ID
--    Number of overdue books
--    Total fines

	SELECT  
    m.member_id,
    COUNT(r.return_id IS NULL) as num_not_retuned,
   round((julianday('now') - julianday(i.issued_date)) - 30,0) AS overdue_by_days,
       round((julianday('now') - julianday(i.issued_date)) - 30,0) * 0.50 AS fine
FROM
    members m
        JOIN
    issued_status i ON m.member_id = i.issued_member_id
        JOIN
    books b ON i.issued_book_isbn = b.isbn
        LEFT JOIN
    return_status r ON i.issued_id = r.issued_id
WHERE
    r.return_id IS NULL
        AND     round((julianday('now') - julianday(i.issued_date)) - 30,0) > 0
GROUP BY m.member_id;

