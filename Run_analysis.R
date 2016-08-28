
## Setting-up an environment
library(reshape2)
library (data.table)
getwd()
setwd("~/Documents/STUDY/Data Science/Coursera - DS specialization/Getting and cleaning data")




## Download and unzip the dataset:
filename <- "getdata_dataset.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Reading activity labels + features
ActivityLab <- read.table("UCI HAR Dataset/activity_labels.txt")
ActivityLab[,2] <- as.character(ActivityLab[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(Features[,2])

# Getting data with mean/SD
FeaturesWithData <- grep(".*mean.*|.*std.*", Features[,2])
FeaturesWithData.Names <- Features[FeaturesWithData,2]
FeaturesWithData.Names <- gsub('-mean', 'Mean', FeaturesWithData.Names)
FeaturesWithData.Names <- gsub('-std', 'Std', FeaturesWithData.Names)
FeaturesWithData.Names <- gsub('[-()]', '', FeaturesWithData.Names)


# Loading the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[FeaturesWithData]
trainActi <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubj <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubj, trainActi, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[FeaturesWithData]
testActi <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubj <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubj, testActi, test)

# merge datasets and add labels
WholeData <- rbind(train, test)
colnames(WholeData) <- c("Subject", "Activity", FeaturesWithData.Names)

# turn activities & subjects into factors
WholeData$Activity <- factor(WholeData$Activity, levels = ActivityLab[,1], labels = ActivityLab[,2])
WholeData$Subject <- as.factor(WholeData$Subject)

WholeData.merged <- melt(WholeData, id = c("Subject", "Activity"))
WholeData.mean <- dcast(WholeData.merged, Subject + Activity ~ variable, mean)

write.table(WholeData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
