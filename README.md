---
title: "README"
author: "Xabi"
date: "Monday, January 19, 2015"
output: html_document
---

First, I need to download the data and unzip it
```{r}
#download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfi#les%2FUCI%20HAR%20Dataset.zip",
#              destfile = "data.zip")
#unzip("data.zip")
```

Lets look at the file names

```{r}
list.files("./UCI HAR Dataset")
list.files("./UCI HAR Dataset/test")
list.files("./UCI HAR Dataset/train")
```

It seems that files are contained in the _./UCI HAR Dataset_ folder. After reading
the readme document I understand the structure of the data.

First, I will load the features contain in the features file

```{r}
features <- readLines("./UCI HAR Dataset/features.txt")
head(features)
```

Then, lets load the test data.

```{r}
test <- read.table("./UCI HAR Dataset/test/X_test.txt", sep = "")
dim(test)
```

The dimensions of the data have the same number of columns as features
I name the columns as features

```{r}
names(test) <- features
head(names(test))
```
lets put the y variable in a new column.
```{r}
testy <- readLines("./UCI HAR Dataset/test/Y_test.txt")
```
And add it at the end of the data frame,andchange its name to "outcome"
I also need to load the dplyr package
```{r, message=FALSE}
library(dplyr)
```

```{r}
test <- cbind(test, testy)
test <- rename(test, outcome = testy)
```

now, lets do the same thing with the train part

```{r}
train <- read.table("./UCI HAR Dataset/train/X_train.txt", sep = "")
dim(train)
```

the number of dimensions and features match here too. So lets change
the name of the variables

```{r}
names(train) <- features
head(names(train))
```
I introduce and paste the outcome variable as made before.
```{r}
trainy <- readLines("./UCI HAR Dataset/train/Y_train.txt")
train <- cbind(train, trainy)
train <- rename(train, outcome = trainy)
```
Done!! now lets merge the two data tables. As all of them are different cases, the best option
is the command rbind
```{r}
data <- rbind (train, test)
```
now I select the variables that contain in any part of the variable
name the word mean or std either capitalized or not, and I add it to a 
new variable called datasm. I also select the outcome variable.
```{r}
datasm <- select(data, grep(".*([Mm]ean|[Ss]td)", features), outcome)
```
Now I change the names to the outcome variable.
First I have to load the variable names from the "activity_labels.txt"
document. I load them into the labels object
```{r}
labels <- readLines("./UCI HAR Dataset/activity_labels.txt")
labels
```
As the list of characters start with a number, I have to remove it.
```{r}
labels <- strsplit(labels, " ")
secondelement <- function(x){x[2]}
labels <- sapply(labels, secondelement)
```
Now I have the label names isolated, and in the proper order. Lets change
the factor levels of the outcome variable.
```{r}
levels(datasm$outcome) <- labels
```

The next step is to change the variable names
Appropriately labels the data set with descriptive variable names.
I will reedit the already created "feature" value
Therefore, I substract from the feature names:
1: any numeric character, parenthesis or commas
2: any spaces
3: any dashes
4: as the variable names are almost already capitalized, i capitalize
the strings "mean" and "std" only.

```{r}
features <- gsub("[1234567890(),]", "", names(datasm))
features <- gsub(" ", "", features)
features <- gsub("-", "", features)
features <- gsub("mean", "Mean", features)
features <- gsub("std", "Std", features)
```
And I add the new feature names to the variable names
```{r}
names(datasm) <- features
```
Finally, I create the new data table in an object calle table, and I
export it to results.txt to upload it to the assingment.
```{r}
datasmbyoutcome <- group_by(datasm, outcome)
table <- summarise_each(datasmbyoutcome,funs(mean))
write.table(table, "result.txt", row.name = F)
```

