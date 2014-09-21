# steps involved in implementation
# 
#Step 1. Merges the training and the test sets to create one data set.
#Step 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#Step 3. Uses descriptive activity names to name the activities in the data set
#Step 4. Appropriately labels the data set with descriptive variable names. 
#Step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each
#  	variable for each activity and each subject.


# set the working directory
setwd("~/coursera/UCI HAR Dataset/")

# load libraries
library(reshape)
library(plyr)


xTrain = read.table("./train/X_train.txt")
yTrain = read.table("./train/y_train.txt")
subjectTrain = read.table("./train/subject_train.txt")
xTest = read.table("./test/X_test.txt")
yTest = read.table("./test/y_test.txt")
subjectTest = read.table("./test/subject_test.txt")



# format variable names
featuresdf = read.table("./features.txt")
headings = featuresdf$V2

# transfer headings to data set
colnames(xTrain) = headings
colnames(xTest) = headings


# change V1 variable to something descriptive "activity"
yTest <- rename(yTest, c(V1="activity"))
yTrain <- rename(yTrain, c(V1="activity"))

# change data values in yTest according to activity_labels.txt file

activitydf  = read.table("./activity_labels.txt")

# convert variable names to lowercase
activityLabels = tolower(levels(activitydf$V2))

# convert $activity to factor and add descriptive labels
yTrain$activity = factor(
  yTrain$activity, 
  labels = activityLabels
)

yTest$activity = factor(
  yTest$activity, 
  labels = activityLabels
)



# change subject variable name to be descriptive
subjectTrain <- rename(subjectTrain, c(V1="subjectid"))
subjectTest <- rename(subjectTest, c(V1="subjectid"))


# combine (x,y,subject) for the training and test sets
train = cbind(xTrain, subjectTrain, yTrain)
test = cbind(xTest, subjectTest, yTest)

# combine train and test set
fullData = rbind(train, test)


# Extract only the measurements on the mean and standard deviation for each measurement.


pattern = "mean|std|subjectid|activity"
tidyData = fullData[,grep(pattern , names(fullData), value=TRUE)]

# tidy up variable names

cleanNames = gsub("\\(|\\)|-|,", "", names(tidyData))
names(tidyData) <- tolower(cleanNames)

# summarize data
result = ddply(tidyData, .(activity, subjectid), numcolwise(mean))

# write file to output
write.table(result, file="tidy_data.txt", sep = "\t", append=F)
