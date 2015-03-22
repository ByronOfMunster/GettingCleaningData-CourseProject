---
title: "Getting and Cleaning Data Course Project"
author: "Byron Estes"
date: "Saturday, March 21, 2015"
output: html_document
---

========================
List of Files in Project
========================

1) run_analysis.R - R script 
2) codebook.txt - Data dictionary for the final data product 
   means_by_subject_and_activity
3) means_by_subject_and_activity.txt which is #2 saved to a file. 
4) datflow.png  - Graphical depiction of the tidying process.

==============
run_analysis.R
==============

This purpose of this script is to create a tidy dataset from the "Human Activity 
Recognition Using Smartphones Dataset v1.0" which can be found here:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

More info about the Human Activity Recognition Using Smartphones can be found here:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

General Approach to Tiding the Data for the Project:

I chose the following high level approach to cleaning my data:

 1) Get each raw file as tidy as it "can be" (e.g. adding column names, do any 
    enrichments, etc.) I also filter the columns for both the test and train X_* files 
    on only contain the mean and std dev columns.
 2) "Stitch" together the columns from the raw test and raw training files 
    separately so that I have a complete test data frame and an independent complete
    train data frame.
 3) Finally, create a single dataset by combining the rows from the test and train 
    data frames together.
    
    Motivation:  
    I chose this order because I believe it makes the data more reusable either to
    summarize separately or to perform other analysis upon.  
    
    For example...
    if you wanted to summarize only the train or test data, you could do that because 
    I preserved the interim data sets in a logical fashion.
    
    One improvement would be to wait to filter the columns until after the file sets
    for test and tain were stitched together.    

Below are the steps I took to massage the raw data into a tidy dataset.  

These are the SAME comments documenting each step in the script, but here I provide
some of my motivation/thought process and I call out interim datasets I create 
along the way.  
    
As a "bonus"", I've provided a diagram showing the data flow from raw data, 
though interim stages into it's final tidy form.  
    
http://dataflow.png

Step 1: Download zip file to working direcory, IF IT DOES NOT ALREADY EXIST.      
        If the script downloads the zip file, it will delete it when it is done.
        If the script uses an existing zip file, it will leave it.              

        Motivations for Step #1:
	I did this to avoid unnecessary downloads, yet insure I the script has the
	data it needs to function.  Similary, I clean up what I did to be kind to 
	the user.



Step 2: Read the raw files needed from the archive (i.e. does not explode it)  
        and load them into data frame variables based upon their file names.


          -----------------
          Features & Labels
          -----------------
                File Name                       Data Frame Variable Name	   
                    features.txt		   features
                    activity_labels.txt	           activity_labels
                        
          ---------------
          Test Data Files
          ---------------
		File Name		        Data Frame Variable Name
                    subject_test.txt		   subject_test
                    X_test.txt			   X_test
                    y_test.txt			   y_test

          ---------------
          Train Data Files
          ---------------
                File Name                       Data Frame Variable Name
                    subject_train.txt		   subject_train
                    X_train.txt		           X_train
                    y_train.txt		           y_train


	Motivations for Step #2:
	I liked the idea of only extracting exactly what was needed from the 
	zip file.  It's cleaner and doesn't duplicate files on the hard drive.
	Naming the raw data frame variables EXACTLY like the file name makes it 
	easy to understand and know what the dataframe contains.
	

 Step 3:  Update subject_id column name on "subject_*" data fames.

	Motivations for Step #3
	The subject_test and subject_train data frames did not have a descriptive
	column name, so I add it (subject_id)
	 

 Step 4:  Update activity_id column name on "y_*" data frames.

	Motivations for Step #4
	The y_test and y_train data frames did not have a descriptive
	column name, so I added it (activity_id)
	

 Step 5:  Add the activity "label" to the "y_*" data frames based upon the 
          activity_id.  

	Motivations for Step #5
	I added the activity label, names simply "activity" so the datset had both 
	the activity_id and activity as tex (e.g. WALKING).  This is a convenience 
	but would also be useful in some reports, graphs, etc.
	
	Creates new data frames:
	-  y_test_with_activity_labels
	-  y_train_with_activity_labels
	

 Step 6:  Update the X_* data frame column names using the feature description. 

	Motivations for Step #6
	Neither the X_test or X_train data frames had descriptive columns so I 
	took the feature names from the feature dataset and used this to update 
	the column names on both of these datasets.


 Step 7:  Get a list of column indexes whose feature description contains 
          "mean()" or "std()". 

         Use this to list issolate and extract only those columns into new 
         data frames, one for test and one for train.

	Creates new data frames:
	-  X_test_std_and_mean_cols_only
	-  X_train_std_and_mean_cols_only


 Step 8:  Combine the columns from the 3 test files together into a single new
          data frame, then do the same for the 3 train files.

	Creates new data frames:
	-  test
	-  train


 Step 9:  Combine the test and train data into a single data frame

	Creates new data frame:
	-  test_and_train


 Step 10:  Alphabetize "Groups" (i.e. pairs and triplets of features) to make 
           locating columns by feature name easier.

	Creates new data frame:
	-  alphabetized_test_and_train
	

 Step 11:  Group the combined test and train data by subject and activity.
           Compute means for all variables by group. 
           Order the result by subject (primary) and activity "name" (secondary)

	Creates new data frame:
	-  means_by_subject_and_activity
	See codebook.txt for data dictionary.


 Step 12:  Save data frame with means grouped by subject and activity to a file.
           file name is "means_by_subject_and_activity.txt".


R Code to read the file created in Step 12:

means_by_subject_and_activity <- read.table("means_by_subject_and_activity.txt",
                stringsAsFactors = FALSE, 
                header=TRUE)
