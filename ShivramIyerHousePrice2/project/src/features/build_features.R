
# Libraries ---------------------------------------------------------------

library(data.table)


# Load data ---------------------------------------------------------------

DT <- fread('./project/volume/data/raw/2008.csv')
str(DT)


# Subset data -------------------------------------------------------------

sub_DT <- DT[!is.na(DT$DepDelay), .(Month,DayOfWeek,Origin,Dest,DepTime,DepDelay)]
str(sub_DT)


# Divide data into 'train' and 'test' -------------------------------------
### note that you do NOT need to do this on your dataset
### here I divide the data into train and test
### so that I'm working on a similar problem as all of you

set.seed(380)
rand_inx <- sample(1:nrow(sub_DT),1000000)

train <- sub_DT[!rand_inx,]
test <- sub_DT[rand_inx,]


# Write 'train' and 'test' on 'interim' -----------------------------------

fwrite(train, './project/volume/data/interim/train.csv')
fwrite(test, './project/volume/data/interim/test.csv')
