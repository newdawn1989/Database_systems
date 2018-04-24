USE sales_dw;
SET SQL_SAFE_UPDATES = 0;
drop TABLE if exists Dim_Customer;

CREATE TABLE Dim_Customer (
CustomerID INT PRIMARY KEY AUTO_INCREMENT,
CustomerAltID VARCHAR(10) NOT NULL,
CustomerName VARCHAR(50),
Gender VARCHAR(2)
);

INSERT INTO Dim_Customer(CustomerAltID,CustomerName,Gender)VALUES
('IMI-001','Harrison Ford','M'),
('IMI-002','Melinda Gates','F'),
('IMI-003','Elon Musk','M'),
('IMI-004','Aldous Huxley','M'),
('IMI-005','Linda Ronstadt','F');

DROP TABLE IF EXISTS Dim_Date;

CREATE TABLE	Dim_Date
	(	DateKey INT PRIMARY KEY AUTO_INCREMENT, 
		DATE DATETIME,
		DAYOFMONTH VARCHAR(2), -- Field will hold day number of Month
		DAYNAME VARCHAR(9), -- Contains name of the day, Sunday, Monday 
		DayOfWeekInMonth VARCHAR(2), -- 1st Monday or 2nd Monday in Month
		DayOfWeekInYear VARCHAR(2),
		DayOfQuarter VARCHAR(3),
		DAYOFYEAR VARCHAR(3),
		WeekOfMonth VARCHAR(1), -- Week Number of Month 
		WeekOfQuarter VARCHAR(2), -- Week Number of the Quarter
		WEEKOFYEAR VARCHAR(2), -- Week Number of the Year
		MONTH VARCHAR(2), -- Number of the Month 1 to 12
		MONTHNAME VARCHAR(9), -- January, February etc
		QUARTER CHAR(1),
		QuarterName VARCHAR(9), -- First,Second..
		YEAR CHAR(4) -- Year value of Date stored in Row

	);
	
	/* Adapted from Tom Cunningham's 'Data Warehousing with MySql' (www.meansandends.com/mysql-data-warehouse) */ 
 
 ###### small-numbers table 
 DROP TABLE IF EXISTS numbers_small; 
 CREATE TABLE numbers_small (number INT); 
 INSERT INTO numbers_small VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9); 
 
 
 ###### main numbers table 
 DROP TABLE IF EXISTS numbers; 
 CREATE TABLE numbers (number BIGINT); 
 INSERT INTO numbers 
 SELECT thousands.number * 1000 + hundreds.number * 100 + tens.number * 10 + ones.number 
   FROM numbers_small thousands, numbers_small hundreds, numbers_small tens, numbers_small ones 
 LIMIT 1000000; 
 

 ###### date table 
 DROP TABLE IF EXISTS dates; 
 CREATE TABLE dates ( 
   date_id          BIGINT PRIMARY KEY,  
   DATE             DATE NOT NULL, 
   TIMESTAMP        BIGINT ,  
   weekend          CHAR(10) NOT NULL DEFAULT "Weekday", 
   day_of_week      CHAR(10) , 
   MONTH            CHAR(10) , 
   month_day        INT ,  
   YEAR             INT , 
   week_starting_monday CHAR(2) , 
   UNIQUE KEY `date` (`date`), 
   KEY `year_week` (`year`,`week_starting_monday`) 
 ); 
 

 ###### populate it with days 
 INSERT INTO dates (date_id, DATE) 
 SELECT number, DATE_ADD( '2010-01-01', INTERVAL number DAY ) 
   FROM numbers 
   WHERE DATE_ADD( '2010-01-01', INTERVAL number DAY ) BETWEEN '2010-01-01' AND '2020-01-01' 
   ORDER BY number; 
 

 ###### fill in other rows 
 UPDATE dates SET 
   TIMESTAMP =   UNIX_TIMESTAMP(DATE), 
   day_of_week = DATE_FORMAT( DATE, "%W" ), 
   weekend =     IF( DATE_FORMAT( DATE, "%W" ) IN ('Saturday','Sunday'), 'Weekend', 'Weekday'), 
   MONTH =       DATE_FORMAT( DATE, "%M"), 
   YEAR =        DATE_FORMAT( DATE, "%Y" ), 
   month_day =   DATE_FORMAT( DATE, "%d" ); 
 

 UPDATE dates SET week_starting_monday = DATE_FORMAT(DATE,'%v'); 
 
INSERT INTO Dim_Date (DATE, DAYOFMONTH, YEAR, DAYNAME, MONTHNAME)
	SELECT DATE, month_day, YEAR, day_of_week, MONTH FROM dates;
	
UPDATE Dim_Date SET 
   MONTH = MONTH(DATE),
   QUARTER = QUARTER(DATE),
   DAYOFYEAR = DAYOFYEAR(DATE),
   WEEKOFYEAR = WEEKOFYEAR(DATE);

DROP TABLE IF EXISTS Dim_Product;

CREATE TABLE Dim_Product
(
ProductKey INT PRIMARY KEY AUTO_INCREMENT,
ProductAltKey VARCHAR(10)NOT NULL,
ProductName VARCHAR(100),
ProductActualCost DECIMAL(9,2),
ProductSalesPrice DECIMAL(9,2)

);

INSERT INTO Dim_Product(ProductAltKey,ProductName, ProductActualCost, ProductSalesPrice)VALUES
('ITM-001','Wheat Flour 1kg',5.50,6.50),
('ITM-002','Jasmine Rice 5kg',22.50,24),
('ITM-003','SunFlower Oil 1 ltr',42,43.5),
('ITM-004','Dawn Dish Soap, case',18,20),
('ITM-005','Tide Laundry Detergent 1kg case',135,139);

DROP TABLE IF EXISTS Dim_SalesPerson; 

CREATE TABLE Dim_SalesPerson
(
SalesPersonID INT PRIMARY KEY AUTO_INCREMENT,
SalesPersonAltID VARCHAR(10)NOT NULL,
SalesPersonName VARCHAR(100),
StoreID INT,
City VARCHAR(100),
State VARCHAR(100),
Country VARCHAR(100)
);

INSERT INTO Dim_SalesPerson(SalesPersonAltID,SalesPersonName,StoreID,City,State,Country )VALUES
('SP-DMSPR1','Tom Petty',1,'Boulder','CO','USA'),
('SP-DMSPR2','John Paul Jones',1,'Longmont','CO','USA'),
('SP-DMNGR1','Danny Weller',2,'Berthoud','CO','USA'),
('SP-DMNGR2','Julian Brand',2,'Lyons','CO','USA'),
('SP-DMSVR1','Jasmin Farah',3,'Louisville','CO','USA'),
('SP-DMSVR2','Jacob Leis',3,'Lafayette','CO','USA');

DROP TABLE IF EXISTS Dim_Store;

CREATE TABLE Dim_Store
(
StoreID INT PRIMARY KEY AUTO_INCREMENT,
StoreAltID VARCHAR(10)NOT NULL,
StoreName VARCHAR(100),
StoreLocation VARCHAR(100),
City VARCHAR(100),
State VARCHAR(100),
Country VARCHAR(100)
);

INSERT INTO Dim_Store(StoreAltID,StoreName,StoreLocation,City,State,Country )VALUES
('LOC-A1','ValueMart Boulder','1234 Ringer Road','Boulder','CO','USA'),
('LOC-A2','ValueMart Lyons','8624 Fenton Park','Lyons','CO','USA'),
('LOC-A3','ValueMart Berthoud','9337 Cherry Lane','Berthoud','CO','USA');

DROP TABLE IF EXISTS fact_productsales;

CREATE TABLE Fact_ProductSales
(
TransactionId BIGINT PRIMARY KEY AUTO_INCREMENT,
SalesInvoiceNumber INT NOT NULL,
SalesDateKey INT,
StoreID INT NOT NULL,
CustomerID INT NOT NULL,
ProductID INT NOT NULL,
SalesPersonID INT NOT NULL,
ProductCost DECIMAL(9,2),
SalesPrice DECIMAL(9,2),
Quantity INTEGER

);

INSERT INTO Fact_ProductSales(SalesInvoiceNumber,SalesDateKey,
StoreID,CustomerID,ProductID ,
SalesPersonID,Quantity,ProductCost,SalesPrice)VALUES
-- 1-jan-2013
(1,1097,1,1,1,1,2,11,13),
(1,1097,1,1,2,1,1,22.50,24),
(1,1097,1,1,3,1,1,42,43.5),

(2,1097,1,2,3,1,1,42,43.5),
(2,1097,1,2,4,1,3,54,60),

(3,1097,1,3,2,2,2,11,13),
(3,1097,1,3,3,2,1,42,43.5),
(3,1097,1,3,4,2,3,54,60),
(3,1097,1,3,5,2,1,135,139),

-- 2-feb-2013

(4,1129,1,1,1,1,2,11,13),
(4,1129,1,1,2,1,1,22.50,24),

(5,1129,1,2,3,1,1,42,43),
(5,1129,1,2,4,1,3,54,60),

(6,1129,1,3,2,2,2,11,13),
(6,1129,1,3,5,2,1,135,139),

(7,1129,2,1,4,3,3,54,60),
(7,1129,2,1,5,3,1,135,139),

-- 3-mar-2013

(8,1158,1,1,3,1,2,84,87),
(8,1158,1,1,4,1,3,54,60),

(9,1158,1,2,1,1,1,5.5,6.5),
(9,1158,1,2,2,1,1,22.50,24),

(10,1158,1,3,1,2,2,11,13),
(10,1158,1,3,4,2,3,54,60),

(11,1158,2,1,2,3,1,5.5,6.5),
(11,1158,2,1,3,3,1,42,43.5);


ALTER TABLE Fact_ProductSales ADD CONSTRAINT 
FK_StoreID FOREIGN KEY (StoreID)REFERENCES Dim_Store(StoreID);

ALTER TABLE Fact_ProductSales ADD CONSTRAINT 
FK_CustomerID FOREIGN KEY (CustomerID)REFERENCES Dim_customer(CustomerID);

ALTER TABLE Fact_ProductSales ADD CONSTRAINT 
FK_ProductKey FOREIGN KEY (ProductID)REFERENCES Dim_product(ProductKey);

ALTER TABLE Fact_ProductSales ADD CONSTRAINT 
FK_SalesPersonID FOREIGN KEY (SalesPersonID)REFERENCES Dim_salesperson(SalesPersonID);

ALTER TABLE Fact_ProductSales ADD CONSTRAINT 
FK_SalesDateKey FOREIGN KEY (SalesDateKey)REFERENCES Dim_Date(DateKey);

SELECT table_name, table_rows 
	FROM information_schema.tables
	WHERE TABLE_NAME  LIKE 'dim_%'
	OR TABLE_NAME  LIKE 'fact_%';

 
