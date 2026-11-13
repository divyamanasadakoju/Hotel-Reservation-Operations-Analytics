-- create database 

create database hospitality_db;

use hospitality_db;

-- create tables

-- guests table

create table guests (   guest_id varchar(20) primary key,
						guest_name varchar(100) not null,
                        city varchar(50),
                        guest_type varchar(20) not null,
                        preferred_room_type varchar(20) default 'standard',
                        loyalty_teir varchar(20),
                        account_since date );

-- hotels table
                        
create table hotels (   hotel_id varchar (20) primary key,
						hotel_name varchar(100) not null,
                        city varchar(50) not null,
                        star_rating int,
                        total_rooms int not null,
                        opened_date date,
                        check (total_rooms > 0),
                        check (star_rating between 1 and 5) );

-- staff table

create table staff (    staff_id varchar (20) primary key,
						staff_name varchar(100) not null,
                        hire_date date,
                        rating decimal (3,2),
                        department varchar (30) not null,
                        is_active varchar (3) default 'yes',
                        check (rating between 1 and 5),
                        check (is_active in ('Yes', 'No')));

-- rooms table
                        
create table rooms (    room_id varchar(20) primary key,
						hotel_id varchar(20) not null,
                        room_type varchar(20) not null default 'standard',
                        floor_number int not null,
                        max_occupancy int not null,
                        price_per_night Decimal(10,2) not null,
                        is_active varchar (3) default 'yes',
                        foreign key (hotel_id) references hotels(hotel_id),
                        check (is_active in ('Yes', 'No')),
                        check (max_occupancy > 0),
                        check (price_per_night >= 0) );
                        
-- bookings table 

create table bookings ( booking_id varchar (20) primary key,
						guest_id varchar(20) not null,
                        hotel_id varchar(20) not null,
                        booking_date date not null,
                        room_type_requested varchar(20),
                        booking_channel varchar (30) not null,
                        nights_booked int not null,
                        total_amount decimal (12,2) not null,
                        foreign key (guest_id) references guests(guest_id),
                        foreign key (hotel_id) references hotels(hotel_id),
                        check (nights_booked >0),
                        check (total_amount >= 0) );
                        
-- stays table

                        
create table stays (    stay_id varchar (20) primary key,
						booking_id varchar (20) not null,
                        room_id varchar(20) not null,
                        staff_id varchar (20) not null,
                        check_in_date date not null,
                        check_out_date date not null,
                        status varchar(20) not null default 'booked',
                        nights_stays int default 0,
                        service_requests int default 0,
                        stay_duration_hrs int default 0,
                        foreign key (booking_id) references bookings(booking_id),
                        foreign key (room_id) references rooms(room_id),
                        foreign key (staff_id) references staff(staff_id),
                        check (check_out_date >= check_in_date),
                        check (nights_stays >= 0),
                        check (service_requests >= 0),
                        check (stay_duration_hrs >= 0) );
                        
                        
 -- show tables
 
 show tables ; 
 
 show create table stays;
 
 desc stays;
 
 -- to test the imported data 
 
SELECT * FROM guests;
 
SELECT * FROM rooms;
 
 -- Sprint 3: Basic Analysis / Data Exploration
 
-- 1. What is the total number of guests?
SELECT 
    COUNT(*) AS total_guests
FROM
    guests;

-- 2. What is the total number of bookings?
SELECT 
    COUNT(*) AS total_bookings
FROM
    bookings;

-- 3. What is the total number of stays?
SELECT 
    COUNT(*) AS total_stays
FROM
    stays;

-- 4. What are the different room types available?
SELECT DISTINCT
    room_type
FROM
    rooms;

-- 5. How many staff members are currently active?
SELECT 
    COUNT(staff_id) AS active_staff
FROM
    staff
WHERE
    is_active = 'yes';

-- 6. What are the different booking channels?
SELECT DISTINCT
    booking_channel
FROM
    bookings;

-- 7. What is the total booking amount across all bookings?
SELECT 
    SUM(total_amount) AS total_amount
FROM
    bookings;

-- 8. What is the average nights booked per booking?
SELECT 
    AVG(nights_booked) AS avg_nights
FROM
    bookings;

-- Sprint 4: Objective-Based Analysis
 
-- 4.1 Understand Booking Demand
-- Business Objective: The Operations team wants to understand where and how bookings are being generated.

-- Compare the number of bookings across hotels.
SELECT h.hotel_name, h.hotel_id, COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN hotels h ON b.hotel_id = h.hotel_id
GROUP BY h.hotel_id
ORDER BY total_bookings DESC;

-- Hotel StayPoint Kolkata Residency with hotel_id H004 has the highest number of bookings.

-- Compare bookings across different booking channels.
SELECT booking_channel, COUNT(*) AS total_bookings
FROM bookings
GROUP BY booking_channel
ORDER BY total_bookings DESC;

-- Highest number of bookings are generated by the Website booking channel.

-- Compare bookings based on room type requested.
SELECT room_type_requested, COUNT(*) AS requested_bookings
FROM bookings
GROUP BY room_type_requested
ORDER BY requested_bookings DESC;

-- Most number of bookings are requested for 'Standard' type of rooms.

-- Examine how booking volume changes over time.
SELECT 
    YEAR(booking_date) AS booking_year,
    MONTH(booking_date) AS booking_month,
    COUNT(booking_id) AS total_bookings
FROM bookings
GROUP BY booking_year , booking_month
ORDER BY total_bookings DESC;

 -- hihgest number of bookings are made in july month of 2026.

-- Look at the booking amount across different groups.
SELECT 
    booking_channel,
    COUNT(booking_id) AS total_bookings,
    SUM(total_amount) AS total_amount
FROM bookings
GROUP BY booking_channel
ORDER BY total_amount DESC;

-- Through Websites booking channel the highest number of bookings 984 are made and generated  15298855.41 total amount.

-- hotels generate the highest total booking amount
SELECT h.hotel_name,
    SUM(b.total_amount) AS total_amount,
    COUNT(b.booking_id) AS total_bookings
FROM hotels h JOIN bookings b ON b.hotel_id = h.hotel_id
GROUP BY hotel_name
ORDER BY total_amount DESC;
 
 -- StayPoint Mumbai Grand has the highest number of bookings and generated the total amount of 3773668.50.
 
 
-- 4.2 Understand Guest Booking Behaviour

-- Compare guests based on the number of bookings they make.
SELECT g.guest_type, COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN guests g ON g.guest_id = b.guest_id
GROUP BY guest_type
ORDER BY total_bookings DESC;

-- individual guests are booking (1903) more than corporate guests bookings (897) 

-- Identify guests with a higher total booking amount.
SELECT g.guest_id, g.guest_name, g.guest_type,
    SUM(total_amount) AS total_amount
FROM bookings b
JOIN guests g ON g.guest_id = b.guest_id
GROUP BY guest_id
ORDER BY total_amount DESC;

-- A corporate guest with name Gwendolyn Klein and guest id G0350 has generated the highest total booking amount of 1196045.76 . 
 
-- Compare guest activity across hotels.
SELECT  g.guest_id, g.guest_name, h.hotel_name,
    COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN hotels h ON h.hotel_id = b.hotel_id
JOIN guests g ON g.guest_id = b.guest_id
GROUP BY g.guest_id , h.hotel_id
ORDER BY total_bookings DESC;

-- Across different hotel bookings by differnt guests Davis-Lewis with guest id G0265 has made highest number of bookgs of 7 in the hotel StayPoint Mumbai Suites.

-- Look at differences between Individual and Corporate guests.
SELECT g.guest_type,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_amount
FROM bookings b
JOIN guests g ON g.guest_id = b.guest_id
GROUP BY guest_type
ORDER BY total_amount DESC;

-- individual guests made more bookings with value of 31394351.96 then the corporate guests bookings 897 with value 14428826.77.

-- Examine guest booking patterns over time.
SELECT  YEAR(booking_date) AS booking_time, COUNT(booking_id) AS total_bookings
FROM bookings
GROUP BY YEAR(booking_date)
ORDER BY total_bookings DESC;

-- the number of booking in the year 2025 is highest with 1048, where it decreased in 2026 with 867 than thebookings in 2024 with 885.


-- 4.3 Evaluate Stay Performance

-- Compare stay outcomes across different hotels (hotel information is on the bookings table, so you will need to connect bookings and stays).
SELECT  h.hotel_id, h.hotel_name,
    COUNT(DISTINCT s.stay_id) AS total_stays
FROM stays s
JOIN bookings b ON b.booking_id = s.booking_id
JOIN hotels h ON h.hotel_id = b.hotel_id
WHERE s.status = 'Checked-out'
GROUP BY h.hotel_id
ORDER BY total_stays DESC;

-- hotel StayPoint Mumbai Suites with hotel id H006 has highest stays of 98 which are completed successfully.

-- Examine stay duration.
SELECT  h.hotel_name, h.hotel_id,
    AVG(s.stay_duration_hrs) AS average_stay_duration
FROM stays s
JOIN bookings b ON b.booking_id = s.booking_id
JOIN hotels h ON h.hotel_id = b.hotel_id
GROUP BY h.hotel_id
ORDER BY average_stay_duration DESC;

-- hotel StayPoint Pune Plaza has the highest stay duration of 67 hours across all. 

-- Compare stay outcomes by status (Checked-out, No-show, Cancelled, In-progress) — these are not a simple success/failure split, so consider what each status actually represents.

SELECT status,
    COUNT(stay_id) AS total_stays,
    ((COUNT(stay_id) * 100) / (SELECT COUNT(*) FROM stays)) AS percentage
FROM stays
GROUP BY status
ORDER BY total_stays DESC;

-- the stays that are completed with status checked out are more with 66 percent then other incompleted stays like no-show 16%, cancelled 15% and in-progress 1%. 

-- Identify hotels with higher booking activity or poorer outcomes.
SELECT h.hotel_name, h.hotel_id,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    COUNT(DISTINCT stay_id) AS total_stays
FROM stays s
JOIN bookings b ON b.booking_id = s.booking_id
JOIN hotels h ON h.hotel_id = b.hotel_id
GROUP BY hotel_id
ORDER BY total_stays DESC;

-- hotel StayPoint Mumbai Suites has the highest booking activity with 152 stays and 119 bookings

SELECT h.hotel_name, h.hotel_id,
    COUNT(DISTINCT s.stay_id) AS poor_stays
FROM stays s
JOIN bookings b ON b.booking_id = s.booking_id
JOIN hotels h ON h.hotel_id = b.hotel_id
WHERE s.status IN ('Cancelled' , 'No-show')
GROUP BY hotel_id
ORDER BY poor_stays DESC;

-- hotel StayPoint Mumbai Suites 53 , StayPoint Indore Plaza 53 , and StayPoint Delhi Retreat 52 has the poorer outcomes of stays across all hotels. 

-- Compare stay performance over time.
SELECT YEAR(s.check_in_date), COUNT(s.stay_id) AS total_stays
FROM stays s
JOIN bookings b ON b.booking_id = s.booking_id
JOIN hotels h ON h.hotel_id = b.hotel_id
WHERE s.status = 'Checked-out'
GROUP BY YEAR(s.check_in_date)
ORDER BY total_stays DESC;

-- 2025 has peaked with highest number of successfull stays of 787 , while 2026 has 678 and 2024 has 652.


-- 4.4 Understand Staff and Room Performance

-- Compare the number of stays handled by staff members.
SELECT  s.staff_id, s.staff_name, COUNT(t.stay_id) AS total_stays
FROM staff s
JOIN stays t ON s.staff_id = t.staff_id
GROUP BY s.staff_id
ORDER BY total_stays DESC;

-- most of the staff members served around 57 to 40 stays and Anthony Humphrey with staff id S044 seerved the highest stays of 59.

-- compare staff performance across stay outcomes.
SELECT s.staff_id, s.staff_name, t.status,
    COUNT(t.stay_id) AS total_stays
FROM staff s
JOIN stays t ON s.staff_id = t.staff_id
GROUP BY s.staff_id , t.status
ORDER BY total_stays DESC;

-- most of the staffs serve around 40 to 30 successfull stays that are checked_out, Anthony Humphrey served 44 successfull stays highest and most of the satff server below 15 stays which are no-show or cancelled.

-- Examine stay duration across staff members.
SELECT s.staff_id, s.Staff_name,
    AVG(t.stay_duration_hrs) AS duration_hrs
FROM staff s
JOIN stays t ON s.staff_id = t.staff_id
GROUP BY s.staff_id
ORDER BY duration_hrs DESC;

-- the highest stay duration is served by Holly Wood of 77 hrs and most of the staff served 60 to 40 hours.

-- Compare room usage across different room types.
SELECT r.room_type, COUNT(DISTINCT s.stay_id) AS total_stays
FROM rooms r
JOIN stays s ON r.room_id = s.room_id
WHERE s.status = 'Checked-out'
GROUP BY r.room_type
ORDER BY total_stays DESC;

-- standard rooms are more used in 951 stays adn Deluxe 661, Suite rooms 315 and Executive rooms used in 190 stays.

-- Look at stay performance across different rooms.

SELECT  h.hotel_name, r.room_type, r.room_id,
    COUNT(DISTINCT s.stay_id) AS total_stays
FROM rooms r
JOIN stays s ON r.room_id = s.room_id
JOIN hotels h ON h.hotel_id = r.hotel_id
WHERE s.status = 'Checked-out'
GROUP BY r.room_id
ORDER BY total_stays DESC;

-- standard room from StayPoint Chandigarh Retreat with room id R00193 and Suite room from StayPoint Mumbai Residency with room id R00327 are more avtive with 11 stays.

-- stays handle by active and inactive staff members
SELECT s.is_active, COUNT(t.stay_id) AS total_stays
FROM staff s
JOIN stays t ON s.staff_id = t.staff_id
GROUP BY s.is_active
ORDER BY total_stays DESC;

-- the active staff serve more stays of 2877 than the inactive staff members serve stays of 323.

-- 4.5 Identify Booking and Stay Problems

-- Examine which bookings resulted in cancellations or no-shows.
SELECT  b.booking_id, h.hotel_name, g.guest_name, b.booking_date, s.status
FROM bookings b
JOIN hotels h ON h.hotel_id = b.hotel_id
JOIN guests g ON g.guest_id = b.guest_id
JOIN stays s ON s.booking_id = b.booking_id
WHERE s.status IN ('No-show' , 'Cancelled');

-- among all around 1000 bookings resukted in cellations or no-shows.


-- Identify common stay statuses and problem patterns.
SELECT  status, COUNT(stay_id) AS total_stays
FROM stays
GROUP BY status
ORDER BY total_stays DESC;

-- most of the stays are successfull wich are checked-out, but 542 stays are no-show and 480  are cancelled.

-- Compare stay performance for bookings with high service request counts.
SELECT  service_requests, status,
    COUNT(booking_id) AS total_bookings
FROM stays
GROUP BY service_requests , status
ORDER BY total_bookings DESC;

-- highest number of bookings are done with 1 service request and which is successfull with checked-out status.

-- Examine whether certain hotels experience more booking problems.
SELECT  h.hotel_name, COUNT(s.stay_id) AS stay_issues
FROM stays s
JOIN rooms r ON r.room_id = s.room_id
JOIN hotels h ON h.hotel_id = r.hotel_id
WHERE s.status IN ('No-show' , 'Cancelled')
GROUP BY h.hotel_name
ORDER BY stay_issues DESC;

-- hotel StayPoint Mumbai Residency has the highest number of booking problems of 84.

-- hotels with highest number of stays with average service requests

SELECT h.hotel_name, AVG(s.service_requests) AS avg_requests
FROM stays s
JOIN rooms r ON r.room_id = s.room_id
JOIN hotels h ON h.hotel_id = r.hotel_id
GROUP BY h.hotel_name
ORDER BY AVG(s.service_requests) DESC;

-- hotels StayPoint Kochi Retreat, StayPoint Goa Grand, StayPoint Mumbai Grand has the highest average service requests.

