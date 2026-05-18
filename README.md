# Library System Management Data

A comprehensive SQL-based library management system designed to handle books, members, employees, branches, and book transactions. This project demonstrates advanced SQL operations including CRUD operations, data analysis, triggers, and performance reporting.

## 📋 Project Overview

This project implements a complete library management system with the following features:
- **Multi-branch support** with branch management and employee hierarchy
- **Member registration and management** with rental tracking
- **Book inventory system** with rental pricing and availability status
- **Book issuance and return tracking** with quality assessment
- **Advanced analytics** including overdue book identification and fine calculation
- **Performance reporting** for branch statistics and employee metrics

## 📂 Project Structure

```
├── app_library.sql               # Main database schema and operations
├── Library_FK_scripts.sql        # Foreign key constraints and table relationships
├── books.csv                     # Sample book inventory data
├── branch.csv                    # Branch information
├── employees.csv                 # Employee details
├── members.csv                   # Library member information
├── issued_status.csv             # Book issuance records
└── return_status.csv             # Book return records
```

## 🗄️ Database Schema

### Core Tables

#### **Branch Table**
- `branch_id` (VARCHAR, PK): Unique branch identifier
- `manager_id` (VARCHAR): Employee ID of branch manager
- `branch_address` (VARCHAR): Branch location
- `contact_no` (VARCHAR): Branch contact number

#### **Employees Table**
- `emp_id` (VARCHAR, PK): Unique employee identifier
- `emp_name` (VARCHAR): Employee name
- `position` (VARCHAR): Job position
- `salary` (DECIMAL): Employee salary
- `branch_id` (VARCHAR, FK): Associated branch

#### **Members Table**
- `member_id` (VARCHAR, PK): Unique member identifier
- `member_name` (VARCHAR): Member name
- `member_address` (VARCHAR): Member address
- `reg_date` (DATE): Registration date

#### **Books Table**
- `isbn` (VARCHAR, PK): International Standard Book Number
- `book_title` (VARCHAR): Book title
- `category` (VARCHAR): Book category
- `rental_price` (DECIMAL): Daily rental price
- `status` (VARCHAR): Availability status (yes/no)
- `author` (VARCHAR): Author name
- `publisher` (VARCHAR): Publisher name

#### **Issued Status Table**
- `issued_id` (VARCHAR, PK): Unique issuance identifier
- `issued_member_id` (VARCHAR, FK): Member issuing the book
- `issued_book_name` (VARCHAR): Title of issued book
- `issued_date` (DATE): Date of issuance
- `issued_book_isbn` (VARCHAR, FK): ISBN of issued book
- `issued_emp_id` (VARCHAR, FK): Employee processing issuance

#### **Return Status Table**
- `return_id` (VARCHAR, PK): Unique return identifier
- `issued_id` (VARCHAR): Reference to issuance record
- `return_book_name` (VARCHAR): Title of returned book
- `return_date` (DATE): Date of return
- `return_book_isbn` (VARCHAR, FK): ISBN of returned book
- `book_quality` (VARCHAR): Condition of returned book

## 🚀 Key Features & Operations

### 1. CRUD Operations
- **Create**: Add new books, members, employees, and branches
- **Read**: Retrieve member details, book information, and transaction records
- **Update**: Modify member addresses and book availability status
- **Delete**: Remove issued status records when needed

### 2. Complex Queries

#### Task 7-12: Data Analysis & Retrieval
- Retrieve books by category
- Calculate total rental income by category
- Find recently registered members (last 180 days)
- List employees with branch manager information
- Filter books by rental price threshold
- Identify unreturned books

#### Task 13: Overdue Book Tracking
Identify members with overdue books (>30 days):
```sql
SELECT member_name, book_title, issued_date, 
       round((julianday('now') - julianday(issued_date)), 0) as overdue_days
FROM issued_status
JOIN members ON issued_member_id = member_id
JOIN books ON issued_book_isbn = isbn
WHERE return_id IS NULL AND overdue_days > 30
```

#### Task 15: Branch Performance Report
Generate comprehensive branch statistics:
- Number of books issued
- Number of books returned
- Total rental revenue per branch

#### Task 17: Top Performing Employees
Identify top 3 employees processing the most book issues with branch details.

#### Task 20: Overdue Fine Calculation
Create comprehensive fine report with:
- Number of overdue books per member
- Total fines at $0.50 per day
- Overdue duration calculation

### 3. Advanced Features

#### Triggers
- **check_book_availability_before_issue**: Prevents issuing unavailable books
- **update_book_status_after_issue**: Automatically updates book status to 'no' when issued
- **update_book_status_on_return**: Automatically updates book status to 'yes' when returned

#### CTAS (Create Table As Select)
- Create summary tables for book issuance counts
- Generate active members table (issued books in last 60 days)
- Create branch performance reports
- Generate overdue books and fine calculation tables

## 📊 Data Files

All CSV files contain sample data for:
- **books.csv**: 15+ sample books across multiple categories
- **branch.csv**: 3-5 branch locations
- **employees.csv**: Employee records with roles and salaries
- **members.csv**: Library member registrations
- **issued_status.csv**: Sample book issuance transactions
- **return_status.csv**: Book return records with quality assessment

## 🔑 Key Insights from Analysis

1. **Book Availability Management**: Automated status tracking prevents double-issuing
2. **Revenue Analysis**: Category-wise rental income calculation for business decisions
3. **Member Activity**: Identifies active and inactive members for targeted campaigns
4. **Employee Performance**: Track employee productivity through issuance metrics
5. **Overdue Management**: Fine calculation system to encourage timely returns
6. **Branch Analytics**: Compare branch performance across locations

## 🛠️ Technologies Used

- **Database**: SQLite
- **Language**: SQL
- **Data Format**: CSV
- **Features**: Triggers, Foreign Keys, Joins, Aggregations, CTAs

## 📝 How to Use

1. **Set up the database**:
   ```sql
   -- Create database and tables
   SOURCE app_library.sql;
   ```

2. **Apply foreign key constraints**:
   ```sql
   -- If needed, run the FK scripts
   SOURCE Library_FK_scripts.sql;
   ```

3. **Load sample data**:
   - Import CSV files into respective tables
   - Or use the INSERT statements provided in the SQL files

4. **Run analysis queries**:
   - Execute individual tasks from the main SQL file
   - Customize queries based on specific business requirements

## 📈 Sample Queries

### Find active members in the last 60 days
```sql
SELECT * FROM members 
WHERE member_id IN 
  (SELECT DISTINCT issued_member_id FROM issued_status 
   WHERE issued_date >= DATE('now', '-60 days'));
```

### Calculate rental income by category
```sql
SELECT category, SUM(rental_price) as total_rental, COUNT(*) 
FROM books 
GROUP BY category;
```

### List unreturned books
```sql
SELECT issued_book_name, member_name, issued_date 
FROM issued_status 
LEFT JOIN return_status ON issued_status.issued_id = return_status.issued_id
JOIN members ON issued_member_id = member_id
WHERE return_id IS NULL;
```

## 🎯 Use Cases

- **Library Administration**: Manage branches, employees, and operations
- **Member Management**: Track member registrations and activities
- **Inventory Control**: Monitor book availability and stock
- **Revenue Tracking**: Calculate rental income and generate reports
- **Compliance**: Identify overdue books and calculate fines
- **Performance Analysis**: Evaluate employee and branch performance

## 📚 Learning Outcomes

This project demonstrates:
- ✅ Database design with multiple related tables
- ✅ Complex SQL joins and aggregations
- ✅ Trigger implementation for automated updates
- ✅ CTAS for derived data tables
- ✅ Advanced querying techniques
- ✅ Data analysis and business intelligence
- ✅ SQL best practices and optimization

## 🤝 Contributing

Feel free to fork this project and enhance it with:
- Additional features (reservations, late fees, notifications)
- API layer for application integration
- Enhanced reporting dashboards
- Performance optimizations

## 📞 Support

For questions or issues, please open a GitHub issue in this repository.

---

**Author**: Niharika-prog08  
**Date**: May 2026  
**Status**: Active Development
