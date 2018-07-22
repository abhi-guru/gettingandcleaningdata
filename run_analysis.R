
#########################################
## Preparation

install.packages("data.table")
library(data.table)

## Download File
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")


#Unzip File
unzip("./data/Dataset.zip",exdir = "./data")

path_rf <- file.path("./data" , "UCI HAR Dataset")

#list.files(path_rf,recursive = TRUE)

files<-list.files(path_rf, recursive=TRUE)
#files


dtfeaturesTest <- read.table(file.path(path_rf, "test","X_test.txt"))
dtfeaturesTrain <- read.table(file.path(path_rf, "train","X_train.txt"))

dtSubjectTest <- read.table(file.path(path_rf, "test","subject_test.txt"))
dtSubjectTrain <- read.table(file.path(path_rf, "train","subject_train.txt"))

dtactivityTest <- read.table(file.path(path_rf, "test","y_test.txt"))
dtactivityTrain <- read.table(file.path(path_rf, "train","y_train.txt"))


dim(dtfeaturesTest)
dim(dtfeaturesTrain)
dim(dtSubjectTest)
dim(dtSubjectTrain)
dim(dtactivityTest)
dim(dtactivityTrain)

str(dtfeaturesTest)
str(dtfeaturesTrain)


#########################################
## Step 1: Merges the training and the test sets to create one data set.
dtfeatures <- rbind(dtfeaturesTest,dtfeaturesTrain)
dtSubject <- rbind(dtSubjectTest,dtSubjectTrain)
dtActivity <- rbind(dtactivityTest,dtactivityTrain)

str(dtfeatures)
str(dtfeatures)

names(dtActivity) <- c("activity")
names(dtSubject) <- c("subject")

dtfeatureNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dtfeatures) <- dtfeatureNames$V2


dtCombine <- cbind(dtSubject, dtActivity)
dt <- cbind(dtfeatures, dtCombine)

## Step 2: Extracts only the measurements on the mean and standard deviation for each measurement. 

subdataFeaturesNames<-dtfeatureNames$V2[grep("mean\\(\\)|std\\(\\)", dtfeatureNames$V2)]

selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
dt<-subset(dt,select=selectedNames)

str(dt)

## Step 3: Uses descriptive activity names to name the activities in the data set

activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

activityLabels

#str(dt)


dt$activity <- factor(dt$activity, labels=c("Walking","Walking_Upstairs", "Walking_Downstairs", "Sitting", "Standing", "Laying"))


str(dt$activity)
head(dt$activity,30)

## Step 4:  Appropriately labels the data set with descriptive variable names. 

names(dt)

names(dt)<-gsub("^t", "Time", names(dt))
names(dt)<-gsub("^f", "Frequency", names(dt))
names(dt)<-gsub("Acc", "Accelerometer", names(dt))
names(dt)<-gsub("Gyro", "Gyroscope", names(dt))
names(dt)<-gsub("Mag", "Magnitude", names(dt))
names(dt)<-gsub("BodyBody", "Body", names(dt))

names(dt)

## Step 5: 
#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
install.packages("plyr")
install.packages("dplyr")

library(plyr);
library(dplyr);


dt2<-aggregate(. ~subject + activity, dt, mean)
dt2<-dt2[order(dt2$subject,dt2$activity),]
write.table(dt2, file = "tidydata.txt",row.name=FALSE)
