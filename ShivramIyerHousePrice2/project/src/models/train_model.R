
# Libraries ---------------------------------------------------------------

library(data.table)
library(caret)
library(xgboost)
library(Metrics)
# Load 'train' and 'test' -------------------------------------------------

train <- fread("./project/volume/data/interim/train.csv")
test <- fread("./project/volume/data/interim/test.csv")
# Split y and x -----------------------------------------------------------

y.train <- train$SalePrice
test$SalePrice <- 0

dummies <- dummyVars(SalePrice~., data=train)
x.train <- predict(dummies, newdata=train)
x.test <- predict(dummies, newdata=test)
dtrain <- xgb.DMatrix(x.train, label=y.train, missing=NA)
dtest <- xgb.DMatrix(x.test, missing=NA)
tuning_log <- NULL
params <- list(booster          = 'gbtree',
               tree_method      = 'hist',
               objective        = 'reg:squarederror',
               # complexity
               max_depth        = 5,
               min_child_weight = 1,
               gamma            = 0.01,
               # diversity
               eta              = 0.01,
               subsample        = 0.7,
               colsample_bytree = 1
)
### cross-validation
XGBm <- xgb.cv(params                = params,
               data                  = dtrain,
               missing               = NA,
               nfold                 = 5,
               # diversity
               nrounds               = 10000,
               early_stopping_rounds = 25,
               # whether it shows error at each round
               verbose               = 1
)
### save tuning parameters
tuning_new <- data.table(t(params))
### save the best number of rounds
best_nrounds <- unclass(XGBm)$best_iteration
tuning_new$best_nrounds <- best_nrounds
### save the test set error
error_cv <- unclass(XGBm)$evaluation_log[best_nrounds,]$test_rmse_mean
tuning_new$error_cv <- error_cv
### keep the tuning log
tuning_log <- rbind(tuning_log,tuning_new)
tuning_log
tuning_best <- tuning_log[which.min(tuning_log$error_cv),]
params <- list(booster          = 'gbtree',
               tree_method      = 'hist',
               objective        = 'reg:squarederror',
               max_depth        = tuning_best$max_depth,
               min_child_weight = tuning_best$min_child_weight,
               gamma            = tuning_best$gamma,
               eta              = tuning_best$eta,
               subsample        = tuning_best$subsample,
               colsample_bytree = tuning_best$colsample_bytree
)
nrounds <- tuning_best$best_nrounds
watchlist <- list(train=dtrain)
XGBm <- xgb.train(params       =params,
                  data         =dtrain,
                  missing      =NA,
                  nrounds      =nrounds,
                  print_every_n=TRUE,
                  watchlist    =watchlist
)
pred <- predict(XGBm, newdata=dtest)
xgb.save(XGBm,"./project/volume/models/model.model")
submit <- data.table(test$Id,SalePrice=pred)
colnames(submit) <- c('Id', 'SalePrice')
fwrite(submit, "./project/volume/data/processed/submit.csv")
