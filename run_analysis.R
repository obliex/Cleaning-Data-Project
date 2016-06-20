# Set working directory
setwd("~/UCI HAR Dataset")

# Read and clean variable names to make them R-Friendly
variables = read.csv("features.txt", sep="", header=FALSE)
variables[,2] = data.frame(gsub("-", "", variables$V2))
variables[,2] = data.frame(gsub("[()]","", variables$V2))
variables[,2] = data.frame(gsub(",","", variables$V2))

# Read Training Data
# Add flag "Training" to id records after merge in subsequent step
trngData = read.csv("train/X_train.txt", sep="", header=FALSE)
trngData <- cbind(trngData,read.csv("train/Y_train.txt", sep="", header=FALSE))
trngData <- cbind(trngData,read.csv("train/subject_train.txt", sep="", header=FALSE))
trngData[,length(trngData)+1] = "Training"
colnames(trngData) <- c(as.character(variables$V2),"Activity","Subject","Flag")


# Read TestData
# Add flag "Test" to id records after merge in subsequent step
testData = read.csv("test/X_test.txt", sep="", header=FALSE)
testData <- cbind(testData,read.csv("test/Y_test.txt", sep="", header=FALSE))
testData <- cbind(testData,read.csv("test/subject_test.txt", sep="", header=FALSE))
testData[,length(testData)+1] = "Test"
colnames(testData) <- c(as.character(variables$V2),"Activity","Subject","Flag")


# Merge Test and Training Data and assign column names
mergedData <- rbind(testData,trngData)


#Find the rows that have mean and std values. Don't forget to add activity and subject
mean_std_rows <- grep('([Mm]ean|[Ss]td)', variables[,2])
mean_std_rows[length(mean_std_rows)+1] = 562
mean_std_rows[length(mean_std_rows)+1] = 563
mean_std_rows[length(mean_std_rows)+1] = 564

# Create data set with means and standard deviation variables
meanstdonly <- mergedData[,mean_std_rows]

# Read activity lables and merge with above data set
activities = read.csv("activity_labels.txt", sep="", header=FALSE)

meanstdlabeled <- merge(activities,meanstdonly,by.x = "V1", by.y = "Activity")
names(meanstdlabeled)[2]<-paste("Activity")
meanstdlabeled <- select(meanstdlabeled,-V1)

# aggregate data and remove unnecessary columns
output = aggregate(meanstdlabeled, by=list(activity = meanstdlabeled$Activity,subject = meanstdlabeled$Subject), mean)
drops <- c("Activity","Flag","Subject")
output <- output[ , !(names(output) %in% drops)]

#print txt file
write.table(output,"output.txt", sep="\t")
