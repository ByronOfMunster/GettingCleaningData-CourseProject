#===============================================================================
# Getting and Cleaning Data Course Project
# Author:  Byron Estes
# Date:  03/20/2015
#===============================================================================
#Load Libaries
library(plyr)
library(dplyr)

#-------------------------------------------------------------------------------
# Step 1:  Download zip file to working direcory IF IT DOES NOT ALREADY EXIST
#          If the script downloads the zip file, it will delete it when it is done.
#          If the script uses an existing zip file, it will leave it.
#-------------------------------------------------------------------------------
cleanup <- FALSE
if(!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")) {
        print("downloading...")
        zipfile <- tempfile()
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", zipfile)
        cleanup <- TRUE
} else {
        zipfile <- "getdata-projectfiles-UCI HAR Dataset.zip" 
}
#-------------------------------------------------------------------------------
# Step 2:  Read the files needed from the archive (i.e. does not explode it) and 
#          load them into data frame variables based upon their file names.
#-------------------------------------------------------------------------------
#
#          -----------------
#          Features & Labels
#          -----------------
#   	   File	Name			Data Frame Variable Name	   
#               features.txt		   features
#               activity_labels.txt	   activity_labels
#
#          ---------------
#          Test Data Files
#          ---------------
#	   File				Data Frame Variable Name
#               subject_test.txt	    subject_test
#               X_test.txt	            X_test
#               y_test.txt		    y_test
#
#          ---------------
#          Train Data Files
#          ---------------
#	   File				Data Frame Variable Name
#               subject_train.txt	   subject_train
#               X_train.txt		   X_train
#               y_train.txt		   y_train
#
#-------------------------------------------------------------------------------
# Load Features & Labels
#-------------------------------------------------------------------------------
features <- read.table(unz(zipfile, "UCI HAR Dataset/features.txt"), stringsAsFactors=FALSE)
activity_labels <- read.table(unz(zipfile, "UCI HAR Dataset/activity_labels.txt"), stringsAsFactors=FALSE)
#-------------------------------------------------------------------------------
# Load Test Data
#-------------------------------------------------------------------------------
subject_test <- read.table(unz(zipfile, "UCI HAR Dataset/test/subject_test.txt"), stringsAsFactors=FALSE)
X_test <- read.table(unz(zipfile, "UCI HAR Dataset/test/X_test.txt"), stringsAsFactors=FALSE)
y_test <- read.table(unz(zipfile, "UCI HAR Dataset/test/y_test.txt"), stringsAsFactors=FALSE)
#-------------------------------------------------------------------------------
# Load Train Data
#-------------------------------------------------------------------------------
subject_train <- read.table(unz(zipfile, "UCI HAR Dataset/train/subject_train.txt"), stringsAsFactors=FALSE)
X_train <- read.table(unz(zipfile, "UCI HAR Dataset/train/X_train.txt"), stringsAsFactors=FALSE)
y_train <- read.table(unz(zipfile, "UCI HAR Dataset/train/y_train.txt"), stringsAsFactors=FALSE)
#Delete the temp file if downloaded by script
if(cleanup) unlink(zipfile)

#-------------------------------------------------------------------------------
# Step 3:  Update subject_id column name on "subject_*" data fames.
#-------------------------------------------------------------------------------
colnames(subject_test) <- c("subject_id")
colnames(subject_train) <- c("subject_id")

#-------------------------------------------------------------------------------
# Step 4:  Update activity_id column name on "y_*" data frames.
#-------------------------------------------------------------------------------
colnames(y_test) <- c("activity_id")
colnames(y_train) <-c("activity_id")

#-------------------------------------------------------------------------------
# Step 5:  Add the activity "label" to the "y_*" data frames based upon the 
#          activity_id.  Note: used join() to preserve order
#-------------------------------------------------------------------------------
colnames(activity_labels) <- c("activity_id", "activity")
y_test_with_activity_labels <- join(y_test, activity_labels)  
y_train_with_activity_labels <- join(y_train, activity_labels)  

#-------------------------------------------------------------------------------
# Step 6:  Update the X_* data frame column names using the feature description. 
#-------------------------------------------------------------------------------
feature_names <- NULL
for (i in 1:nrow(features)) { 
        #name <- features[i,2]
        feature_names <- c(feature_names, features[i,2])        
}
colnames(X_test) <- feature_names
colnames(X_train) <- feature_names

#-------------------------------------------------------------------------------
# Step 7:  Get a list of column indexes whose feature description contains 
#          "mean()" or "std()". 
#
#          Use this to list issolate and extract only those columns into new 
#          data frames, one for test and one for train.
#-------------------------------------------------------------------------------
search <- c("mean()", "std()")
found_columns <- unique (grep(paste(search,collapse="|"), feature_names))
X_test_std_and_mean_cols_only <- X_test[,found_columns]
X_train_std_and_mean_cols_only <- X_train[,found_columns]

#-------------------------------------------------------------------------------
# Step 8:  Combine the columns from the 3 test files together into a single new
#          data frame, then do the same for the 3 train files.
#-------------------------------------------------------------------------------
test <- cbind(subject_test, y_test_with_activity_labels, X_test_std_and_mean_cols_only)
train <- cbind(subject_train, y_train_with_activity_labels, X_train_std_and_mean_cols_only)

#-------------------------------------------------------------------------------
# Step 9:  Combine the test and train data into a single data frame
#-------------------------------------------------------------------------------
test_and_train <- rbind(test, train)

#-------------------------------------------------------------------------------
# Step 10:  Alphabetize "Groups" (i.e. pairs and triplets of features) to make 
#           locating columns by feature name easier. Force subject_id to first
#           column.
#-------------------------------------------------------------------------------
unsorted <- colnames(test)
sorted<- sort(unsorted)
sorted_with_subject_moved_to_front <- c(sorted[42], sorted[1:41],sorted[43:82])
alphabetized_test_and_train <- test_and_train[sorted_with_subject_moved_to_front]

#-------------------------------------------------------------------------------
# Step 11: Group the combined test and train data by subject and activity.
#          Compute means for all variables by group. 
#          Order the result by subject (primary) and activity "name" (secondary)
#          Note: Drop activity label for this one. 
#-------------------------------------------------------------------------------
means_by_subject_and_activity <- test_and_train %>% 
         group_by(subject_id, activity_id) %>% 
         summarise_each(funs(mean), -activity) %>%
         arrange(subject_id, activity_id)

#-------------------------------------------------------------------------------
# Step 12:  Save data frame with means grouped by subject and activity to a file.
#-------------------------------------------------------------------------------
write.table(means_by_subject_and_activity,
            "means_by_subject_and_activity.txt", 
            append=FALSE,
            row.name=FALSE)

#-------------------------------------------------------------------------------
# Code to read the file created in Step 12.  Uncomment to use.
#-------------------------------------------------------------------------------
#means_by_subject_and_activity <- read.table("means_by_subject_and_activity.txt",
#                                            stringsAsFactors = FALSE, 
#                                            header=TRUE)

