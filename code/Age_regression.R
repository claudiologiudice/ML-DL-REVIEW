### Written by A. Lacalamita

library(caret)
library(randomForest)
library(neuralnet)
library(boot)
library(Boruta)
library(mlbench)
library(fscaret)
library(tidyverse)
library(nnet)
library(devtools)
library(ROSE)
library(Metrics)

# Age Regression
setwd(".")
load("../data/DB_clean_normalized.RData")
load("../data/metadata.RData")
############################################################################################################
############################################################################################################

DB_exp_norm_clean = DB_exp_norm_clean[, -ncol(DB_exp_norm_clean)]
DB_exp_norm_clean = cbind(DB_exp_norm_clean, DB_metadato_ordinato$V6)
colnames(DB_exp_norm_clean) = make.names(colnames(DB_exp_norm_clean), unique = TRUE)

############################################################################################################

# First Feature Selection

############################################################################################################

#Boruta for 28 subsamples
feat = 0
n_rip = 1
n_sep = 28 #2000 features per each dataset
n_test = as.integer(ncol(DB_exp_norm_clean)/n_sep)

for(i in 1:n_rip){
  
  vettore = sample(1:ncol(DB_exp_norm_clean), replace = FALSE)
  
  for(n in 1:n_sep){
    
    if(n < n_sep){
      ind_test = vettore[seq(n_test*(n-1)+1, n_test*n)]
    }else{
      ind_test = vettore[seq(n_test*(n-1)+1, length(vettore))]
    }
    
    DB_test = DB_exp_norm_clean[, ind_test]
    DB_metadato_ordinato.V6 = DB_metadato_ordinato$V6
    DB_test = cbind(DB_test, DB_metadato_ordinato.V6)
    colnames(DB_test) = make.names(colnames(DB_test), unique = TRUE)
    
    bor1 = Boruta(DB_metadato_ordinato.V6 ~ ., data = DB_test, doTrace = 2, maxRuns = 500)
    if(n == 1)
      feat = getSelectedAttributes(bor1)
    else feat = c(feat, getSelectedAttributes(bor1))
    
    cat("n_rip: ", i, " n_fold: ", n, "\r")
  }
}

#save(vettore, file = "vettore.RData")
#save(feat, file = "feat.RData")
#load("vettore.RData")
#load("feat.RData")


fss = NULL
for(i in 1:length(feat)){
  if(i > 1)
    fss = paste(fss,feat[i], sep = " + ")
  else fss = feat[i]
}

fs_boruta_Age = "DB_metadato_ordinato.V6 ~ "
fs_boruta_Age = paste(fs_boruta_Age, fss)
fs_boruta_Age = as.formula(fs_boruta_Age)
#save(fs_boruta_Age, file = "fs_boruta_Age_Full_2.RData")
#load("fs_boruta_Age_Full_2.RData")




############################################################################################################

# Second Feature Selection

############################################################################################################

#Boruta
boruta_Age = Boruta(fs_boruta_Age, data = DB_exp_norm_clean, doTrace = 2, maxRuns = 500)
print(boruta_Age)
plot(boruta_Age, las = 2, cex.axis = 0.7)
plotImpHistory(boruta_Age)
fs_boruta_Age = getConfirmedFormula(boruta_Age)
#save(fs_boruta_Age, file = "fs_boruta_Age_DEF.RData")
#load("fs_boruta_Age_DEF.RData")

####################################

#Stepwise Selection
Ctrl_Parameters = trainControl(method = "cv", number = 10)
Age_lm_cv_5fold_Stepwise = train(fs_boruta_Age, data = DB_exp_norm_clean, method = "lmStepAIC", trControl = Ctrl_Parameters, modelType = "Regression")
print(Age_lm_cv_5fold_Stepwise)
#save(Age_lm_cv_5fold_Stepwise, file = "Age_lm_cv_5fold_Stepwise.RData")
#load("Age_lm_cv_5fold_Stepwise.RData")
p_lm_Age_Boruta_Stepwise = predict(Age_lm_cv_5fold_Stepwise, DB_exp_norm_clean)
cor(p_lm_Age_Boruta_Stepwise, DB_exp_norm_clean$DB_metadato_ordinato.V6)


fs_Age_Stepwise = "DB_metadato_ordinato.V6 ~ "
fs_Age_Stepwise = paste(fs_Age_Stepwise, as.character(Age_lm_cv_5fold_Stepwise$finalModel$call$formula[3]))
fs_Age_Stepwise = as.formula(fs_Age_Stepwise)
#save(fs_Age_Stepwise, file = "fs_Age_Stepwise_DEF.RData")

#######################################################################################################
#######################################################################################################

#Machine learning models

#######################################################################################################
#######################################################################################################

#Linear Model
#Boruta e Stepwise Feature

n_rip = 100
n_fold = 5
n_test = as.integer(nrow(DB_exp_norm_clean)/n_fold)

PRED_lm_Age_Step = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = n_rip)

for(i in 1:n_rip){
  
  vettore = sample(1:nrow(DB_exp_norm_clean), replace = FALSE)
  
  for(n in 1:n_fold){
    
    if(n < n_fold){
      ind_test = vettore[seq(n_test*(n-1)+1, n_test*n)]
      ind_training = vettore[-seq(n_test*(n-1)+1, n_test*n)]
    }else{
      ind_test = vettore[seq(n_test*(n-1)+1, length(vettore))]
      ind_training = vettore[-seq(n_test*(n-1)+1, length(vettore))]
    }
    
    DB_train = DB_exp_norm_clean[ind_training, ]
    
    DB_metadato_ordinato.V6 = DB_metadato_ordinato$V6[ind_training]
    DB_train = cbind(DB_train, DB_metadato_ordinato.V6)
    colnames(DB_train) = make.names(colnames(DB_train), unique = TRUE)
    
    lm_model_Age_Step <- lm(fs_Age_Stepwise, data = DB_train)
    
    DB_test = DB_exp_norm_clean[ind_test, ]
    colnames(DB_test) = make.names(colnames(DB_test), unique = TRUE)
    PRED_lm_Age_Step[ind_test, i] = predict(lm_model_Age_Step , DB_test)
    
    cat("n_rip: ", i, " n_fold: ", n, "\r")
  }
}

#Performances

corr_lm_Age_Step = 0
rmse_lm_Age_Step = 0
mae_lm_Age_Step = 0
for(i in 1:n_rip){
  corr_lm_Age_Step[i] = cor.test(PRED_lm_Age_Step[, i], as.numeric(DB_metadato_ordinato$V6))$estimate
  rmse_lm_Age_Step[i] = rmse(PRED_lm_Age_Step[, i], DB_metadato_ordinato$V6)
  mae_lm_Age_Step[i] = mae(PRED_lm_Age_Step[, i], DB_metadato_ordinato$V6)
}


#########################################

#Random Forest
#Boruta e Stepwise Feature

n_fold = 5
n_test = as.integer(nrow(DB_exp_norm_clean)/n_fold)

PRED_rf_Age = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = n_rip)
PRED_rf_Age_Step = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = n_rip)

for(i in 1:n_rip){
  
  vettore = sample(1:nrow(DB_exp_norm_clean), replace = FALSE)
  
  for(n in 1:n_fold){
    
    if(n < n_fold){
      ind_test = vettore[seq(n_test*(n-1)+1, n_test*n)]
      ind_training = vettore[-seq(n_test*(n-1)+1, n_test*n)]
    }else{
      ind_test = vettore[seq(n_test*(n-1)+1, length(vettore))]
      ind_training = vettore[-seq(n_test*(n-1)+1, length(vettore))]
    }
    
    DB_train = DB_exp_norm_clean[ind_training, ]
    
    DB_metadato_ordinato.V6 = DB_metadato_ordinato$V6[ind_training]
    DB_train = cbind(DB_train, DB_metadato_ordinato.V6)
    colnames(DB_train) = make.names(colnames(DB_train), unique = TRUE)
    
    rf_model_Age <- randomForest(fs_boruta_Age, data = DB_train, ntree = 300, importance = TRUE, proximity = TRUE)
    rf_model_Age_Step <- randomForest(fs_Age_Stepwise, data = DB_train, ntree = 300, importance = TRUE, proximity = TRUE)
    
    DB_test = DB_exp_norm_clean[ind_test, ]
    colnames(DB_test) = make.names(colnames(DB_test), unique = TRUE)
    PRED_rf_Age[ind_test, i] = predict(rf_model_Age, DB_test)
    PRED_rf_Age_Step[ind_test, i] = predict(rf_model_Age_Step, DB_test)
    
    cat("n_rip: ", i, " n_fold: ", n, "\r")
  }
}


#Performances
corr_rf_Age_Step = 0
rmse_rf_Age_Step = 0
mae_rf_Age_Step = 0
for(i in 1:n_rip){
  
  corr_rf_Age_Step[i] = cor.test(PRED_rf_Age_Step[, i], as.numeric(DB_metadato_ordinato$V6))$estimate
  rmse_rf_Age_Step[i] = rmse(PRED_rf_Age_Step[, i], DB_metadato_ordinato$V6)
  mae_rf_Age_Step[i] = mae(PRED_rf_Age_Step[, i], DB_metadato_ordinato$V6)
}


#########################################

max_Age = max(DB_metadato_ordinato$V6)
min_Age = min(DB_metadato_ordinato$V6)
for(i in 1:nrow(DB_metadato_ordinato)){
  DB_metadato_ordinato$V6[i] = (DB_metadato_ordinato$V6[i] - min_Age)/(max_Age - min_Age)
}

#Neaureal network
#Boruta e Stepwise Feature

n_fold = 5
n_test = as.integer(nrow(DB_exp_norm_clean)/n_fold)

PRED_nnet_Age_Step = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = n_rip)

for(i in 1:n_rip){
  
  vettore = sample(1:nrow(DB_exp_norm_clean), replace = FALSE)
  
  for(n in 1:n_fold){
    
    if(n < n_fold){
      ind_test = vettore[seq(n_test*(n-1)+1, n_test*n)]
      ind_training = vettore[-seq(n_test*(n-1)+1, n_test*n)]
    }else{
      ind_test = vettore[seq(n_test*(n-1)+1, length(vettore))]
      ind_training = vettore[-seq(n_test*(n-1)+1, length(vettore))]
    }
    
    DB_train = DB_exp_norm_clean[ind_training, ]
    
    DB_metadato_ordinato.V6 = DB_metadato_ordinato$V6[ind_training]
    DB_train = cbind(DB_train, DB_metadato_ordinato.V6)
    colnames(DB_train) = make.names(colnames(DB_train), unique = TRUE)
    
    nnet_model_Age <- neuralnet(fs_boruta_Age, data = DB_train, hidden = c(100, 50, 25, 10), err.fct = "sse", linear.output = TRUE)
    nnet_model_Age_Step <- neuralnet(fs_Age_Stepwise, data = DB_train, hidden = c(80, 40, 20), err.fct = "sse", linear.output = TRUE)
    
    DB_test = DB_exp_norm_clean[ind_test, ]
    colnames(DB_test) = make.names(colnames(DB_test), unique = TRUE)
    PRED_nnet_Age[ind_test, i] = predict(nnet_model_Age, DB_test)
    PRED_nnet_Age_Step[ind_test, i] = predict(nnet_model_Age_Step, DB_test)
    
    cat("n_rip: ", i, " n_fold: ", n, "\r")
  }
}


#Performances
corr_nnet_Age_Step = 0
rmse_nnet_Age_Step = 0
mae_nnet_Age_Step = 0
for(i in 1:n_rip){
  corr_nnet_Age_Step[i] = cor.test(PRED_nnet_Age_Step[, i], as.numeric(DB_metadato_ordinato$V6))$estimate
  rmse_nnet_Age_Step[i] = rmse(PRED_nnet_Age_Step[, i], DB_metadato_ordinato$V6)*(max_Age - min_Age)
  mae_nnet_Age_Step[i] = mae(PRED_nnet_Age_Step[, i], DB_metadato_ordinato$V6)*(max_Age - min_Age)
}

wrap.lp<-c('Linear Model', 'Random Forest', 'MLP')

boxplot(corr_lm_Age_Step,corr_rf_Age_Step,corr_nnet_Age_Step,names=wrap.lp,col =c('red','blue','green'),cex.axis=1.3,cex.lab=1.3,ylim=c(0.65,0.85), ylab = "Correlation coefficient")



DF3 <- data.frame(
  x = c(c(rmse_lm_Age_Step,rmse_rf_Age_Step,rmse_nnet_Age_Step), c(mae_lm_Age_Step, mae_rf_Age_Step,mae_nnet_Age_Step)),
  y = rep(c("RMSE","MAE"), each = 300),
  z = rep(rep(c("LM","RF","MLP"), each=100), 2),
  stringsAsFactors = FALSE
)
str(DF3)



X11()

ggplot(DF3, aes(y, x, fill=factor(z))) +
  geom_boxplot(outlier.shape = NA)+
  labs(fill = "Model")+
  theme_bw(base_size = 16)+
  xlab("")+ 
  ylab('years')+
  coord_cartesian(ylim = c(6.5, 11))