library(tidyverse) # Metapackage of all tidyverse packages

pdf("visualization.pdf",compress = TRUE) # creating a common pdf for all visualizations in this script
df <- read_csv("US_Accidents_June20.csv") # reading the csv file

# Creating constants
NIGHT <- 'Night'
MORNING <- 'Morning'
AFTERNOON <- 'Afternoon'
EVENING <- 'Evening'

SATURDAY <- 'Saturday'
SUNDAY <- 'Sunday'

WEEKEND <- 'Weekend'
WEEKDAY <- 'Weekday'

AM_5_7 <- '5-7 AM'
AM_7_9 <- '7-9 AM'
AM_9_11 <- '9-11 AM'
PM_11_1 <- '11-1 PM'
PM_1_3 <- '1-3 PM'
PM_3_5 <- '3-5 PM'

#Creating Global Variables
ID <- df$ID
Severity <- df$Severity
order <- c(MORNING, AFTERNOON, EVENING, NIGHT)

# Taking hour value from the Start_Time column
df$Hour <- format(as.POSIXct(df$Start_Time,format="%H:%M:%S"),"%H")

# Function to get frequency of accidents based on True/False boolean
get_acc_val_day <- function(Acc_Bool,ID) {
    if(Acc_Bool == "True"){
        return(ID)
    } else{
        return(nrow(df)-ID)
    }
}


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

# Function to get the Time Intervals as per the hour value
get_time_interval_of_day <- function(hour) {
    if (hour == 5 || hour == 6) {
        return(AM_5_7)
    } else  if (hour == 7 || hour == 8) {
        return(AM_7_9)
    } else  if (hour == 9 || hour == 10) {
        return(AM_9_11)
    }
    else if (hour == 11 || hour == 12) {
        return(PM_11_1)
    }
    else if (hour == 13 || hour == 14) {
        return(PM_1_3)
    }
    else if (hour == 15 || hour == 16)
    {
        return(PM_3_5)
    }
}

# Converting Hour column from chr $o dbl
df$Hour <- as.numeric(df$Hour)

# Creating new column time_of_the_day and filling the values by invoking the function created above
df$time_of_the_day<- mapply(get_time_of_day, df$Hour)
#Sorting the col
df$time_of_the_day <- factor(df$time_of_the_day, levels=c(MORNING, AFTERNOON, EVENING, NIGHT))

# Creating new column for getting the day of the week as per the start date
df$day_of_the_week <- weekdays(as.Date(df$Start_Time))
df$type_of_the_day <- with(df, ifelse(df$day_of_the_week == SATURDAY | df$day_of_the_week == SUNDAY,WEEKEND,WEEKDAY))

Type_Of_The_Day <- df$type_of_the_day
Day_Of_The_Week <- df$day_of_the_week
Time_of_the_day <- df$time_of_the_day

#Sub data frames for weekend and  weekdays
Weekend_df = subset(df,type_of_the_day == WEEKEND)
Weekday_df = subset(df,type_of_the_day == WEEKDAY)

####################
# BASIC BAR PLOT - Proportion of accidents occuring at different times of the day
####################

bb <- aggregate(ID ~ Time_of_the_day, df, FUN=length)
bb$total = nrow(df)
bb_df <- xtabs(bb$ID / bb$total ~ bb$Time_of_the_day, bb)

barplot(t(bb_df[match(order, bb$Time_of_the_day)])
        ,main="Comparison of proportion of accidents \noccurring at different times of the day"
        ,ylab="Proportion"
        ,xlab="Time of the day"
        ,col=c("mistyrose")
        ,las=1        
        ,args.legend=list(x="topleft")
        ,axes=F
        ,cex.axis=1.2
        ,cex.names=1.2
        ,cex.lab=1
        ,cex.main=1.2)
axis(side=2,at=c(0,0.1,0.2,0.3,0.4),labels=c("0","0.1","0.2","0.3","0.4"),las=2)

####################
# Histogram - Frequency of accidents occurring at different hours during Weekend and weekday
####################

print(hist_weekend <- hist(Weekend_df$Hour,
              breaks="Sturges"
              ,main="Frequency of accidents occurring at different hour intervals in weekends"
              ,ylab="Frequency"
              ,xlab="Time"
              ,col="azure"
              ,axes=FALSE
    ))
axis(side=2, at=c(0,5000,10000,15000,20000,25000,30000), labels=c("0","5k","10k","15k","20k","25k","30k"), las=1)
axis(side=1, at=c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23),
         labels=c("12am","1am","2am","3am","4am","5am","6am","7am","8am","9am","10am","11am","12pm","1pm","2pm","3pm","4pm","5pm","6pm","7pm","8pm","9pm","10pm","11pm"))
    
# For creating line
mn <- mean(Weekend_df$Hour)
stdD <- sd(Weekend_df$Hour)
x <- seq(0,24,0.000001)
y1 <- dnorm(x, mean=mn, sd=stdD)
y1 <- y1 * diff(hist_weekend$mids[1:2])*length(Weekend_df$Hour);
lines(x,y1,col="blue")
    

print(hist_weekday <- hist(Weekday_df$Hour,
           breaks="Sturges"
           ,main="Frequency of accidents occurring at different hour intervals in weekdays"
           ,ylab="Frequency"
           ,xlab="Time"
           ,col="azure"
           ,axes=FALSE
))
axis(side=2, at=c(0,50000,100000,150000,200000,250000,300000), labels=c("0","50k","100k","150k","200k","250k","300k"), las=1)
axis(side=1, at=c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23),
     labels=c("12am","1am","2am","3am","4am","5am","6am","7am","8am","9am","10am","11am","12pm","1pm","2pm","3pm","4pm","5pm","6pm","7pm","8pm","9pm","10pm","11pm"))

# For creating line
mn <- mean(Weekday_df$Hour)
stdD <- sd(Weekday_df$Hour)
x <- seq(0,24,0.000001)
y1 <- dnorm(x, mean=mn, sd=stdD)
y2 <- y1 * diff(hist_weekday$mids[1:2])*length(Weekday_df$Hour);
lines(x,y2,col="blue")


####################
# GROUPED BAR PLOT - Comparison of proportions of accidents \noccuring at different Types of the day during weekend and weekday
####################

a.Type_Of_The_Day.time_of_the_day <- aggregate(ID ~ type_of_the_day + time_of_the_day, df, FUN=length)
a.Type_Of_The_Day.Size <- aggregate(ID ~ type_of_the_day,df, FUN=length)
a <- merge(a.Type_Of_The_Day.time_of_the_day, a.Type_Of_The_Day.Size, by = "type_of_the_day")

colnames(a) <- c("Type_Of_The_Day", "Time_Of_The_Day", "Time_Of_The_Day.Count", "Total.Count")
xtab <- xtabs(Time_Of_The_Day.Count / Total.Count ~ Type_Of_The_Day + Time_Of_The_Day , a)

barplot(t(xtab)
        ,main="Comparison of proportions of accidents occurring \nat different times of the day between weekend and weekdays"
        ,ylab="Proportion"
        ,xlab="Type of the day"
        ,col=c("#ADD8E6","#F4A582","#90ee90","#FDDBC7")
        ,las=1,
        ,cex.axis=1.2
        ,cex.names=1.2
        ,cex.lab=1
        ,cex.main=1
        ,legend.text=c("Morning","Afternoon","Evening","Night")
        ,args.legend=list(x="topright")
        ,axes=F
        ,beside=TRUE)

axis(side=2,las=2,at=c(0,0.1,0.2,0.3,0.4,0.46),labels=c('0',"0.1","0.2","0.3","0.4","0.5"))
mtext("Weekday and Weekend",side=1,line=6)

dev.off()
