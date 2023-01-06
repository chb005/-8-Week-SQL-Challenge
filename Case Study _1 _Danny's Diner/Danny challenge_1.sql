/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

     select* from sales;
     select * from menu;
     
     select s."customer_id",sum("price") as "Total Price"
     from sales s inner join menu m
     on s."product_id"=m."product_id"
     group by s."customer_id"
     order by 2 desc;
    
     
-- 2. How many days has each customer visited the restaurant?
     select* from sales;
     select * from menu;
     select * from members;
     
     select "customer_id",count(distinct("order_date")) as "Cust_count"
     from sales group by 1 order by 2 desc;

-- 3. What was the first item from the menu purchased by each customer?
    with first_item as
    (
      select s."customer_id",s."order_date",m."product_name",
      dense_rank() over (partition by s."customer_id" order by "order_date") as rank1  
      from sales s join menu m on s."product_id"=m."product_id"
    )
    select "customer_id","product_name","order_date"    
    from first_item
    where rank1<2
    order by 1,2;
    
    

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
   with extra as(
   select count(s."product_id") as most_buy_product,m."product_name" 
    from sales s join menu m
    on s."product_id"=m."product_id"
    group by s."product_id",2
    order by 1 desc
    )
    select "product_name",most_buy_product from extra limit 2;

-- 5. Which item was the most popular for each customer?
   WITH famous_food AS
   (
	SELECT 
    s."customer_id", 
    m."product_name", 
    COUNT(m."product_id") AS or_cnt,
		DENSE_RANK() OVER(PARTITION BY s."customer_id" ORDER BY COUNT(s."customer_id") DESC) AS rank
    FROM menu m
    JOIN    sales s
        ON m."product_id" = s."product_id"
    GROUP BY s."customer_id", m."product_name"
    )
   SELECT 
      "customer_id", 
      "product_name", 
       or_cnt
   FROM famous_food
   WHERE rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
    select * from sales;
    select * from menu;
    select * from members;
    
   with first_item as(
    select s."customer_id",s."order_date",m."product_id",m."product_name" ,
       dense_rank() over(partition by s."customer_id" order by s."order_date") as rnk
    from sales s join members me
    on s."customer_id"=me."customer_id"
    join menu m on m."product_id"=s."product_id"
    where s."order_date" >= me."join_date"
    )
    
    select "customer_id","order_date","product_id","product_name" 
    from first_item where rnk<=1;
        
    
-- 7. Which item was purchased just before the customer became a member?
       with first_item as(
    select s."customer_id",s."order_date",m."product_id",m."product_name" ,
       dense_rank() over(partition by s."customer_id" order by s."order_date" desc) as rnk
    from sales s join members me
    on s."customer_id"=me."customer_id"
    join menu m on m."product_id"=s."product_id"
    where s."order_date" < me."join_date"
    )
    
    select "customer_id","order_date","product_id","product_name" 
    from first_item where rnk=1;
-- 8. What is the total items and amount spent for each member before they became a member?
    select s."customer_id",count(distinct s."product_id")as "unique_count",sum(m."price") as "Total"
    from sales s join menu m
    on s."product_id"=m."product_id"
    join members me 
    on s."order_date"<me."join_date"
    group by 1;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

        with ptotal as(
        select *,
            case when "product_name"='sushi' then "price"*20
            else "price"*10
            end AS points
        from menu
        )
        select s."customer_id",
        sum(p.points) as total_amt
        from ptotal p
        join sales s on p."product_id"=s."product_id"
        group by 1;
        
 --10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 
    
    WITH last_day_cte AS
	  (SELECT "join_date",
			  DATEADD(DAY,6,"join_date") AS program_last_date,
			  "customer_id"
	   FROM members)
		SELECT s."customer_id",
			   SUM(CASE
					   WHEN "order_date" BETWEEN "join_date" AND program_last_date THEN "price"*10*2
					   WHEN "order_date" NOT BETWEEN "join_date" AND program_last_date
							AND "product_name" = 'sushi' THEN "price"*10*2
					   WHEN "order_date" NOT BETWEEN "join_date" AND program_last_date
							AND "product_name" != 'sushi' THEN "price"*10
				   END) AS customer_points
		FROM menu m
		JOIN sales s ON m."product_id" = s."product_id"
		INNER JOIN last_day_cte AS mem ON mem."customer_id" = s."customer_id"
		AND "order_date" <='2021-01-31'
		AND "order_date" >="join_date"
		GROUP BY s."customer_id"
		ORDER BY s."customer_id";
 
    