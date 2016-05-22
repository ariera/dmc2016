# install.packages("RPostgreSQL")
# install.packages('e1071', dependencies = TRUE)
# install.packages('iterpc', dependencies = TRUE)
# install.packages('logging', dependencies = TRUE)
require("RPostgreSQL")
library(class) 
library(e1071) 
library(iterpc)
#library(logging)
#basicConfig()
#addHandler(writeToFile, logger="naive", file="naive.log")
#loginfo("Start", logger="naive")
#logReset()
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "dmc2016", host = "localhost", port = 5432, user = "ariera")
dbExistsTable(con, "test")
accuracy <- function(matrix){
  acc <- sum(diag(matrix))/sum(matrix)
  return(acc)
}
catn <- function(x, append="\n"){cat(x); cat(append)}
?sink
#train <- dbReadTable(con, "dm2_v7_train_known_customers")
#test <- dbReadTable(con, "dm2_v7_test_known_customers")

train_and_test <- rbind(train, test)

categorical_attrs <- c(
  "orderdate",
  "articleid",
  "colorcode",
  "sizecode",
  "productgroup",
  "customerid",
  "deviceid",
  "paymentmethod",
  "day_of_week",
  "end_of_month",
  "is_productgroup_with_low_return_rate",
  "is_productgroup_with_high_return_rate",
  "customer_cluster"
)
for (attr in categorical_attrs) {
  print(attr)
  train_and_test[,attr] <- as.factor(train_and_test[,attr])
}


train_factor <- train_and_test[0:(nrow(train)),]
test_factor <- train_and_test[nrow(train):(nrow(train_and_test)-1),]

classification_attrs <- c(
  "orderdate",
  "articleid",
  "colorcode",
  "sizecode",
  "productgroup",
  "quantity",
  "price",
  "rrp",
  "voucheramount",
  "customerid",
  "deviceid",
  "paymentmethod",
  "price_per_item",
  "price_to_rrp_ratio",
  "usual_price_ratio",
  "has_voucher",
  "day_of_week",
  "end_of_month",
  "is_productgroup_with_low_return_rate",
  "is_productgroup_with_high_return_rate",
  "total_order_price",
  "n_articles_in_order",
  "voucher_to_order_price_ratio",
  "different_sizes",
  "different_colors",
  "n_times_article_appears_in_order",
  "customer_cluster"
  
)
label <- "has_return"
# head(train)
# train[1:3,classification_attrs]
# train[1,]


#classifier<-naiveBayes(train[,classification_attrs], train$has_return) 
classifier <- naiveBayes(as.factor(has_return)~price, data=as.data.frame(train_factor[,classification_attrs]))

predictions <- predict(classifier, test_factor[, classification_attrs])
confusion_matrix <- table(predictions, test_factor[, "has_return"])
accuracy(confusion_matrix)

I=iterpc(table(classification_attrs),1)
getlength(I)
getall(I)
sink("iterations.txt")
while (!is.null(getnext(I))){
  current_attrs <- getcurrent(I)
  current_attrs_with_label <- append(as.ordered(current_attrs), label)
  current_attrs
  class(current_attrs)
  
  classifier <- naiveBayes(as.factor(has_return)~price, data=as.data.frame(train_factor[,current_attrs]))
  
  catn("using attributes")
  print(as.data.frame(getcurrent(I)))
  #catn(getcurrent(I))
}
sink()
# unlink("iterations.txt")
