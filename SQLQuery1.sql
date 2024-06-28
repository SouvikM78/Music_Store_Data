Use MusicStore_DB

Select * from employee;

Alter Table employee Alter Column birthdate datetime

Select top 1 levels from employee order by levels Desc

select * from employee Where levels = (Select max(levels) from employee)     -- or
select * from employee Where levels = (Select top 1 levels from employee order by levels Desc)  -- To select the top levels of levels column and select entire row based on that

Select * from employee order by levels Desc 

select * from invoice 

select Count(*) as State_count, billing_state from invoice    --Slecting total rows count and billing state to form a different table
group by billing_state                                        -- grouping according to billing state
order by State_count desc                                     -- sorting   


Select count(*) as Country_count, billing_country from invoice
group by billing_country
order by Country_count Desc                                   -- Most number biilng from the country

Select top 3 total, invoice_id from invoice order by total desc           -- order by to sort first the total in descendance order and then selecting top 3 from total column



Select * from invoice

Select sum(total) as city_total, billing_city from invoice
group by billing_city
order by city_total Desc                                        -- Prague has the best customer, it gave the highest billing total

Select * from invoice

Select sum(total) as bestCustomer_total, customer_id from invoice
group by customer_id
order by bestCustomer_total Desc                                 -- To find customer_id of best customer

Select * from customer where customer_id=5                       -- Frantisek Wichterlova is the best customer



Select customer.customer_id, customer.first_name, customer.last_name, customer.email, SUM(invoice.total) as bestCustomer_total 
from customer 
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name, customer.email
order by bestCustomer_total Desc                                  -- Using Join method

Select * from genre
select * from playlist
select * from playlist_track
Select * from track
Select * from customer
Select * from invoice_line
Select * from invoice
Select * from track
Select * from artist
Select * from album



Select distinct customer.first_name, customer.last_name, customer.email, genre.name from customer
join invoice on customer.customer_id=invoice.customer_id	
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id
join genre on track.genre_id=genre.genre_id
Where genre.name like 'Alternative & Punk'
order by email

--(
--Select name from genre
--join genre on track.genre_id=genre.genre_id
--where genre.name Like 'Rock'
--)


Select distinct artist.artist_id, artist.artist_name from artist
join album on artist.artist_id=album.artist_id
join track on track.album_id=album.album_id
join genre on track.genre_id=genre.genre_id
Where genre.name like 'Rock'
--group by artist.artist_id
--order by count(artist.artist_id) DESC


Select count(*) as track_count, album_id from track
where genre_id = 1
group by album_id
order by track_count Desc


                      
Select artist.artist_name, artist.artist_id, count(track.track_id) as songcount from track
join album on album.album_id = track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Metal'
group by artist.artist_name, artist.artist_id
order by songcount Desc                              -- will return the artist who written most rock genre song


EXEC sp_rename 'artist.name', 'artist_name', 'COLUMN';


Select name, milliseconds from track
Where milliseconds > (Select AVG(milliseconds) as 'average_song_length(ms)' from track)
order by milliseconds Desc                                     -- Return the song name and milliseconds greater than average song length 



Select customer.customer_id, customer.first_name, artist.artist_name, count(invoice_line.track_id) as 'No of songs purchased per Artist', 
sum(invoice_line.quantity*invoice_line.unit_price) as 'Total Spent on each artist' from customer
join invoice on customer.customer_id=invoice.customer_id	
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id
join album on track.album_id= album.album_id
join artist on album.artist_id=artist.artist_id
group by customer.customer_id,customer.first_name, artist.artist_name
order by sum(invoice_line.quantity*invoice_line.unit_price) Desc 
-- Alternative Way

With best_selling_artist as (
Select artist.artist_name, artist.artist_id --count(artist.artist_name) as No_of_songs_purchased_per_Artist, 
--sum(invoice_line.quantity*invoice_line.unit_price) as Total_Spent_on_each_artist 
from invoice_line
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by artist.artist_name, artist.artist_id
--order by No_of_songs_purchased_per_Artist desc
)
Select customer.customer_id, customer.first_name, best_selling_artist.artist_name, count(invoice_line.track_id) as No_of_songs_purchased_per_Artist, 
sum(invoice_line.unit_price*invoice_line.quantity) as total_spent_on_each_artist
from invoice_line
join invoice on invoice_line.invoice_id=invoice.invoice_id
join customer on customer.customer_id=invoice.customer_id
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
--join artist on artist.artist_id=album.artist_id
join best_selling_artist on best_selling_artist.artist_id=album.artist_id
group by customer.customer_id,customer.first_name, best_selling_artist.artist_name
order by total_spent_on_each_artist desc;                 -- To return most purchased artist


With popular_genre as
(
Select invoice.billing_country, genre.name, genre.genre_id, count(track.genre_id) as highest_selling_genre,
ROW_NUMBER() over (partition by invoice.billing_country order by count(track.genre_id) desc) as Row_No
from invoice
	join invoice_line on invoice.invoice_id=invoice_line.invoice_id
	join track on track.track_id=invoice_line.track_id
	join genre on genre.genre_id=track.genre_id
group by invoice.billing_country, genre.name, genre.genre_id
)
Select * FROM popular_genre WHERE Row_No <=1
order by billing_country                                              -- To return most purchased genre from each country



--Select count(genre.name), (genre.name) from genre

-- Alternative way

With  
	Sales_per_country as(
	select count(*) as purchases_per_genre, customer.country, genre.name, genre.genre_id
	from invoice_line
	join invoice on invoice.invoice_id=invoice_line.invoice_id
	join customer on customer.customer_id=invoice.customer_id
	join track on track.track_id=invoice_line.track_id
	join genre on genre.genre_id=track.genre_id 
	group by customer.country, genre.name, genre.genre_id
	--order by customer.country
	),
    max_genre_per_country as (Select Max(purchases_per_genre) as max_genre_number, country
	from Sales_per_country
	group by country
	--order by 2
	)
Select Sales_per_country.* From Sales_per_country
join max_genre_per_country on max_genre_per_country.country=Sales_per_country.country
where Sales_per_country.purchases_per_genre=max_genre_per_country.max_genre_number
order by Sales_per_country.country                             -- To return most purchased genre from each country





With most_music_listener as
(
Select invoice.billing_country, customer.first_name, customer.customer_id, 
round(sum(invoice_line.quantity*invoice_line.unit_price),2, -1) as total_spent,
ROW_NUMBER() over (partition by invoice.billing_country order by round(sum(invoice_line.quantity*invoice_line.unit_price),2, -1) desc) as Row_No
from invoice
	join customer on customer.customer_id=invoice.customer_id
	join invoice_line on invoice_line.invoice_id=invoice.invoice_id
group by invoice.billing_country, customer.first_name, customer.customer_id
)
Select * FROM most_music_listener WHERE Row_No <=10
order by billing_country                              -- To return most music listener from each country




















