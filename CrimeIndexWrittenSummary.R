

require(rjson); require(RSQLite); require(lubridate);
require(geosphere)


CrimeWrittenSummary <- function(args){
  
  
  locationData <- fromJSON(args);
  #change colnames of locationData if neccessary
  longitude = as.numeric(locationData$longitude)
  latitude = as.numeric(locationData$latitude)
  
  
  #latitude = 35.784519 
  #longitude = -78.672733
  point = c(longitude, latitude);
  
  crimeRadius = 0.3*1609.344  
  
  cat.driving = c("DRIVING", "VEHICLE")
  cat.drugs = c("DRUGS","ALCOHOL")
  cat.theft = c("BURGLARY", "ROBBERY", "FRAUD", "LARCENY", "FORGERY", "STOLEN PROPERTY", "EMBEZZLEMENT")
  cat.property = c("DAMAGE PROPERTY")
  cat.violent = c("ASSAULT", "WEAPONS", "KIDNAPPING", "HUMAN TRAFFICKING", "HOMICIDE")
  cat.sexual = c("SEX OFFENSE", "PROSTITUTION", "PORNOGRAPHY")
  cat.misc = c("MISC", "HUMANE", "CHILD", "FAMILY", "JUVENILE", "DISORDERLY", "EXTORTION", "GAMBLING", "ALL", "NOISE")
  
  
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
    #for (j in 1:8){
      #dummy = crimeIndex[,j];
      #dummy = dummy[which(dummy<quantile(dummy,0.9))]
      #crimeIndex[,j] = dummy
    #}
    crimeRatingYear_driving[i-2009] = ecdf(crimeIndex[,1])(crimes_driving) * 100;
    crimeRatingYear_drugs[i-2009] = ecdf(crimeIndex[,2])(crimes_drugs) * 100
    crimeRatingYear_misc[i-2009] = ecdf(crimeIndex[,3])(crimes_misc) * 100
    crimeRatingYear_property[i-2009] = ecdf(crimeIndex[,4])(crimes_property) * 100
    crimeRatingYear_sexual[i-2009] = ecdf(crimeIndex[,5])(crimes_sexual) * 100
    crimeRatingYear_theft[i-2009] = ecdf(crimeIndex[,6])(crimes_theft) * 100
    crimeRatingYear_violent[i-2009] = ecdf(crimeIndex[,7])(crimes_violent) * 100
    crimeRatingYear[i-2009] = ecdf(crimeIndex[,8])(crimes) * 100;
    
    
  }

#The first two sentences are using 2014 data to make its comparisons. The third sentence is using a timetrend.
  
#Sentence one - describes overall crime in the area
firstMessages = c("very safe","safe","relatively safe","moderately dangerous","dangerous","very dangerous")
firstSeeds = c(0,10,30,50,70,90)
choice = length(firstSeeds[firstSeeds<crimeRatingYear[5]])
message1 = paste("Based on our analytics, with an index of ",round(crimeRatingYear[5]), " this is a ",firstMessages[choice],
                " area compared to the rest of Raleigh.",sep="");

#Sentence two - describes relatively dangerous and safe types of crimes

ratings = c(crimeRatingYear_drugs[5],crimeRatingYear_property[5],crimeRatingYear_sexual[5],crimeRatingYear_theft[5],crimeRatingYear_violent[5])
types = c("drugs and alcohol related","property damage","sexual offense","burglary and larceny related","violent")
check = 0;
highIndex = order(ratings, decreasing = TRUE)[1:2]
lowIndex = order(ratings, decreasing = FALSE)[1:2]
if (length(ratings[ratings>70])==5){
  part1 = "Unfortunately, this area has high occurances of all types of crimes."
  part2 = paste("Relative to the other types of crimes, it is somewhat safe for",types[lowIndex[1]],"and",
                types[lowIndex[2]],"crimes with scores of",round(ratings[lowIndex[1]]),"and",
                round(ratings[lowIndex[2]]),"but it is unsafe for",types[highIndex[1]],"and",types[highIndex[2]],
                "crimes with scores of",round(ratings[highIndex[1]]),"and", round(ratings[highIndex[2]]))
  message2 = paste(part1,part2)
  check = 1;
} 
if (length(ratings[ratings<35])==5){
  part1 = "This area has low incidents of all types of crimes!"
  part2 = paste("Relative to the other types of crimes, it is very safe for",types[lowIndex[1]],"and",
                types[lowIndex[2]],"crimes with scores of",round(ratings[lowIndex[1]]),"and",
                round(ratings[lowIndex[2]]),"but it is a bit more unsafe for",types[highIndex[1]],"and",types[highIndex[2]],
                "crimes with scores of",round(ratings[highIndex[1]]),"and", round(ratings[highIndex[2]]))
  check = 2;
  message2 = paste(part1,part2)
} 
if (check==0){
  message2 = paste("Relative to the other types of crimes, it is safe for",types[lowIndex[1]],"and",
                     types[lowIndex[2]],"crimes with scores of",round(ratings[lowIndex[1]]),"and",
                     round(ratings[lowIndex[2]]),"but it is unsafe for",types[highIndex[1]],"and",types[highIndex[2]],
                     "crimes with scores of",round(ratings[highIndex[1]]),"and", round(ratings[highIndex[2]]))
}

#Sentence three - describes trend over the years
x = 1:5
reg <- lm(crimeRatingYear[1:5] ~ x)
trend = as.numeric(reg$coefficients[2])
sign = "positive"; if (trend<0){sign = "negative"}
addition = ""; if (abs(trend)<2){addition = "slightly"}

message3 = paste(". Over the past five years, there has been a",addition,sign,"trend of",as.character(round(trend,2)),"crime index points per year")
if (sign == "positive"){
  message3 = paste(message3,"implying that it has been getting slowly more dangerous");
}
if (sign == "negative"){
  message3 = paste(message3,"meaning that it is getting safer each year")  
}

#Sentence four - 

localData <- localDataAllYears[which(localDataAllYears$year==2014),];
locationMatrix = as.matrix(data.frame(localData$longitude,localData$latitude));
distancetoPoint = distHaversine(point,locationMatrix);
crimes = length(which(distancetoPoint < crimeRadius));
crimesNight = length(which(distancetoPoint < crimeRadius & (localData$hour>21 | localData$hour < 4) ));
nightPercent = crimesNight/crimes * 100;
modifier = "large"; if (nightPercent < 60){modifier = "good"}; if (nightPercent < 45){modifier = "fair"}; if (nightPercent <30){modifier = "small"}
message4 = paste(". Finally, a",modifier,"amount of crimes,",round(nightPercent),"percent, happen in the night from 9:00pm to 4:00am")

#Full message
message = paste(message1," ",message2,message3,message4,sep="")


return(toJSON(message))
  
}