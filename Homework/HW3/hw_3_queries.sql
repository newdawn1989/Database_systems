/*Initializing the database, showing the resilts of creating the new database*/
USE sales_dw;
SELECT table_name, table_rows 
	FROM information_schema.tables
	WHERE TABLE_NAME  LIKE 'dim_%'
	OR TABLE_NAME  LIKE 'fact_%';

    
/*
1. What is the total sales price for all items purchased by customer Melinda Gates?

To get the needed information, we need to join our Facts table with the customer dimension
from there, isolate based on customer name
*/ 
SELECT CustomerName, SUM(SalesPrice)
	FROM Fact_ProductSales f JOIN Dim_Customer c 
    ON f.CustomerID = c.CustomerID
    WHERE(c.CustomerName = "Melinda Gates");



/*
2. What is the total revenue by store for all items purchased in March 2013? (Total Revenue =
SalesPrice * Quantity)
Here we need to join our Facts table with two Dim tables, Date and Store in order to calculate the revenue from the given month
The month is selected by number (1-12 corresponding to January - December)
*/
SELECT storename, SUM(salesprice*quantity) AS Total_Rvenue_March_2013
	FROM Dim_Date d
		JOIN Fact_ProductSales f 
			ON f.SalesDateKey = d.DateKey
		JOIN Dim_Store s
			ON f.StoreID = s.StoreID
		WHERE(MONTH = "3")
        GROUP BY(StoreName);
        
        
        
        
/*
3. Who is the best performing SalesPerson? (That is, the salesperson with the highest total
revenue amount?)
We join the fact table with the sales person dimension then perform two subqueries:
The inner most to calculate the sales perfoemance of all the sales people, 
The outter subquery to select the MAX of the previous calcualtion which is then returned as our query answer 

*/

SELECT DISTINCT(Dim_SalesPerson.SalesPersonName), SUM(salesprice*quantity) AS Highest_revenue
    FROM Dim_SalesPerson JOIN Fact_ProductSales
        ON Dim_SalesPerson.SalesPersonID = Fact_ProductSales.SalesPersonID
        GROUP BY(Dim_SalesPerson.SalesPersonID)
			HAVING Highest_revenue = (SELECT MAX(revenue) AS 'Highest Revenue'
				FROM(SELECT SalesPersonID, SUM(Fact_ProductSales.SalesPrice * Fact_ProductSales.Quantity) AS revenue
					FROM Fact_ProductSales
						GROUP BY(Fact_ProductSales.SalesPersonID))T);

		
/*
4. Which product shows the largest profit from sales? (Profit = the difference between Total
Revenue (SalesPrice * Quantity ) and Total Cost (ProductCost * Quantity.))
Same process as used to find the top sales person, nested sub queries, the inner most one to find the profit of all products, the outter subquery to return the 
product with the MAX profit.
*/
SELECT Dim_Product.ProductName, SUM((Fact_ProductSales.salesprice*Fact_ProductSales.quantity)-(Fact_ProductSales.productcost*Fact_ProductSales.quantity)) AS Profit
	FROM Dim_Product, Fact_ProductSales
		WHERE(Dim_Product.ProductKey = Fact_ProductSales.ProductID)
        GROUP BY(Dim_Product.ProductKey)
			HAVING Profit = (SELECT MAX(revenue) AS Rev
				FROM(SELECT ProductID, SUM((Fact_ProductSales.SalesPrice*Fact_ProductSales.Quantity) - (Fact_ProductSales.ProductCost*Fact_ProductSales.quantity)) 
					AS revenue
					FROM Fact_ProductSales
						GROUP BY(Fact_ProductSales.ProductID))T);
	
    
    
/*
5. Describe the three month trend in total sales revenue comparing January, February, and March
2013.
After joing both date and store dimensions to the facts table, we simple use logical OR atatements in our WHERE clause to find the desired months
indicated by their corresponding numerical values.

The trend we notice is that sales go up in February over the previous month, and then fall sharply in March.
*/  
SELECT Dim_Date.MONTH AS 'MONTH', SUM(Fact_ProductSales.SalesPrice*Fact_ProductSales.Quantity) AS Month_total
	FROM Dim_Date 
		JOIN Fact_ProductSales 
			ON Fact_ProductSales.SalesDateKey = Dim_Date.DateKey
		JOIN Dim_Store 
			ON Fact_ProductSales.StoreID = Dim_Store.StoreID
		WHERE(Dim_Date.MONTH = "1" OR Dim_Date.MONTH = "2" OR Dim_Date.MONTH = "3")
			GROUP BY(Dim_Date.MONTH);