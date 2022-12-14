/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

A1: Select name from Facilities
    Where membercost = 0

/* Q2: How many facilities do not charge a fee to members? */

A2: Select count(name) from Facilities
    Where membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

A3: select facid, name, membercost, monthlymaintenance from Facilities
    where membercost > 0 AND membercost < 0.2 * monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

A4: select * from Facilities
    where facid in (1, 5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

A5: select name, monthlymaintenance,
     case when monthlymaintenance > 100 then 'expensive'
     else 'cheap'
    end as cost
    from Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

A6: select surname, firstname from Members
    where joindate = (Select max(joindate) from Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

A7: select distinct concat_ws(' ', M.firstname, M.surname) as name, F.name
    from Members as M
    join Bookings as B
    on B.memid = M.memid and B.memid <> 0
    join Facilities as F
    on F.facid = B.facid
    where F.name is not null and F.name like 'Ten%'
    order by name

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
//NEEDS WORK
A8: select F.name, concat_ws(' ', M.firstname, M.surname) as name, 
    case when B.memid = 0 then F.guestcost * B.slots
    else F.membercost * B.slots
    end as cost
    from Facilities as F
    left join Bookings as B
    on starttime like '2012-09-14%' and B.facid = F.facid
    left join Members as M
    on M.memid = B.memid
    order by cost desc

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

A9: select J.name, concat_ws(' ', M.firstname, M.surname) as name, J.cost
    from Members as M
    left join (Select F.name, B.memid,
           case when B.memid = 0 then F.guestcost * B.slots
           else F.membercost * B.slots
           end as cost
           from Facilities as F
           left join Bookings as B
           on B.facid = F.facid
           where starttime like '2012-09-14%') as J
    on J.memid = M.memid
    where J.cost > 30
    order by J.cost desc

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

A10:    select F.name, revG + revM as revenue
        from Facilities as F
        left join (select count(B.bookid) * F.guestcost as revG, F.facid
            from Facilities as F
            left join Bookings as B
            on B.facid = F.facid
            where B.memid = 0
            group by F.facid) as G
        on G.facid = F.facid
        left join (select count(B.bookid) * F.membercost as revM, F.facid
            from Facilities as F
            left join Bookings as B
            on B.facid = F.facid
            where B.memid <> 0
            group by F.facid) as M
        on M.facid = F.facid
        where revenue < 1000
        group by F.name
        order by revenue 
        
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

A11: select distinct M1.surname || ', ' || M1.firstname, M2.surname || ', ' ||   M2.firstname
        from Members as M1
        left join Members as M2
        on M1.recommendedby = M2.memid
        order by M1.surname, M1.firstname

/* Q12: Find the facilities with their usage by member, but not guests */

A12: select F.name, count(bookid)
        from Bookings as B
        left join Facilities as F
        on F.facid = B.facid
        where memid <> 0
        group by B.facid

/* Q13: Find the facilities usage by month, but not guests */

A13: select F.name, count(bookid),
        case when starttime like '2012-07%' then 'July'
        when starttime like '2012-08%' then 'Aug'
        else 'Sept'
        end as Month
        from Bookings as B
        left join Facilities as F
        on F.facid = B.facid
        where memid <> 0
        group by Month, F.facid
