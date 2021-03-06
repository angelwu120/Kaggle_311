
library(randomForest)
library(imputation)
library(MASS)
library(party)

setwd("/Users/Angie/Desktop/RPI/Courses/MGMT 6963/assignment/2")
raw_trainset <- read.csv("train.csv")
raw_testset <- read.csv("test.csv")
raw_sample <- read.csv("sampleSubmission.csv")

raw_testset$num_votes <- 0
raw_testset$num_comments <- 0
raw_testset$num_views <- 0

#raw_fullset<-rbind(raw_testset,raw_trainset)

train <- raw_trainset
test <- raw_testset

train$miss_type <- is.na(train$tag_type)
train$miss_source <- is.na(train$source)

test$miss_type <- is.na(test$tag_type)
test$miss_source <- is.na(test$source)

###################################
### change longitutue into city ###
###################################
#longitude < -100, Oakland
#-90 < longitude < -80, Chicago
#-80 < longitude < -75, Richmond
#otherwise New Haven.

train$city [train$longitude <  -100] <- "Oakland"
train$city [ train$longitude > -90] <- "Chicago"
train$city [ train$longitude > -80] <- "Richmond"
train$city [ train$longitude > -75] <- "New Haven"
train$city<-as.factor(train$city)

test$city [test$longitude <  -100] <- "Oakland"
test$city [test$longitude > -90] <- "Chicago"
test$city [test$longitude > -80] <- "Richmond"
test$city [test$longitude > -75] <- "New Haven"
test$city<-as.factor(test$city)

########################################
### data clean! source and tag_type! ###
########################################

### prediction for source ###
train_small <-na.omit(train)
test_small <-na.omit(test)

SourceFormula <- source ~ num_views + num_votes + num_comments + city 

source_ctree_train <- ctree(SourceFormula, data=train_small)
source_ctree_test <- ctree(SourceFormula, data=test_small)

train$source[is.na(train$source)] <- predict(source_ctree_train, newdata = train)[is.na(train$source)]
test$source[is.na(test$source)] <- predict(source_ctree_test, newdata = test)[is.na(test$source)]

### check NA in source ###
#train_miss_source<-subset(test, is.na(train$source))
#test_miss_source<-subset(test, is.na(test$source))

train1<-train
test1<-test

## flag here...
#train<-train1 
#test<-test1

####################################
### how to clean NA in tag_types ###
####################################

train$tag_type<-as.character(train$tag_type)
test$tag_type<-as.character(test$tag_type)

### train set 
train_miss_type<-subset(train, is.na(train$tag_type))

train$tag_type[agrep("pavement", train$summary, ignore.case=TRUE)] <-'sidewalk'
train$tag_type[agrep("alley", train$summary, ignore.case=TRUE)] <-'street'
train$tag_type[agrep("dumping", train$summary, ignore.case=TRUE)] <-'trash'
train$tag_type[agrep("abandon", train$summary, ignore.case=TRUE)] <-'abandoned_vehicles'
train$tag_type[agrep("Rodent", train$summary, ignore.case=TRUE)] <-'rodents'
train$tag_type[agrep("park", train$summary, ignore.case=TRUE)] <-'parking_meter'
train$tag_type[agrep("tree", train$summary, ignore.case=TRUE)] <-'tree'
train$tag_type[agrep("limbs", train$summary, ignore.case=TRUE)] <-'tree'
train$tag_type[agrep("grass", train$summary, ignore.case=TRUE)] <-'tree'
train$tag_type[agrep("pothole", train$summary, ignore.case=TRUE)] <-'pothole'
train$tag_type[agrep("Graffiti", train$summary, ignore.case=TRUE)] <-'graffiti'
train$tag_type[agrep("brush", train$summary, ignore.case=TRUE)] <-'brush_bulk'
train$tag_type[agrep("bulk", train$summary, ignore.case=TRUE)] <-'brush_bulk'
train$tag_type[agrep("bulk", train$description, ignore.case=TRUE)] <-'brush_bulk'
train$tag_type[agrep("light", train$summary, ignore.case=TRUE)] <-'street_light'
train$tag_type[agrep("signal", train$summary, ignore.case=TRUE)] <-'street_signal'
train$tag_type[agrep("prostitutes", train$summary, ignore.case=TRUE)] <-'prostitutes'
train$tag_type[agrep("trash", train$summary, ignore.case=TRUE)] <-'trash'

## integer similar tags
train$tag_type[train$tag_type=='abandoned_vehicle']<-'abandoned_vehicles'
train$tag_type[train$tag_type=="roadkill"] <-'road_safety'
train$tag_type[train$tag_type=="pedestrian_light"] <-'street_light'
train$tag_type[train$tag_type=="rodents"] <-'animal_problem'
train$tag_type[train$tag_type=="bad_driving"] <-'road_safety'
train$tag_type[train$tag_type=="noise_complaint"] <-'noise_odor'
train$tag_type[train$tag_type=="odor"] <-'noise_odor'
train$tag_type[train$tag_type=="zoning"] <-'traffic'
train$tag_type[train$tag_type=="crosswalk"] <-'street'
train$tag_type[train$tag_type=="drain_problem"] <-'pothole'
train$tag_type[train$tag_type=="prostitutes"] <-'prostitution'

## change "small tages" into "other"
train$tag_type[train$tag_type=="public_art"] <-'other'
train$tag_type[train$tag_type=="public_concern"] <-'other'
train$tag_type[train$tag_type=="lost_and_found"] <-'other'
train$tag_type[train$tag_type=="illegal_idling"] <-'other'

train$tag_type[is.na(train$tag_type)]<- "other"
train.other<-subset(train,tag_type=="other")

                    
### test set 
test_miss_type<-subset(test, is.na(test$tag_type))

test$tag_type[agrep("pavement", test$summary, ignore.case=TRUE)] <-'sidewalk'
test$tag_type[agrep("alley", test$summary, ignore.case=TRUE)] <-'street'
test$tag_type[agrep("Vehicle", test$summary, ignore.case=TRUE)] <-'abandoned_vehicles'
test$tag_type[agrep("abandon", test$summary, ignore.case=TRUE)] <-'abandoned_vehicles'
test$tag_type[agrep("Dumping", test$summary, ignore.case=TRUE)] <-'trash'
test$tag_type[agrep("Rodent", test$summary, ignore.case=TRUE)] <-'rodents'
test$tag_type[agrep("tree", test$summary, ignore.case=TRUE)] <-'tree'
test$tag_type[agrep("limbs", test$summary, ignore.case=TRUE)] <-'tree'
test$tag_type[agrep("grass", test$summary, ignore.case=TRUE)] <-'tree'
test$tag_type[agrep("pothole", test$summary, ignore.case=TRUE)] <-'pothole'
test$tag_type[agrep("Graffiti", test$summary, ignore.case=TRUE)] <-'graffiti'
test$tag_type[agrep("brush", test$summary, ignore.case=TRUE)] <-'brush_bulk'
test$tag_type[agrep("bulk", test$summary, ignore.case=TRUE)] <-'brush_bulk'
test$tag_type[agrep("bulk", test$description, ignore.case=TRUE)] <-'brush_bulk'
test$tag_type[agrep("light", test$summary, ignore.case=TRUE)] <-'street_light'
test$tag_type[agrep("signal", test$summary, ignore.case=TRUE)] <-'street_signal'
test$tag_type[agrep("prostitutes", test$summary, ignore.case=TRUE)] <-'prostitutes'
test$tag_type[agrep("trash", test$summary, ignore.case=TRUE)] <-'trash'

## integer similar tags
test$tag_type[test$tag_type=='abandoned_vehicle']<-'abandoned_vehicles'
test$tag_type[test$tag_type=="pedestrian_light"] <-'street_light'
test$tag_type[test$tag_type=="roadkill"] <-'road_safety'
test$tag_type[test$tag_type=="rodents"] <-'animal_problem'
test$tag_type[test$tag_type=="bad_driving"] <-'road_safety'
test$tag_type[test$tag_type=="noise_complaint"] <-'noise_odor'
test$tag_type[test$tag_type=="odor"] <-'noise_odor'
test$tag_type[test$tag_type=="zoning"] <-'traffic'
test$tag_type[test$tag_type=="crosswalk"] <-'street'
test$tag_type[test$tag_type=="drain_problem"] <-'pothole'
test$tag_type[test$tag_type=="prostitutes"] <-'prostitution'

## change "small tages" into "other"
test$tag_type[test$tag_type=="bus_lane"] <-'other'
test$tag_type[test$tag_type=="illegal_idling"] <-'other'

test$tag_type[is.na(test$tag_type)]<- "other"
test.other<-subset(test,tag_type=="other")


### combine into full data ###
train$tag_type<-as.factor(train$tag_type)
test$tag_type<-as.factor(test$tag_type)
fulldata<-rbind(test,train)




########################
### Cross Validation ###
########################
formula<-num_views ~  city + source + tag_type + miss_type 
formula2<-num_votes ~ city + source + tag_type + miss_type + num_views 
formula3<-num_comments ~ city + source + tag_type + miss_type + num_views 

train.cv1 <- train[1:111564,]
train.cv2 <- train[111565:223128,]
## CV1
train.cv1.rf <- randomForest(formula, data=train.cv1)
train.cv1.glm <- glm(formula, data=train.cv1)
train.cv2$pred_rf <- predict(train.cv1.rf, train.cv2)
train.cv2$pred_glm <- predict(train.cv1.glm, train.cv2)

## CV2
train.cv2.rf <- randomForest(formula, data=train.cv2)
train.cv2.glm <- glm(formula, data=train.cv2)
train.cv1$pred_rf <- predict(train.cv1.rf, train.cv1)
train.cv1$pred_glm <- predict(train.cv1.glm, train.cv1)

### Test ###
train.s<-subset(train, num_views<4)


## Random Forest
train.rf.view <- randomForest(formula, data=train)
train.rf.vote <- randomForest(formula2, data=train)
train.rf.comm <- randomForest(formula3, data=train)
train.s.rf.view <- randomForest(formula, data=train.s)
train.s.rf.vote <- randomForest(formula2, data=train.s)
train.s.rf.comm <- randomForest(formula3, data=train.s)

## GLM
train.glm.view <- glm(formula, data=train)
train.glm.vote <- glm(formula2, data=train)
train.glm.comm <- glm(formula3, data=train)
train.s.glm.view <- glm(formula, data=train.s)
train.s.glm.vote <- glm(formula2, data=train.s)
train.s.glm.comm <- glm(formula3, data=train.s)


#train.rf$importance
#varImpPlot(train.rf)

test$num_views_rf <- predict(train.rf.view, test)
test$num_votes_rf <- predict(train.rf.vote, test)
test$num_comments_rf <- predict(train.rf.comm, test)
test$num_views_rf <- predict(train.s.rf.view, test)
test$num_votes_rf <- predict(train.s.rf.vote, test)
test$num_comments_rf <- predict(train.s.rf.comm, test)

test$num_views_glm <- predict(train.glm.view, test)
test$num_votes_glm <- predict(train.glm.vote, test)
test$num_comments_glm <- predict(train.glm.comm, test)

test$num_views_glm <- predict(train.s.glm.view, test)
test$num_votes_glm <- predict(train.s.glm.vote, test)
test$num_comments_glm <- predict(train.s.glm.comm, test)

######################
### Export results ###
######################
sample.rf<-raw_sample
sample.glm<-raw_sample
sample.lm<-raw_sample

sample.rf$num_views <- test$num_views_rf
sample.rf$num_votes <- test$num_votes_rf
sample.rf$num_comments <- test$num_comments_rf

sample.glm$num_views <- abs(test$num_views_glm)
sample.glm$num_votes <- abs(test$num_votes_glm)
sample.glm$num_comments <- abs(test$num_comments_glm)



write.csv(sample.rf,
          '/Users/Angie/Desktop/RPI/Courses/MGMT 6963/assignment/2/predict_rf4.csv',
          row.names = FALSE)
write.csv(sample.glm,
          '/Users/Angie/Desktop/RPI/Courses/MGMT 6963/assignment/2/predict_glm5.csv',
          row.names = FALSE)

