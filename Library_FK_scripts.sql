-- Table recreation to take into account some alterations (deletion of column, modification of foreign key...)

CREATE TEMPORARY TABLE temp AS
SELECT
  issued_id,
  issued_member_id,
  issued_book_name,
  issued_date,
  issued_book_isbn,
  issued_emp_id
FROM issued_status;

DROP TABLE issued_status;

CREATE TABLE issued_status (
	issued_id TEXT,
	issued_member_id TEXT,
	issued_book_name TEXT,
	issued_date TEXT,
	issued_book_isbn TEXT,
	issued_emp_id TEXT,
	emp_id TEXT,
	member_id TEXT,
	isbn TEXT,
	CONSTRAINT ISSUED_STATUS_PK PRIMARY KEY (issued_id),
	CONSTRAINT issued_status_employees_FK FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
	CONSTRAINT issued_status_members_FK FOREIGN KEY (member_id) REFERENCES members(member_id),
	CONSTRAINT issued_status_books_FK FOREIGN KEY (isbn) REFERENCES books(isbn)
);
CREATE UNIQUE INDEX sqlite_autoindex_issued_status_1 ON issued_status (issued_id);

INSERT INTO issued_status
 (issued_id,
  issued_member_id,
  issued_book_name,
  issued_date,
  issued_book_isbn,
  issued_emp_id)
SELECT
  issued_id,
  issued_member_id,
  issued_book_name,
  issued_date,
  issued_book_isbn,
  issued_emp_id
FROM temp;

DROP TABLE temp;
