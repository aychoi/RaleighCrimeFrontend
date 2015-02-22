#This script is for the Raleigh Crime Map
#Description: It recieves a JSON string of a location, dates, time of day. 
#By querying PoliceIncidents.sqlite, this scripts inputs relevant crime data and 
#outputs in a string a crime index and a summary of the crime in that area.

#As of now (Feb 20 3:00), crimeIndex will be based on radius 

#Some comments will be for Nitin's local computer testings

#Loading required packages

require(rjson); require(RSQLite); require(lubridate);
require(geosphere)

#1. Reading JSON string from command prompt and saving variables ----
#Variables that will be inputted: latitide, longitude, firstDate, lastDate, timeDay
#firstDate is numeric of the format "yyyymmdd"
#timeDay key: Mornings (6am-12pm), Afternoon(12pm-6pm), Evening, N  


CrimeIndex <- function(args){

  
  
#args <- commandArgs(trailingOnly=TRUE);
#args = '{\"latitude\": \"35.784519\", \"longitude\": \"-78.682733\"}'
#cat(args)
locationData <- fromJSON(args);
#change colnames of locationData if neccessary
longitude = as.numeric(locationData$longitude)
latitude = as.numeric(locationData$latitude)


#latitude = 35.784519 
#longitude = -78.652733
point = c(longitude, latitude);

cat.driving = c("DRIVING", "VEHICLE")
cat.drugs = c("DRUGS","ALCOHOL")
cat.theft = c("BURGLARY", "ROBBERY", "FRAUD", "LARCENY", "FORGERY", "STOLEN PROPERTY", "EMBEZZLEMENT")
cat.property = c("DAMAGE PROPERTY")
cat.violent = c("ASSAULT", "WEAPONS", "KIDNAPPING", "HUMAN TRAFFICKING", "HOMICIDE")
cat.sexual = c("SEX OFFENSE", "PROSTITUTION", "PORNOGRAPHY")
cat.misc = c("MISC", "HUMANE", "CHILD", "FAMILY", "JUVENILE", "DISORDERLY", "EXTORTION", "GAMBLING", "ALL", "NOISE")



#2. Querying neccessary rows from PoliceIncidents.sqlite into localData ----
firstDate = "2014-01-01"
lastDate = "2014-12-31"

firstDateN = as.numeric(paste(substr(firstDate,1,4),substr(firstDate,6,7),substr(firstDate,9,10),sep=""));
lastDateN = as.numeric(paste(substr(lastDate,1,4),substr(lastDate,6,7),substr(lastDate,9,10),sep=""))
firstTime = 0;
lastTime = 24;
if (firstTime > lastTime){
  temp = firstTime; firstTime = lastTime; lastTime = temp;
}

con <- dbConnect(dbDriver("SQLite"), dbname = "PoliceIncidents.sqlite")
sqlcmd <- paste("Select * from PoliceIncidents where (dates <= ",lastDateN," and dates >=",firstDateN,
                " and hour <= ",lastTime," and hour >= ",firstTime,
                ")",sep="")

localData = dbGetQuery(con, sqlcmd)

nothing = dbDisconnect(con)


#3. Using the localData, I will create a crime index ----
crimeRadius = 0.3*1609.344

#First I need to import the scale.
days = as.Date(lastDate) - as.Date(firstDate) + 1
crimeIndex <- read.table("crimeIndexFiles/crimeIndexUniformGroup2014.csv",sep=",",header=TRUE)
crimeIndex$X <- NULL
locations <- data.frame(localData$longitude,localData$latitude);
locationMatrix <- data.matrix(locations,rownames.force = FALSE)

distancetoPoint = distHaversine(point,locationMatrix);
crimes = length(which(distancetoPoint < crimeRadius))

crimeRating = ecdf(crimeIndex[,8])(crimes) * 100;

#cat(crimeRating)

#4. Creating the summary 



#5. Making the score timeline ----
latDiff = 0.006;
lonDiff = 0.006;
upperBoundLat = latitude + latDiff; lowerBoundLat = latitude - latDiff;
upperBoundLon = longitude + lonDiff; lowerBoundLon = longitude - lonDiff;
con <- dbConnect(dbDriver("SQLite"), dbname = "PoliceIncidents.sqlite")
sqlcmd <- paste("Select * from PoliceIncidents where latitude > ", lowerBoundLat,
                " and latitude < ",upperBoundLat,
                " and longitude > ",lowerBoundLon,
                " and longitude < ",upperBoundLon
                ,sep="") 

localDataAllYears = dbGetQuery(con, sqlcmd)
nothing = dbDisconnect(con)



years = 2010:2015

crimeRatingYear_driving = 0
crimeRatingYear_drugs = 0
crimeRatingYear_misc = 0
crimeRatingYear_property = 0 
crimeRatingYear_sexual = 0
crimeRatingYear_theft = 0
crimeRatingYear_violent = 0
crimeRatingYear = 0

for (i in years){
  fname = paste("crimeIndexFiles/crimeIndexUniformGroup",i,".csv",sep="")
  
  crimeIndex <- read.table(fname,sep=",",header=TRUE)
  crimeIndex$X <-NULL
  localData <- localDataAllYears[which(localDataAllYears$year==i),]
  
  days = 365
  if (i%%4 == 0){
    days = 366
  }
  if (i==2015){
    nD = max(localData$dates); fD= min(localData$dates);
    final = paste(substr(nD,1,4),"-",substr(nD,5,6),"-",substr(nD,7,8),sep="")
    first = paste(substr(fD,1,4),"-",substr(fD,5,6),"-",substr(fD,7,8),sep="")     
    days = as.Date(final) - as.Date(first)
  }
  
  locationMatrix = as.matrix(data.frame(localData$longitude,localData$latitude));
  distancetoPoint = distHaversine(point,locationMatrix);
  
  crimes = length(which(distancetoPoint < crimeRadius));
  crimes_driving = length(which(distancetoPoint < crimeRadius & localData$groupName%in%cat.driving));
  crimes_drugs = length(which(distancetoPoint < crimeRadius & localData$groupName%in%cat.drugs));
  crimes_misc = length(which(distancetoPoint < crimeRadius & localData$groupName%in%cat.misc));
  crimes_property = length(which(distancetoPoint < crimeRadius & localData$groupName%in%cat.property));
  crimes_sexual = length(which(distancetoPoint < crimeRadius & localData$groupName%in%cat.sexual));
  crimes_theft = length(which(distancetoPoint < crimeRadius & localData$groupName%in%cat.theft));
  crimes_violent = length(which(distancetoPoint < crimeRadius & localData$groupName%in%cat.violent));
  
  
  crimesPerDay = crimes/as.numeric(days)  
  
  #crimeIndex = (crimeIndex[which(crimeIndex<quantile(crimeIndex,0.9))])
  crimeRatingYear_driving[i-2009] = ecdf(crimeIndex[,1])(crimes_driving) * 100;
  crimeRatingYear_drugs[i-2009] = ecdf(crimeIndex[,2])(crimes_drugs) * 100
  crimeRatingYear_misc[i-2009] = ecdf(crimeIndex[,3])(crimes_misc) * 100
  crimeRatingYear_property[i-2009] = ecdf(crimeIndex[,4])(crimes_property) * 100
  crimeRatingYear_sexual[i-2009] = ecdf(crimeIndex[,5])(crimes_sexual) * 100
  crimeRatingYear_theft[i-2009] = ecdf(crimeIndex[,6])(crimes_theft) * 100
  crimeRatingYear_violent[i-2009] = ecdf(crimeIndex[,7])(crimes_violent) * 100
  crimeRatingYear[i-2009] = ecdf(crimeIndex[,8])(crimes) * 100;
  
  
}

crimeRatingYears = data.frame(crimeRatingYear_driving,crimeRatingYear_drugs,crimeRatingYear_misc,
                         crimeRatingYear_property,crimeRatingYear_sexual,crimeRatingYear_theft,
                         crimeRatingYear_violent,crimeRatingYear)

outputJ = data.frame(crimeRating,crimeRatingYears)

return(toJSON(outputJ))

}
