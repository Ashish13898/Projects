library(tidyverse) # Metapackage of all tidyverse packages
df <- read_csv("US_Accidents_June20.csv") # reading the csv file

# Creating constants
NIGHT <- 'Night'
MORNING <- 'Morning'
AFTERNOON <- 'Afternoon'
EVENING <- 'Evening'
WEEKEND <- 'Weekend'
WEEKDAY <- 'Weekday'
SATURDAY <- 'Saturday'
SUNDAY <- 'Sunday'
AM_5_7 <- '5-7 AM'
AM_7_9 <- '7-9 AM'
AM_9_11 <- '9-11 AM'
PM_11_1 <- '11-1 PM'
PM_1_3 <- '1-3 PM'
PM_3_5 <- '3-5 PM'

# Taking hour value from the Start_Time column
df$Hour <- format(as.POSIXct(df$Start_Time,format="%H:%M:%S"),"%H")

# Function to get Morning/Afternoon... from hour value
get_time_of_day <- function(hour) {
    if (hour >= 5 && hour < 12) {
        return(MORNING)
    } else if (hour >= 12 && hour < 16) {
        return(AFTERNOON)
    } else if (hour >= 16 && hour < 20) {
        return(EVENING)
    } else {
        return(NIGHT)
    }
}

# Converting Hour column from chr $o dbl
df$Hour <- as.numeric(df$Hour)

# Creating new column time_of_the_day and filling the values by invoking the function created above
df$time_of_the_day<- mapply(get_time_of_day, df$Hour)

# Sorting the col
df$time_of_the_day <- factor(df$time_of_the_day, levels=c(MORNING, AFTERNOON, EVENING, NIGHT))

# Creating new column for getting the day of the week as per the start date
df$day_of_the_week <- weekdays(as.Date(df$Start_Time))
df$type_of_the_day <- with(df, ifelse(df$day_of_the_week == SATURDAY | df$day_of_the_week == SUNDAY,WEEKEND,WEEKDAY))

# Temp data frames for weekend and  weekdays
Weekend_df = subset(df,type_of_the_day == WEEKEND)
Weekday_df = subset(df,type_of_the_day == WEEKDAY)

# Counting the total values for type of the day
Morning_Accidents = length(which(df$time_of_the_day == MORNING))
Afternoon_Accidents = length(which(df$time_of_the_day == AFTERNOON))
Evening_Accidents = length(which(df$time_of_the_day == EVENING))
Night_Accidents = length(which(df$time_of_the_day == NIGHT))

# Counting the total values for weekends and weekdays
Total_Accidents = nrow(df)
Total_Weekend_Accidents = nrow(Weekend_df)
Total_Weekday_Accidents = nrow(Weekday_df)

accidents <- c(Morning_Accidents, Afternoon_Accidents,Evening_Accidents,Night_Accidents )
total <- c(Total_Accidents,Total_Accidents,Total_Accidents,Total_Accidents)

weekday_accidents <- 0
weekend_accidents <- 0
total_weekday_accidents <- 0
total_weekend_accidents <- 0

# Getting the list of number of accidents for every hour interval
for(i in 0:23) 
{
    weekday_accidents[i] <- sum( Weekday_df$Hour == toString(i) )
    weekend_accidents[i] <- sum( Weekend_df$Hour == toString(i) )
    total_weekday_accidents[i] <- Total_Weekday_Accidents
    total_weekend_accidents[i] <- Total_Weekend_Accidents
}

# Calculting the chi-square for H1 value
prop.test(accidents,total,conf.level=0.95)

# Calculting the chi-square for H2 value
prop.test(weekend_accidents,total_weekend_accidents,conf.level=0.95)

# Calculting the chi-square for H3 value
prop.test(weekday_accidents,total_weekday_accidents,conf.level=0.95)
