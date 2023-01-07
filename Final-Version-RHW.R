##R-HOMEWORK
## ALEXANDER NILSSON, ZOE JAMOIS, NICOLAS SCWAIGER

setwd("/Users/zoejamois/Documents/R Programming/HW")

## Installing and library packages
install.packages("sf")
install.packages("corrplot")
install.packages("ggcorrplot")
library(ggcorrplot)
library(corrplot)
library(sf) 
library(readr) 
library(lubridate) 
library(hms) 
library(tidyverse)
library(leaflet) 
library(stargazer)

## We remove unnecessary and irrelevant columns, changes certain character columns
## into factors columns, latitude/longitude/coordinates into doubles and change the 
## date column into European form.
df19 <- read_csv("Crime_Chicago_2019.csv", col_types = cols(...1 = col_skip(),
                                                            ID = col_skip(),
                                                            IUCR = col_factor(),
                                                            Updated.On = col_skip(),
                                                            Location = col_skip(),
                                                            Date = col_datetime("%m/%d/%Y %I:%M:%S %p"),
                                                            Block = col_factor(),
                                                            Description = col_factor(),
                                                            Location.Description = col_factor(),
                                                            Arrest = col_factor(),
                                                            Domestic = col_factor(),
                                                            Beat = col_factor(),
                                                            District = col_factor(),
                                                            Ward = col_factor(),
                                                            Community.Area = col_factor(),
                                                            FBI.Code = col_factor(),
                                                            X.Coordinate = col_double(),
                                                            Y.Coordinate = col_double(),
                                                            Year = col_factor(),
                                                            Latitude = col_double(),
                                                            Longitude = col_double()))

df20 <- read_csv("Crime_Chicago_2020.csv", col_types = cols(...1 = col_skip(),
                                                            ID = col_skip(),
                                                            IUCR = col_factor(),
                                                            Updated.On = col_skip(),
                                                            Location = col_skip(),
                                                            Date = col_datetime("%m/%d/%Y %I:%M:%S %p"),
                                                            Block = col_factor(),
                                                            Description = col_factor(),
                                                            Location.Description = col_factor(),
                                                            Arrest = col_factor(),
                                                            Domestic = col_factor(),
                                                            Beat = col_factor(),
                                                            District = col_factor(),
                                                            Ward = col_factor(),
                                                            Community.Area = col_factor(),
                                                            FBI.Code = col_factor(),
                                                            X.Coordinate = col_double(),
                                                            Y.Coordinate = col_double(),
                                                            Year = col_factor(),
                                                            Latitude = col_double(),
                                                            Longitude = col_double()
))



df21 <- read_csv("Crime_Chicago_2021.csv", col_types = cols(ID = col_skip(),
                                                            IUCR = col_factor(),
                                                            Updated.On = col_skip(),
                                                            Location = col_skip(),
                                                            Date = col_datetime("%m/%d/%Y %I:%M:%S %p"),
                                                            Block = col_factor(),
                                                            Description = col_factor(),
                                                            Primary.Type = col_factor(),
                                                            Location.Description = col_factor(),
                                                            Arrest = col_factor(),
                                                            Domestic = col_factor(),
                                                            Beat = col_factor(),
                                                            District = col_factor(),
                                                            Ward = col_factor(),
                                                            Community.Area = col_factor(),
                                                            FBI.Code = col_factor(),
                                                            X.Coordinate = col_double(),
                                                            Y.Coordinate = col_double(),
                                                            Year = col_factor(),
                                                            Latitude = col_double(),
                                                            Longitude = col_double()
))

## Since the column for primary type is missing from the 2019/2020 data sets, we use
## right_join and bind_rows to use 2021 data set (which includes the missing variable
## for primary crime type) to implement the years missing it.

## Create new data frame and select variables IUCR and Primary.Type 
pt21 <- df21 %>% select(4:5)


## Unique() lets us isolate the values of Primary.type and their corresponding IUCR codes.
upt21 <- unique(pt21)


## Using right_join we can now add the primary.type variable to the data set for 2019
df19new <- right_join(
  upt21,
  df19,
  by = NULL,
  copy = FALSE,
  suffix = c(".upt21", ".df19"),
  keep = FALSE,
  na_matches = c("na", "never")
)

## Using right_join we can now add the primary.type variable to the data set for 2020
df20new <- right_join(
  upt21,
  df20,
  by = NULL,
  copy = FALSE,
  suffix = c(".upt21", ".df20"),
  keep = FALSE,
  na_matches = c("na", "never")
)


## Using bind_rows we are able to create one combined data frame for all three years of data.
df <- bind_rows(df19new, df20new, df21)


## To make the analysis process easier and to avoid mistakes we are going to standardize the 
## names of the variables in the data frame. We make all names lowercase and change "." to "_"
names(df)<-str_to_lower(names(df)) %>% 
  str_replace("[.]",'_')

## To analyse the data deep we are going to create time intervals so that we can analyse
## based on a given time period. We choose to do four six hour periods. 
## 00-06, 06-12, 12-18, 18-00.
df1<-df %>%
  mutate(time=as_hms(hour(date)*60+minute(date)),
         date=date(date),
         time_group=cut(as.numeric(time),
                        breaks=c(0,6*60,12*60,18*60,23*60+59),
                        labels=c("00-06","06-12","12-18","18-00"),
                        include.lowest = TRUE))

## Similar to the reasoning for creating the time slots, we
## Create day and month columns, abbreviated to fit on plots and graphs better. 
df1 <- df1 %>%
  mutate(
    day=wday(date, label=TRUE, abbr=TRUE),
    month=month(date, label=TRUE, abbr=TRUE)
  )
df1$week <- week(ymd(df1$date))
df1$Nday <- day(ymd(df1$date))

## The amount of different crime types are quite high, with many types being
## quite specific with low crime counts, thus we create the new variable “crime” 
## where we merge and condense the amount of primary types to 16 variables instead.

df1<-df1 %>%
  mutate(
    crime=fct_recode(primary_type,
                     "DAMAGE"="CRIMINAL DAMAGE",
                     "DRUG"="NARCOTICS",
                     "DRUG"="OTHER NARCOTIC VIOLATION",
                     "FRAUD"="DECEPTIVE PRACTICE",
                     "NONVIOLENT"="LIQUOR LAW VIOLATION",
                     "NONVIOLENT"="CONCEALED CARRY LICENSE VIOLATION",
                     "NONVIOLENT"="STALKING",
                     "NONVIOLENT"="INTIMIDATION",
                     "NONVIOLENT"="GAMBLING",
                     "NONVIOLENT"="OBSCENITY",
                     "NONVIOLENT"="PUBLIC INDECENCY",
                     "NONVIOLENT"="INTERFERENCE WITH PUBLIC OFFICER",
                     "NONVIOLENT"="PUBLIC PEACE VIOLATION",
                     "NONVIOLENT"="NON-CRIMINAL",
                     "OTHER"="OTHER OFFENSE",
                     "OTHER"="OFFENSE INVOLVING CHILDREN",
                     "SEX"="HUMAN TRAFFICKING",
                     "SEX"="CRIMINAL SEXUAL ASSAULT",
                     "SEX"="SEX OFFENSE",
                     "SEX"="CRIMINAL SEXUAL ASSAULT",
                     "SEX"="PROSTITUTION",
                     "TRESSPASS"="CRIMINAL TRESPASS",
                     "VIOLENT"="KIDNAPPING",
                     "VIOLENT"="WEAPONS VIOLATION"
    ))


## To finish the process of cleaning the data, we check for missing values and find
## that there are some missing values. To correct for this we run the na.omit() command.
## given that the NA's only make up a small percent of the data, we don't worry about 
## obscuring our results, we also suspect some duplicates and remove these with unique()
df1 <- na.omit(df1)
df1 <- unique(df1)  ## Beware, this command will take some time 

## EXPLORATORY ANALYSIS.

## Let's start by looking at how frequent the different crime types were over the three years.
df1 %>%
  group_by(crime) %>%
  summarize(count=n()) %>%
  arrange(desc(count))


## To visualize the distribution of the different crime types, we create a bar plot.
counts = table(df1$crime)
counts = counts[order(counts, decreasing=T)]
par(mar = c(5,10,1,1)) 
y = barplot(counts, horiz=T, las=1, cex.names=0.7, col="black")


## We create data frames that include the amount of crimes given a that they
## take place on the same longitude and latitude.
crimesLatLong <- df1 %>%
  mutate(longitude = round(longitude, 2),
         latitude = round(latitude, 2)) %>% 
  group_by(longitude, latitude) %>% 
  summarise(CrimeCount = n())

## Interactive map
## defining the color function for our map
colfunc <- colorRampPalette(c("white", "red"))

## Using our color function to create a color pallet for our maps. 
pal <- colorNumeric(
  palette = colfunc(10),
  domain = crimesLatLong$CrimeCount)

## Map of crimes spreadout over the city
CrimeMap <- leaflet(crimesLatLong) %>% 
  addTiles() %>% 
  setView(lng = mean(crimesLatLong$longitude), lat = mean(crimesLatLong$latitude), zoom = 9.5) %>%
  addCircles(lng = ~longitude, lat = ~latitude,
             stroke = T,
             color = ~pal(CrimeCount),
             fillColor = ~pal(CrimeCount), 
             opacity = ~CrimeCount,
             fillOpacity = ~CrimeCount,
             radius = ~1,
             popup = ~CrimeCount, label = ~CrimeCount,
  ) %>%
  addLegend("topright", pal = pal, values = ~CrimeCount,
            title = "Crime Count")
CrimeMap

## The article we are basing our analysis on states that after the pandemic more 
## people are fearful of more violent crimes and not feeling same in their homes
## From this point on we are going analyse this and see if the data confrimes this.
crime_count_year <- df1 %>% count(year)
ggplot(data = crime_count_year, 
       aes(x = year, y=n))+ 
  geom_bar(stat = "identity", size = .2) +
  scale_y_continuous(labels = scales::comma)+
  labs(title = "Evolution of crime count over 3 years",
       x = "Year",
       y = "Numbers of Crimes")+ 
  theme(plot.title = element_text(size = 10))

## Does the evolution crime have a similar pattern every year?
## Evolution of crime during the year 2019 per week
crimeweek19_count <- subset(df1, year=='2019') %>% 
  count(week)
ggplot(data = crimeweek19_count, aes(x=week, y = n)) +
  geom_line(color = "blue", size = .8) +
  geom_point(color = " blue") +
  labs(title = "Evolution of crime in 2019, per week", y = "Count", x = "Week")

## Evolution of crime during the year 2020 per week
crimeweek20_count <- subset(df1, year=='2020') %>% 
  count(week)
ggplot(data = crimeweek20_count, aes(x=week, y = n)) +
  geom_line(color = "blue", size = .8) +
  geom_point(color = " blue") +
  labs(title = "Evolution of crime in 2020, per week", y = "Count", x = "Week")


## Evolution of crime during the year 2021 per week
crimeweek21_count <- subset(df1, year=='2021') %>% 
  count(week)
ggplot(data = crimeweek21_count, aes(x=week, y = n)) +
  geom_line(color = "blue", size = .8) +
  geom_point(color = " blue") +
  labs(title = "Evolution of crime in 2021, per week", y = "Count", x = "Week")

## Distribution of crimes over different time group
crimetg_count <- df1 %>% count(time_group)
ggplot(data = crimetg_count, 
       aes(x = time_group, y = n))+
  geom_bar(stat = "identity", size = .1) +
  labs(title = "Crime distribution per time group over 2019 - 2021",
       x = "Time Group",
       y = "Numbers of Crimes")+ 
  theme(plot.title = element_text(size = 10))

## DEEPER ANALYSIS 

## We have 3 sub questions that we want to analyze further: 
## Year 2020 as an outlier 
## Violent crime as an outlier compared to other crime types 
## Home/Location based analysis 

## 1. Year 2020 as an outlier 
## Year 2020 has by far the most unstable evolution, we want to focus on 2 events 
## that could have influenced the level of crime in 2020: protests following George FLoyd's death
## and the lockdown

## The Lockdown
## Evolution of Crime in March 2020: beginning of the pandemic and progressive restrictions
crime_March20 <- subset(df1, year=='2020'& month=="Mar") %>% count(Nday)
ggplot(data = crime_March20, aes(x=Nday, y = n)) +
  geom_line(color = "black", size = .8) +
  geom_point(color = " black") +
  labs(title = "Evolution of Crime in March 2020", y = "Number of crimes"
       , x = "Day")

## The impact of George Floyd's death protests on crime
## Evolution of crime over month of May 2020
crimeMAY20_count <- df1[(df1$year == "2020") & (df1$month=="May"),] %>% count(Nday)
ggplot(data = crimeMAY20_count, aes(x=Nday, y = n)) +
  geom_line(color = "black", size = .8) +
  geom_point(color = " black") +
  labs(title = "Evolution of crime over the month of May 2020", y = "Number of crimes",
       x = "Day") + 
  theme (plot.title = element_text(size = 9))


## 2. We want to check how violence has evolved compared to all other crimes. 
## The article claims that 2/3 of people think that violence is on the rise, 
## we want to check that. 

## To analyse if the type of violent crime has increased we create a new data frame
## where we group all variables that we interpret as being of violent nature. 
violentdf<-df1 %>%
  mutate(
    violent=fct_recode(primary_type,
                       "VIOLENT"="BATTERY",
                       "VIOLENT"="ASSAULT",
                       "VIOLENT"="HOMICIDE",
                       "VIOLENT"="HUMAN TRAFFICKING",
                       "VIOLENT"="CRIMINAL SEXUAL ASSAULT",
                       "VIOLENT"="ROBBERY",
                       "VIOLENT"="KIDNAPPING",
    ))


## Here we create the subset data frame that only includes violent crimes
sub_violent<- subset(violentdf, violent=="VIOLENT")

## Plot showing the evolution of specifically violent crimes over the three years.
crime_count_year_violent<- sub_violent %>% count(year)
ggplot(data = crime_count_year_violent, 
       aes(x = year, y=n))+
  geom_bar(stat = "identity", size = .2) +
  labs(title = "Evolution of violent crimes count over 3 years",
       x = "Year",
       y = "Number of Violent Crimes")+ 
  theme(plot.title = element_text(size = 10))

## Plot showing the evolution of specifically violent crimes during different time groups
## over the three years 
crimetg_count <- sub_violent %>% count(time_group)
ggplot(data = crimetg_count, 
       aes(x = time_group, y = n))+
  geom_bar(stat = "identity", size = .1) +
  labs(title = "Violent Crime distribution per time group over 2019 - 2021",
       x = "Time Group",
       y = "Number of Crimes")+ 
  theme(plot.title = element_text(size = 10))

## We create data frames that include the amount of violent crimes given a that they
## take place on the same longitude and latitude to compare it to all crimes.
crimesLatLong1 <- sub_violent %>%
  mutate(longitude = round(longitude, 2),
         latitude = round(latitude, 2)) %>% 
  group_by(longitude, latitude) %>% 
  summarise(CrimeCount = n())

### Now we create the same map but looking only at violent crimes
pal1 <- colorNumeric(
  palette = colfunc(10),
  domain = crimesLatLong1$CrimeCount)

ViolentMap <- leaflet(crimesLatLong1) %>% 
  addTiles() %>% 
  setView(lng = mean(crimesLatLong1$longitude), lat = mean(crimesLatLong1$latitude), zoom = 9.5) %>%
  addCircles(lng = ~longitude, lat = ~latitude,
             stroke = T,
             color = ~pal1(CrimeCount),
             fillColor = ~pal1(CrimeCount), 
             opacity = ~CrimeCount,
             fillOpacity = ~CrimeCount,
             radius = ~1,
             popup = ~CrimeCount, label = ~CrimeCount,
  ) %>%
  addLegend("topright", pal = pal, values = ~CrimeCount,
            title = "Crime Count")

ViolentMap

## To end our analysis of violence, lets map out how the chance of violent crimes
## Actually affected neighborhoods. To start we first need download the boundaries
## outline for the city of Chicago.
neighborhoods = st_read("https://data.cityofchicago.org/api/geospatial/bbvz-uum9?method=export&format=GeoJSON")


## Lets create a subset of violent crimes 2019 that can be mapped on the neighborhoods.
violence = violentdf[(violentdf$violent=="VIOLENT") & (violentdf$latitude > 41),]
violence_2019 = violence[(violence$longitude) & (violence$year == "2019"),]
violence_2019 = st_as_sf(violence_2019, coords = c("longitude", 'latitude'), crs = 4326)
neighborhoods$Violence_2019 = lengths(st_intersects(neighborhoods, violence_2019))


## Create another subset of violent crimes 2020 that can be mapped on the neighborhoods.
violence20 = violentdf[(violentdf$violent=="VIOLENT") & (violentdf$latitude > 41),]
violence_2020 = violence[(violence$longitude) & (violence$year == "2020"),]
violence_2020 = st_as_sf(violence_2020, coords = c("longitude", 'latitude'), crs = 4326)
neighborhoods$Violence_2020 = lengths(st_intersects(neighborhoods, violence_2020))


## Now to get thh change in violence from year 2019 to 2020.
neighborhoods$violence_change = 100 * ((neighborhoods$Violence_2020 /
                                          neighborhoods$Violence_2019) - 1)
neighborhoods$violence_change[is.infinite(neighborhoods$violence_change)] = 1000
neighborhoods$violence_change = round(neighborhoods$violence_change)

## Lastly we plot the evolution of violent crimes from 2019 to 2020.
plot(neighborhoods["violence_change"], breaks="quantile",
     pal=colorRampPalette(c("yellow","orange", "red")))



#3. We want to explore the part of the article claiming that people don't feel safe in their own homes. 

## We first create new df to split location and description into home/not home
home_df <- df1 %>%
  mutate(l_d = ifelse(location_description==c("APARTMENT", "RESIDENCE", 
         "RESIDENCE - PORCH / HALLWAY","RESIDENCE - YARD (FRONT / BACK)",
         "RESIDENCE PORCH/HALLWAY","RESIDENCE - GARAGE", "RESIDENTIAL YARD
         (FRONT/BACK)", "DRIVEWAY - RESIDENTIAL", "NURSING / RETIREMENT HOME", 
         "NURSING HOME/RETIREMENT HOME"), 'HOME', 'NOT HOME'))    

## Heatmap n°1: is population safe at home over the 3 years? 
## We exclude district 31 as it data is incomplete.
home_df = filter(home_df, district != "31")
home_df %>%
  group_by(l_d,district) %>%
  summarise(count=n()) %>%
  ggplot(aes(x=l_d, y=district)) +
  geom_tile(aes(fill=count)) +
  labs(x="Crime", y = "District", title="Is population safe at home?") +
  scale_fill_viridis_c("Number of Crimes") +
  coord_flip()
 
## Compare 2019 and 2021 to observe any variation.
subset(home_df, year=='2019') %>%
  group_by(l_d,district) %>%
  summarise(count=n()) %>%
  ggplot(aes(x=l_d, y=district)) +
  geom_tile(aes(fill=count)) +
  labs(x="Crime", y = "District", title="Is population safe at home in 2019?") +
  scale_fill_viridis_c("Number of Crimes") +
  coord_flip()

## 2021
subset(home_df, year=='2021')%>%
  group_by(l_d,district) %>%
  summarise(count=n()) %>%
  ggplot(aes(x=l_d, y=district)) +
  geom_tile(aes(fill=count)) +
  labs(x="Crime", y = "District", title="Is population safe at home in 2021?") +
  scale_fill_viridis_c("Number of Crimes") +
  coord_flip()

## Create dummy variables  for futher analysis.
home_df_2 <- home_df %>%
  mutate(home = ifelse(l_d=='HOME', 1, 0),
         arrest=ifelse(arrest=="true",1,0),
         pre_pandemic=ifelse(year=="2019",1,0), 
         post_pandemic=ifelse(year=="2021",1,0))

## Correlation between home, arrest.
cor(home_df_2[, c('home','arrest')])

## Correlation between home, pre pandemic, post pandemic.
cor(home_df_2[, c('home','pre_pandemic', 'post_pandemic')])

## 4. Police efficiency 
## Regression analysis.
## To run a regression (we decide on a Probit model) we first need to create
## a new data frame to which we can add all the dummmy variables.

## this first steps creates the data frame and additionally we manually create 
## the dummy variables for arrest and for the time groups
reg1_df<- df1[, c("arrest", "crime", "time_group", "district")] 
reg1_df <- reg1_df %>%   
  mutate(dum_arrest=ifelse(arrest=="true",1,0),
         dum_timegr1=ifelse(time_group=="00-06",1,0),
         dum_timegr2=ifelse(time_group=="06-12",1,0),
         dum_timegr3=ifelse(time_group=="12-18",1,0),
         dum_timegr4=ifelse(time_group=="18-00",1,0),)

## after creating the data frame we now must create the dummy variales for crime.
## The first step is getting a vector of the unique crime types
crime<- unique(df1$crime)
## next we obtain a matrix which consists of n-1 dummy variables for "crime", with the 
## function "model.matrix"
dum_crime <- as.data.frame(model.matrix (~crime)[,-1])
## in this step we combine the vector of unique types and the dummy variable matrix.
## the two have to be combined to be able to join this matrix to the regression data frame
df_crime <- as.data.frame(cbind(crime, dum_crime)) # baseline is crime "Battery"

## with the command right_join we finally add the two data frames together and 
## now we have a data frame for the regression with 15 dummy variables for the 16 
## different crime types. 
reg1_df <- right_join(
  df_crime,
  reg1_df,
  by = NULL,
  copy = FALSE,
  suffix = c(".df_crime", ".reg1_df"),
  keep = FALSE,
  na_matches = c("na", "never"))

## We repeat the above steps for the variable districts
district<- unique(df1$district)
dum_district <- as.data.frame(model.matrix (~district)[,-1])
df_dist <- as.data.frame(cbind(district, dum_district)) # baseline is district 1


reg1_df <- right_join(
  df_dist,
  reg1_df,
  by = NULL,
  copy = FALSE,
  suffix = c(".df_dist", ".reg1_df"),
  keep = FALSE,
  na_matches = c("na", "never"))

colnames(reg1_df)[37] ="crimeMOTOR" ## necessary to rename "crimeMOTORVEHICLETHEFT" to "crimeMOTOR" to run the regression

## We finally are able to regress arrest on the selected variables from the regression
## data frame using a Probit model. The baseline Person in our  model commits the crime Battery, 
## in district 1 at time "18-00".
probit <- glm(dum_arrest~dum_timegr1+dum_timegr2+dum_timegr3+crimeTHEFT+crimeOTHER+crimeARSON+
                crimeBURGLARY+crimeDRUG+crimeASSAULT+crimeDAMAGE+crimeFRAUD+crimeSEX+crimeVIOLENT+crimeROBBERY+crimeTRESSPASS+
                crimeMOTOR+crimeNONVIOLENT+crimeHOMICIDE+district12+district19+district20+district3+district7+
                district15+district8+district18+district25+district5+district6+district4+district11+district10+district14+
                district2+district22+district17+district24+district16+district9+district31, 
              family = binomial(link="probit"), data = reg1_df)
summary(probit)


## Regression for violent data subset

## We repeat the same regression from above, this time using the violent 
## crime subset. We want to see if we can see any differences in the effects
## of the variables between the two data sets. 
## The steps needed in this regression are the same as in the regression above.

reg2_df<- sub_violent[, c("arrest", "crime", "time_group", "district")]
reg2_df <- reg2_df %>%   
  mutate(dum_arrest=ifelse(arrest=="true",1,0),
         dum_timegr1=ifelse(time_group=="00-06",1,0),
         dum_timegr2=ifelse(time_group=="06-12",1,0),
         dum_timegr3=ifelse(time_group=="12-18",1,0),
         dum_timegr4=ifelse(time_group=="18-00",1,0),)

crime_violent<- unique(sub_violent$primary_type)
## the only difference when creating the regression data frame is that the levels
## of crime in the violent subset need to be dropped. (from 16 levels down to the 
## actual 7 violent levels)
crime_violent <- droplevels(crime_violent)
dum_crime_violent <- as.data.frame(model.matrix (~crime_violent)[,-1])
df_crime_violent <- as.data.frame(cbind(crime_violent, dum_crime_violent)) 
colnames(df_crime_violent)[1]="crime"  # baseline is crime "battery"

reg2_df <- right_join(
  df_crime_violent,
  reg2_df,
  by = NULL,
  copy = FALSE,
  suffix = c(".df_crime_violent", ".reg2_df"),
  keep = FALSE,
  na_matches = c("na", "never"))


district<- unique(df1$district)
dum_district <- as.data.frame(model.matrix (~district)[,-1])
df_dist <- as.data.frame(cbind(district, dum_district)) 


reg2_df <- right_join(
  df_dist,
  reg2_df,
  by = NULL,
  copy = FALSE,
  suffix = c(".df_dist", ".reg2_df"),
  keep = FALSE,
  na_matches = c("na", "never"))

colnames(reg2_df)[26]="crime_violentSEX"
colnames(reg2_df)[30]="crime_violentHUMAN"

## Probit # baseline Person: commits crime Battery, in district 1 at time "18-00"
probit2 <- glm(dum_arrest~dum_timegr1+dum_timegr2+dum_timegr3+ crime_violentASSAULT+
                 crime_violentSEX+crime_violentROBBERY+crime_violentKIDNAPPING+
                 crime_violentHOMICIDE+crime_violentHUMAN+district12+district19+district20+district3+district7+
                 district15+district8+district18+district25+district5+district6+district4+district11+district10+district14+
                 district2+district22+district17+district24+district16+district9+district31, 
               family = binomial(link="probit"), data = reg2_df)
summary(probit2)

## END




