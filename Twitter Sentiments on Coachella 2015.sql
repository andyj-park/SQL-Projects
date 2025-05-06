/**
The Twitter Sentiment Analysis of Coachella 2015 dataset is a robust collection of tweets exhibiting public sentiment towards the Coachella 2015 music festival. Initially sourced from Crowdflower Data for Everyone and later modified, the dataset offers an intriguing insight into how social media users responded to one of the biggest music festivals on the globe.
Consisting of diverse dimensions such as 'retweet_count', 'tweet_coord', 'tweet_location', 'text', etc., this compilation provides multiple perspectives on Twitter activity related to Coachella 2015. The sentiment expressed in each tweet has been categorized under the column,’coachella_sentiment’. This classifies each entry as being either positive, negative or neutral towards Coachella festival lineup.
The ‘retweet_count’ column quantitatively reveals how viral various tweets became. Linked with this is ‘tweet_coord’, revealing geographical coordinates from where these opinions emanate - dependent on whether location sharing was enabled by users at the time of tweeting. On similar lines, we have ‘tweet_location’ that captures a user's specified location if they've opted-in for location inclusion.
Central to any analysis are columns like ‘text’, containing actual content forming basis for any sentiment analysis, along with information about Twitter users who posted these tweets under name. Also enhancing context are fields like ‘user_timezone’, providing insights into differing temporal contexts influencing user opinions and reactions across variable time zones.
Yet another important dimension in this set is 'coachela_yn'. It provides binary data specifying whether a tweet mentioned Coachella or not — integral to discerning between event-centric sentiments versus general ones associated with different artists performing at that event.
Lastly but critically important is tweet_created, documenting precise timings when each tweet was first broadcasted. As events unfold during a festival lineup announcement or throughout its progression can profoundly influence nature and orientation of reactions produced; thus making it relatively influential regarding pattern prediction efforts focused on such datasets.
In summary, the Coachella 2015 Sentiment Analysis on Twitter dataset encapsulates extensive data angles pertaining to tweet interactions about the Coachella 2015 event. Its comprehensive nature makes it a worthy choice for those interested in social media analysis, sentiment studies or even event management research concerning large-scale music festivals
**/ 

-- Create table
Create Table if not exists coachella_data(
	index_num Integer Primary Key Not Null
	, coachella_sentiment Varchar(255)
	, coachella_yn Varchar(255)
	, name Varchar(255)
	, retweet_count Integer
	, text Varchar(255)
	, tweet_coord Varchar(255)
	, tweet_created TEXT
	, tweet_id Numeric
	, tweet_location Varchar(255)
	, user_timezone Varchar(255)
);

-- Test the data import
select *
from coachella_data;

-- Count coachella_sentiment
select coachella_sentiment
, count(coachella_sentiment) as count
from coachella_data cd
group by cd.coachella_sentiment;
-- Categories were: positive (2283), neutral (928), negative (553), & cant tell (82)

-- Count coachella_yn (this indicates whether Coachella was explicitly mentioned
-- in the tweet)
select coachella_yn
, count(coachella_yn) as count
from coachella_data cd
group by cd.coachella_yn;
-- Looks like every tweet did mention Coachella

-- Let's take a look at the most retweeted tweets, from highest to lowest
select index_num
, name 
, coachella_sentiment
, retweet_count
, text
from coachella_data cd
order by cd.retweet_count desc;
-- There are 52 tweets that have more than 10 retweets

-- Out of those 52 tweets, 23 were positive, 27 were neutral, and 2 were can't tell
select coachella_sentiment
, count(coachella_sentiment) as count
from coachella_data cd
where retweet_count > 10
group by cd.coachella_sentiment;

-- Split the datetime column into time and date
ALTER TABLE coachella_data ADD COLUMN tweet_date TEXT;
ALTER TABLE coachella_data ADD COLUMN tweet_time TEXT;

UPDATE coachella_data
SET tweet_date = TRIM(SUBSTR(tweet_created, 1, INSTR(tweet_created, ' ') - 1)),
    tweet_time = TRIM(SUBSTR(tweet_created, INSTR(tweet_created, ' ') + 1))
WHERE tweet_created IS NOT NULL;

-- Now we need to change the date and time columns into proper data type
ALTER TABLE coachella_data ADD COLUMN tweetdate_c DATE;
ALTER TABLE coachella_data ADD COLUMN tweettime_c TIME;

CREATE TEMP TABLE temp_parts AS
SELECT
  index_num
  ,tweet_date
  ,CAST(SUBSTR(tweet_date, 1, INSTR(tweet_date, '/') - 1) AS INT) AS month
  ,SUBSTR(tweet_date, INSTR(tweet_date, '/') + 1) AS day_year
FROM coachella_data
WHERE tweet_date IS NOT NULL;

UPDATE coachella_data
SET tweetdate_c = DATE(
  '20' || 
    SUBSTR(day_year, INSTR(day_year, '/') + 1, 2) || '-' ||
    SUBSTR('0' || month, -2) || '-' ||
    SUBSTR('0' || CAST(SUBSTR(day_year, 1, INSTR(day_year, '/') - 1) AS INT), -2)
)
FROM temp_parts
WHERE coachella_data.index_num = temp_parts.index_num;

UPDATE coachella_data
SET tweettime_c = TIME(tweet_time || ':00')
WHERE tweet_time IS NOT NULL;

UPDATE coachella_data
SET tweettime_c = TIME(
  SUBSTR('0' || SUBSTR(tweet_time, 1, INSTR(tweet_time, ':') - 1), -2) || ':' ||
  SUBSTR(tweet_time, INSTR(tweet_time, ':') + 1) || ':00'
)
WHERE tweet_time IS NOT NULL AND INSTR(tweet_time, ':') > 0;


-- Let's see what days people tweeted
select tweetdate_c as Date_of_Tweet
, count(tweetdate_c) as Count
from coachella_data cd
group by cd.tweetdate_c
-- 1/5/15 had 15 tweets, 1/6/15 had 2937, and 1/7/15 had 894. Interesting because you
-- would imagine you'd have the most tweets on the first day

-- Let's see what times people tweeted
select tweettime_c as Time_of_Tweet
, count(tweettime_c) as Count
from coachella_data cd
group by cd.tweettime_c
order by Count desc;
-- Seems most of the times were roughly around 10:30am - 12:50pm

-- Let's see the different tweet locations
SELECT tweet_location 
, count(tweet_location) as Count
from coachella_data
group by tweet_location
Order by Count desc
/** This was tough to decipher, since 1170 values were blank. And there was no uniform
formatting, so there was a lot of overlap (Los Angeles vs Los Angeles, CA vs LA, etc).
But the majority of the tweets seemed to come from California - Los Angeles, 
San Francisco, San Diego **/

-- Let's look at the different user timezones
SELECT user_timezone 
, count(user_timezone) as Count
from coachella_data
group by user_timezone
Order by Count desc
/** This gave us a slightly better picture. We had 983 empty values. The rest were very 
US focused (PT, ET, CT, Arizona, Alaska, Hawaii). There was also a strong international
presence (Quito, London, Amsterdam, Sydney, Tijuana). This was helpful to see the
spread across different countries **/

-- Let's examine the 50 tweets that were retweeted the most
With CTE as (
	select *
	from coachella_data cd
	order by cd.retweet_count desc
	Limit 50
)
Select user_timezone
, count(user_timezone) as Count
From CTE
Group by user_timezone
Order by Count desc
-- Most of these top 50 tweets came from the Pacific Time zone

-- Now let's see the sentiments of the top 50 tweets
With CTE as (
	select *
	from coachella_data cd
	order by cd.retweet_count desc
	Limit 50
)
Select coachella_sentiment
, count(coachella_sentiment) as Count
From CTE
Group by coachella_sentiment
Order by Count desc
-- 25 were neutral, 23 were positive, 2 were 'cant tell'
-- This is good, since none of the most retweeted tweets were negative

-- Now let's look at the date for the top 50 tweets
With CTE as (
	select *
	from coachella_data cd
	order by cd.retweet_count desc
	Limit 50
)
Select tweet_date
, count(tweet_date) as Count
From CTE
Group by tweet_date
Order by Count desc;
-- 28 were on 1/7/15 and 22 were on 1/16/15. It's interesting that none were on the first
-- day of 1/5/15. 

-- Let's look at the tweets where the sentiment was negative
select *
from coachella_data cd
where cd.coachella_sentiment is 'negative'
order by cd.retweet_count desc
-- The most retweets that negative tweets got was 7, which is not bad at all. 
-- That's good to see that negative discourse was not widely disseminated

-- Let's look at the timezones of the negative tweets
select user_timezone
, count(user_timezone) as count
from coachella_data cd
where cd.coachella_sentiment is 'negative'
group by cd.user_timezone
order by Count desc
-- Nothing out of the ordinary, the spread seems to follow the timezone distribution
-- as a whole


/** Overall this was interesting to get a sense of Twitter discourse on Coachella.
 * I liked seeing the spread of sentiment as well as the dates, times, and timezones of 
 * the tweets. It was nice to see that the discourse was largely positive or neutral.
 * And that the negative tweets were niche and not widely retweeted. It was also 
 * informative to see that most of the discourse was based in the US and on the West Coast.
 * It's roughly what you'd assume, but it was good to have confirmation. It would have been 
 * nice to have a uniform format for the tweet_location so we could get more granular
 */


