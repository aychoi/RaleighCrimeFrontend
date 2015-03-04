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

#Not Raleigh Example
#latitude = 35.944275 
#longitude = -78.504000

#Raleigh Example
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

cat(crimeRating)

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

tierMult = 3;
crimeRatingYear_day = 0
crimeRatingYear_night = 0
crimeRatingYear = 0
emptyCheck = 0;

for (i in years){
  fname = paste("crimeIndexFiles/crimeIndexUniformTier",i,".csv",sep="")
  
  crimeIndex <- read.table(fname,sep=",",header=TRUE)
  crimeIndex$X <-NULL
  localData <- localDataAllYears[which(localDataAllYears$year==i),]
  emptyCheck = 0;
  days = 365
  
  locationMatrix = as.matrix(data.frame(localData$longitude,localData$latitude));
  
  if (i%%4 == 0){
    days = 366
  }
  if (i==2015 & dim(locationMatrix)[1]!=0){
    nD = max(localData$dates); fD= min(localData$dates);
    #final = paste(substr(nD,1,4),"-",substr(nD,5,6),"-",substr(nD,7,8),sep="")
    #first = paste(substr(fD,1,4),"-",substr(fD,5,6),"-",substr(fD,7,8),sep="")     
    days = as.Date(nD) - as.Date(fD)
  }
  
 

  if (dim(locationMatrix)[1]!=0){      
      distancetoPoint = distHaversine(point,locationMatrix);      
  }
  if (dim(locationMatrix)[1]==0){
    emptyCheck = 1
  }
  
  crimes = tierMult * length(which(distancetoPoint < crimeRadius & localData$tier1 == 1)) + 
                               length(which(distancetoPoint < crimeRadius & localData$tier1 == 0));
                                      
  crimes_night = tierMult * length(which(distancetoPoint < crimeRadius & localData$tier1 == 1 & localData$hour24 < 4 | localData$hour24>=20)) + 
                        length(which(distancetoPoint < crimeRadius & localData$tier1 == 0 & localData$hour24 < 4 | localData$hour24>=20));
           
  crimes_day = tierMult * length(which(distancetoPoint < crimeRadius & localData$tier1 == 1 & localData$hour24 >= 4 & localData$hour24<20)) + 
                        length(which(distancetoPoint < crimeRadius & localData$tier1 == 0 & localData$hour24 >= 4 & localData$hour24<20));
        
  #Scaling day and night crimes appropriately                              
  crimes_day = crimes_day * 3/2;
  crimes_night = crimes_night * 3;                             
  crimesPerDay = crimes/as.numeric(days)  
  
  #crimeIndex = (crimeIndex[which(crimeIndex<quantile(crimeIndex,0.9))])

  crimeRatingYear_day[i-2009] = ecdf(crimeIndex$x)(crimes_day) * 100
  crimeRatingYear_night[i-2009] = ecdf(crimeIndex$x)(crimes_night) * 100
  crimeRatingYear[i-2009] = ecdf(crimeIndex$x)(crimes) * 100;
  
  
}

crimeRatingYears = data.frame(crimeRatingYear_day,crimeRatingYear_night,crimeRatingYear)


outputJ = data.frame(crimeRatingYears)

if (emptyCheck==1){
  outputJ = "notRaleigh"
}

return(toJSON(outputJ))

}
