## libraries
library(ggplot2)
library(plotly)
library(dplyr)
library(hms)
library(lubridate)


## set file directory
setwd('C:/Users/Vidusha/Documents/MSA/CarolinaDataChallenge/datasets-main/FootballDatasets/NFL/CumulativeStats')

## read in 1 file to explore
test = read.csv('nfl2000stats.csv')
ncol(test) #30 cols in each dataset

#get col names
tablenames = colnames(test)
tablenames
## get list of files
filelist <- list.files(path = "C:/Users/Vidusha/Documents/MSA/CarolinaDataChallenge/datasets-main/FootballDatasets/NFL/CumulativeStats", ignore.case = TRUE)
filelist

## create list of seasons
seasonlist = seq(2000,2013)
seasonlist

## create blank df for vertical merging
## 31 cols as we are adding season column
compiled <- data.frame(matrix(ncol = 31, nrow = 0))
colnames(compiled) <- tablenames
names(compiled)

counter = 1

## loop through each file
## subset each file into the specified stats
## merge
for (i in filelist)
{
  filename = i
  pathname = 'C:/Users/Vidusha/Documents/MSA/CarolinaDataChallenge/datasets-main/FootballDatasets/NFL/CumulativeStats/'
  filelocation = paste(pathname,filename, sep = "")
  loopdf <- read.csv(file = filelocation,
                   header = TRUE,
                   stringsAsFactors = FALSE,
                   na.strings = "NA")
  print(ncol(loopdf))
  loopdf = loopdf[,tablenames]
  loopdf$Season = seasonlist[counter]
  counter = counter + 1
  compiled <- rbind(compiled, loopdf)
  
  
}

teamnames = unique(compiled$TeamName)

#list of teams of interest
c('Jacksonville Jaguars','Tampa Bay Buccaneers','Tennessee Titans',
  'Cincinnati Bengals','Buffalo Bills','Seattle Seahawks','Green Bay Packers',
  'Pittsburgh Steelers','New England Patriots','Dallas Cowboys')

## subset df into just the wanted teams
nfldata = compiled
colnames(nfldata)

## remove percent sign
nfldata$ThirdDownPctOff = as.numeric(gsub('%','', nfldata$ThirdDownPctOff))
nfldata$ThirdDownPctDef = as.numeric(gsub('%','', nfldata$ThirdDownPctDef))

## calculate other metrics
nfldata$YdsPerRushOff = nfldata$RushYdsOff / nfldata$RushAttOff
nfldata$YdsPerRushDef = nfldata$RushYdsDef / nfldata$RushAttDef

nfldata$CompPctOff = (nfldata$PassCompOff / nfldata$PassAttOff) * 100
nfldata$CompPctDef = (nfldata$PassCompDef / nfldata$PassAttDef) * 100

nfldata$YdsPerPassOff = nfldata$PassYdsOff / nfldata$PassCompOff
nfldata$YdsPerPassDef = nfldata$PassYdsDef / nfldata$PassCompDef

nfldata$ScoreDiff = nfldata$ScoreOff - nfldata$ScoreDef
nfldata$Win = nfldata$ScoreDiff > 0

#Select vars of interest, split into off and def
nfldatanames = colnames(nfldata)
nfldatanames

#only keep wanted vars

offnames = nfldatanames[c(31,2,3,4,5,7,32,10,34,36,11,12,38,39)]
nfloff = nfldata[,offnames]

defnames = nfldatanames[c(31,2,18,19,20,22,33,25,37,26,27,38,39)]
nfldef = nfldata[,defnames]

## write all files to a csv to be used for SAS
write.csv(compiled, 'C:/Users/Vidusha/Documents/MSA/CarolinaDataChallenge/CompiledStats.csv', row.names = FALSE)
write.csv(nfldata, 'C:/Users/Vidusha/Documents/MSA/CarolinaDataChallenge/CondensedStats.csv', row.names = FALSE)
write.csv(nfloff, 'C:/Users/Vidusha/Documents/MSA/CarolinaDataChallenge/OffensiveStats.csv', row.names = FALSE)
write.csv(nfldef, 'C:/Users/Vidusha/Documents/MSA/CarolinaDataChallenge/DefensiveStats.csv', row.names = FALSE)


