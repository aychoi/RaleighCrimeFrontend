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

#2. Querying neccessary rows from PoliceIncidents.sqlite into localData ----
firstDate = "2014-10-31"
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
days = as.Date(lastDate) - as.Date(firstDate)
crimeIndex <- read.table("crimeIndex.csv",sep=",",header=TRUE)
crimeIndex$X <- NULL
locations <- data.frame(localData$longitude,localData$latitude);
locationMatrix <- data.matrix(locations,rownames.force = FALSE)

distancetoPoint = distHaversine(point,locationMatrix);
crimes = length(which(distancetoPoint < crimeRadius))
crimesPerDay = crimes/as.numeric(days)
crimeRating = ecdf(crimeIndex$x)(crimesPerDay) * 100;

cat(crimeRating)

#4. Creating the summary 



#5. Making the score timeline ----
con <- dbConnect(dbDriver("SQLite"), dbname = "PoliceIncidents.sqlite")
sqlcmd <- paste("Select * from PoliceIncidents where latitude > ", lowerBoundLat,
                " and latitude < ",upperBoundLat,
                " and longitude > ",lowerBoundLon,
                " and longitude < ",upperBoundLon
                ,sep="") 

localDataAllYears = dbGetQuery(con, sqlcmd)
nothing = dbDisconnect(con)

b = Sys.time();
upperBoundLat = latitude + latDiff; lowerBoundLat = latitude - latDiff;
upperBoundLon = longitude + lonDiff; lowerBoundLon = longitude - lonDiff;
years = 2010:2015
crimeRatingYear = 0
setwd("crimeIndexFiles")
for (i in years){
  fname = paste("crimeIndexUniform",i,".csv",sep="")
  
  crimeIndex <- read.table(fname,sep=",",header=TRUE)
  crimeIndex <- crimeIndex$x
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
  
  crimesPerDay = crimes/as.numeric(days)  
  
  crimeIndex = (crimeIndex[which(crimeIndex<quantile(crimeIndex,0.9))])
  
  crimeRatingYear[i-2009] = ecdf(crimeIndex)(crimes) * 100;
  
  
}
elapse = Sys.time() - b;

outputJ = data.frame(crimeRating,crimeRatingYear)

return(toJSON(outputJ))

}
