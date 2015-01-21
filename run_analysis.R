#Welcome to exercise!!

#First, I need to download the data and unzip it

#download and unzip the data
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfi#les%2FUCI%20HAR%20Dataset.zip",
              destfile = "data.zip")
unzip("data.zip")

#Lets look at the file names

list.files()
list.files("./UCI HAR Dataset")
list.files("./UCI HAR Dataset/test")
list.files("./UCI HAR Dataset/train")

#It seems that files are contained in the "./UCI HAR Dataset" folder. After reading
#the readme document I understand the structure of the data.

#First, I will load the features contain in the features file

features <- readLines("./UCI HAR Dataset/features.txt")
head(features)

#Then, lets load the test data.

test <- read.table("./UCI HAR Dataset/test/X_test.txt", sep = "")
dim(test)

#The dimensions of the data have the same number of columns as features
#I name the columns as features

names(test) <- features
head(test)

#lets put the y variable in a new column.

testy <- readLines("./UCI HAR Dataset/test/Y_test.txt")
test <- cbind(test, testy)
train <- rename(test, outcome = testy)

#And add it at the end of the data frame,andchange its name to "outcome"
library(dplyr)
test <- cbind(test, testy)
test <- rename(test, outcome = testy)

#now, lets do the same thing with the train part

train <- read.table("./UCI HAR Dataset/train/X_train.txt", sep = "")
dim(train)

#the number of dimensions and features match here too. So lets change
#the name of the variables

names(train) <- features
train

#I introduce and paste the outcome variable as made before.

trainy <- readLines("./UCI HAR Dataset/train/Y_train.txt")
train <- cbind(train, trainy)
train <- rename(train, outcome = trainy)

#Done!! now lets merge the two data tables. As all of them are different cases, the best option
#is the command rbind

data <- rbind (train, test)

#now I select the variables that contain in any part of the variable
#name the word mean or std either capitalized or not, and I add it to a 
#new variable called datasm. I also select the outcome variable.

datasm <- select(data, grep(".*([Mm]ean|[Ss]td)", features), outcome)

#Now I change the names to the outcome variable.
#First I have to load the variable names from the "activity_labels.txt"
#document. I load them into the labels object

labels <- readLines("./UCI HAR Dataset/activity_labels.txt")
labels

#As the list of characters start with a number, I have to remove it.

labels <- strsplit(labels, " ")
secondelement <- function(x){x[2]}
labels <- sapply(labels, secondelement)

#Now I have the label names isolated, and in the proper order. Lets change
#the factor levels of the outcome variable.
levels(datasm$outcome) <- labels

#The next step is to change the variable names
#Appropriately labels the data set with descriptive variable names.
#I will reedit the already created "feature" value
#Therefore, I substract from the feature names:
#1: any numeric character, parenthesis or commas
#2: any spaces
#3: any dashes
#4: as the variable names are almost already capitalized, i capitalize
#the strings "mean" and "std" only.

features <- gsub("[1234567890(),]", "", names(datasm))
features <- gsub(" ", "", features)
features <- gsub("-", "", features)
features <- gsub("mean", "Mean", features)
features <- gsub("std", "Std", features)

#And I add the new feature names to the variable names
names(datasm) <- features

#Finally, I create the new data table in an object calle table, and I
#export it to results.txt to upload it to the assingment.
datasmbyoutcome <- group_by(datasm, outcome)
table <- summarise_each(datasmbyoutcome,funs(mean))
write.table(table, "result.txt", row.name = F)
