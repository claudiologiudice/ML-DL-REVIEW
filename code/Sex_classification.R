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


setwd(".")
load("../data/DB_clean_normalized.RData")
load("../data/metadata.RData")


ncol_clean = ncol(DB_exp_norm_clean)
Th = 0.8
t = 0
for(i in 1:(ncol_clean-t-1)){
  
  corfun = function(B){
    F = DB_exp_norm_clean[, i]
    ex = cor(F, B)
    return(ex)
  }
  
  ########################### 
  if((i+1) == (ncol_clean - t))
    break
  ###########################
  
  corr = as.vector(apply(DB_exp_norm_clean[, (i+1):(ncol_clean-t)], 2, corfun))
  ind = which(abs(corr) > Th)
  if(length(ind) != 0)
    DB_exp_norm_clean = DB_exp_norm_clean[, -(ind+1)]
  
  t = t + length(ind)
  cat("i:", i, "ncol:", (ncol_clean-t), "\r")
}
ncol(DB_exp_norm_clean)
#save(DB_exp_norm_clean, file = "DB_non_corr_15_07_21.RData")



############################################################################################################
############################################################################################################


# Sex Prediction


############################################################################################################
############################################################################################################


DB_metadato_ordinato$V5 = as.character(DB_metadato_ordinato$V5)
DB_metadato_ordinato$V5[which(DB_metadato_ordinato$V5 == "Male")] = 0
DB_metadato_ordinato$V5[which(DB_metadato_ordinato$V5 == "Female")] = 1
DB_metadato_ordinato$V5 = as.numeric(DB_metadato_ordinato$V5) 

DB_exp_norm_clean = cbind(DB_exp_norm_clean, DB_metadato_ordinato$V5)

colnames(DB_exp_norm_clean) = make.names(colnames(DB_exp_norm_clean), unique = TRUE)

DB_exp_Male = DB_exp_norm_clean[which(DB_exp_norm_clean$DB_metadato_ordinato.V5 == "0"), ]
DB_exp_Female = DB_exp_norm_clean[which(DB_exp_norm_clean$DB_metadato_ordinato.V5 == "1"), ]


############################################################################################################

# Feature Selection procedure

############################################################################################################

#Boruta

boruta_Sex = Boruta(DB_metadato_ordinato.V5 ~ ., data = DB_exp_norm_clean, doTrace = 2, maxRuns = 500)
print(boruta_Sex)
#plot(boruta_Sex, las = 2, cex.axis = 0.7)
#plotImpHistory(boruta_Sex)
fs_boruta_Sex = getNonRejectedFormula(boruta_Sex)


###############################################

#Stepwise Selection

Ctrl_Parameters = trainControl(method = "cv", number = 10)
Sex_lm_cv_5fold_Stepwise = train(fs_boruta_Sex, data = DB_exp_norm_clean, method = "lmStepAIC", trControl = Ctrl_Parameters, modelType = "Regression")
print(Sex_lm_cv_5fold_Stepwise)
fs_Sex_Stepwise = "DB_metadato_ordinato.V5 ~ "
fs_Sex_Stepwise = paste(fs_Sex_Stepwise, as.character(Sex_lm_cv_5fold_Stepwise$finalModel$call$formula[3]))
fs_Sex_Stepwise = as.formula(fs_Sex_Stepwise)
#save(fs_Sex_Stepwise, file = "fs_Sex_Stepwise.RData")
#load("fs_Sex_Stepwise.RData")


#########################################################


library(stringi)
Sex = as.character(fs_Sex_Stepwise)
Sex = Sex[3]
Sex = as.vector(strsplit(Sex, " "))
Sex = stri_extract_all_words(Sex, simplify = TRUE)
Sex = Sex[-1]

DB_Gene_exp = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = length(Sex))
for(i in 1:nrow(DB_exp_norm_clean)){
  for(j in 1:length(Sex)){
    DB_Gene_exp[i, j] = DB_exp_norm_clean[i, which(colnames(DB_exp_norm_clean) == Sex[j])]
  }
}
colnames(DB_Gene_exp) = Sex
DB_Gene_exp = as.data.frame(DB_Gene_exp)
DB_Gene_exp = cbind(DB_Gene_exp, DB_metadato_ordinato$V5)
colnames(DB_Gene_exp) = make.names(colnames(DB_Gene_exp), unique = TRUE)

DB_exp_Male = DB_Gene_exp[which(DB_Gene_exp$DB_metadato_ordinato.V5 == "0"), ]
DB_exp_Female = DB_Gene_exp[which(DB_Gene_exp$DB_metadato_ordinato.V5 == "1"), ]

Max_male = max(DB_exp_Male[, which(colnames(DB_exp_Male) == Sex[i])])
Max_female = max(DB_exp_Female[, which(colnames(DB_exp_Female) == Sex[i])])
MAX = max(Max_male, Max_female)
X11()
h_male = hist(DB_exp_Male[, which(colnames(DB_exp_Male) == Sex[i])], breaks = 100, xlim = c(0, MAX), main = Sex[i], xlab = "Gene expression" ,col = "red", cex.lab=1.5, cex.axis=1.5, cex.main=3, cex.sub=1.5)
legend("topright", c("Male", "Female"), col=c("red", "blue"), lwd=10)
h_female = hist(DB_exp_Female[, which(colnames(DB_exp_Female) == Sex[i])], breaks = 100, xlim = c(0, Max_female), main = Sex[i], col = "blue", add = T, cex.lab=1.5, cex.axis=1.5, cex.main=3, cex.sub=1.5)

h_female = hist(DB_exp_Female[, which(colnames(DB_exp_Female) == Sex[i])], breaks = 100, xlim = c(0, Max_female), main = Sex[i], col = "blue")

Sex_eq = Sex[1:21]

fs_Sex_Eq = "DB_metadato_ordinato.V5 ~ "
fs_Sex_Eq = paste(fs_Sex_Eq, Sex_eq[1], sep = "") 
for(i in 2:length(Sex_eq)){
  fs_Sex_Eq = paste(fs_Sex_Eq, Sex_eq[i], sep = " + ") 
}
fs_Sex_Eq = as.formula(fs_Sex_Eq)
#save(fs_Sex_Eq, file = "fs_Sex_Eq.RData")
#load("fs_Sex_Eq.RData")



############################################################################################################
#######################################################################################################

#Sex classification

#######################################################################################################
#######################################################################################################


#Linear Model
n_rip = 100
n_fold = 5
n_test = as.integer(nrow(DB_exp_norm_clean)/n_fold)

#PRED_lm_Sex = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = n_rip)
PRED_lm_Sex_Step = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = n_rip)

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
    
    DB_metadato_ordinato.V5 = DB_metadato_ordinato$V5[ind_training]
    DB_train = cbind(DB_train, DB_metadato_ordinato.V5)
    colnames(DB_train) = make.names(colnames(DB_train), unique = TRUE)
    lm_model_Sex_Step <- lm(fs_Sex_Eq, data = DB_train)
    
    DB_test = DB_exp_norm_clean[ind_test, ]
    colnames(DB_test) = make.names(colnames(DB_test), unique = TRUE)
    PRED_lm_Sex_Step[ind_test, i] = predict(lm_model_Sex_Step, DB_test)
    
    cat("n_rip: ", i, " n_fold: ", n, "\r")
  }
}



#Performances

acc_lm_Sex_Step = 0
tn_lm_Sex_Step = 0
fp_lm_Sex_Step = 0
fn_lm_Sex_Step = 0
tp_lm_Sex_Step = 0
for(i in 1:100){
  
  PRED_lm_Sex_Step_factor <- ifelse(PRED_lm_Sex_Step[, i] < 0.5, 0, 1)
  acc_lm_Sex_Step[i] = mean(as.factor(PRED_lm_Sex_Step_factor) == as.factor(DB_metadato_ordinato$V5))
  cf_Step = confusionMatrix(as.factor(PRED_lm_Sex_Step_factor), as.factor(DB_metadato_ordinato$V5))
  tn_lm_Sex_Step[i] = cf_Step$table[1]
  fp_lm_Sex_Step[i] = cf_Step$table[2]
  fn_lm_Sex_Step[i] = cf_Step$table[3]
  tp_lm_Sex_Step[i] = cf_Step$table[4]
}




###########################################

#Random Forest


n_fold = 5
n_test = as.integer(nrow(DB_exp_norm_clean)/n_fold)

PRED_rf_Sex_Step = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = n_rip)

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
    
    DB_metadato_ordinato.V5 = DB_metadato_ordinato$V5[ind_training]
    DB_train = cbind(DB_train, DB_metadato_ordinato.V5)
    colnames(DB_train) = make.names(colnames(DB_train), unique = TRUE)
    
    rf_model_Sex_Step <- randomForest(fs_Sex_Eq, data = DB_train, ntree = 300, importance = TRUE, proximity = TRUE)
    
    DB_test = DB_exp_norm_clean[ind_test, ]
    colnames(DB_test) = make.names(colnames(DB_test), unique = TRUE)
    PRED_rf_Sex_Step[ind_test, i] = predict(rf_model_Sex_Step, DB_test)
    
    
    cat("n_rip: ", i, " n_fold: ", n, "\r")
  }
}



#Performances
acc_rf_Sex_Step = 0
tn_rf_Sex_Step = 0
fp_rf_Sex_Step = 0
fn_rf_Sex_Step = 0
tp_rf_Sex_Step = 0
for(i in 1:100){
  
  PRED_rf_Sex_Step_factor <- ifelse(PRED_rf_Sex_Step[, i] < 0.5, 0, 1)
  acc_rf_Sex_Step[i] = mean(as.factor(PRED_rf_Sex_Step_factor) == as.factor(DB_metadato_ordinato$V5))
  cf_Step = confusionMatrix(as.factor(PRED_rf_Sex_Step_factor), as.factor(DB_metadato_ordinato$V5))
  tn_rf_Sex_Step[i] = cf_Step$table[1]
  fp_rf_Sex_Step[i] = cf_Step$table[2]
  fn_rf_Sex_Step[i] = cf_Step$table[3]
  tp_rf_Sex_Step[i] = cf_Step$table[4]
}




#########################################

#Neaureal network


n_fold = 5
n_test = as.integer(nrow(DB_exp_norm_clean)/n_fold)

PRED_nnet_Sex = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = n_rip)
PRED_nnet_Sex_Step = mat.or.vec(nr = nrow(DB_exp_norm_clean), nc = n_rip)

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
    
    DB_metadato_ordinato.V5 = DB_metadato_ordinato$V5[ind_training]
    DB_train = cbind(DB_train, DB_metadato_ordinato.V5)
    colnames(DB_train) = make.names(colnames(DB_train), unique = TRUE)
    
    
    nnet_model_Sex_Step <- neuralnet(fs_Sex_Eq, data = DB_train, hidden = c(50, 10, 1), err.fct = "sse", linear.output = TRUE)
    
    DB_test = DB_exp_norm_clean[ind_test, ]
    colnames(DB_test) = make.names(colnames(DB_test), unique = TRUE)
    PRED_nnet_Sex_Step[ind_test, i] = predict(nnet_model_Sex_Step, DB_test)
    
    cat("n_rip: ", i, " n_fold: ", n, "\r")
  }
}


#Performances
acc_nnet_Sex_Step = 0
tn_nnet_Sex_Step = 0
fp_nnet_Sex_Step = 0
fn_nnet_Sex_Step = 0
tp_nnet_Sex_Step = 0
for(i in 1:100){
  PRED_nnet_Sex_Step_factor <- ifelse(PRED_nnet_Sex_Step[, i] < 0.5, 0, 1)
  acc_nnet_Sex_Step[i] = mean(as.factor(PRED_nnet_Sex_Step_factor) == as.factor(DB_metadato_ordinato$V5))
  
  cf_Step = confusionMatrix(as.factor(PRED_nnet_Sex_Step_factor), as.factor(DB_metadato_ordinato$V5))
  tn_nnet_Sex_Step[i] = cf_Step$table[1]
  fp_nnet_Sex_Step[i] = cf_Step$table[2]
  fn_nnet_Sex_Step[i] = cf_Step$table[3]
  tp_nnet_Sex_Step[i] = cf_Step$table[4]
}


wrap.lp<-c('Linear Model', 'Random Forest', 'MLP')

X11()

boxplot(acc_lm_Sex_Step,acc_rf_Sex_Step,acc_nnet_Sex_Step,names=wrap.lp,col =c('red','blue','green'),cex.axis=1.3,cex.lab=1.5,ylim=c(0.91,1), ylab = "Accuracy")

Reference <- c('MALE', 'MALE', 'FAMELE', 'FAMELE')
LM <- c('MALE', 'FAMELE', 'MALE', 'FAMELE')
Y<-c(mean(tn_lm_Sex_Step),mean(fp_lm_Sex_Step),mean(fn_lm_Sex_Step),mean(tp_lm_Sex_Step))
df <- data.frame(Reference, LM, Y)

X11()
ggplot(data =  df, mapping = aes(x = Reference, y = LM)) +
  geom_tile(aes(fill = Y), colour = "white") +
  geom_text(aes(label = sprintf("%0.1f", Y)), vjust = 0.5, fontface  = "bold", alpha = 4,size = 10) +
  #geom_label(label.size = 0.25)+
  #scale_fill_gradient(low = "green", high = "pink") +
  scale_fill_gradientn(colours = c("pink", "lightblue", "lightgreen", "green"))+
  #theme_bw() + theme(legend.position = "none")
  theme(axis.text=element_text(size=15),axis.title.x = element_text(size = 20),axis.title.y = element_text(size = 20)) + theme(legend.position = "none")



Reference <- c('MALE', 'MALE', 'FAMELE', 'FAMELE')
RF <- c('MALE', 'FAMELE', 'MALE', 'FAMELE')
Y<-c(mean(tn_rf_Sex_Step),mean(fp_rf_Sex_Step),mean(fn_rf_Sex_Step),mean(tp_rf_Sex_Step))
df <- data.frame(Reference, RF, Y)

X11()

ggplot(data =  df, mapping = aes(x = Reference, y = RF)) +
  geom_tile(aes(fill = Y), colour = "white") +
  geom_text(aes(label = sprintf("%0.1f", Y)), vjust = 0.5, fontface  = "bold", alpha = 4,size = 10) +
  #geom_label(label.size = 0.25)+
  #scale_fill_gradient(low = "green", high = "pink") +
  scale_fill_gradientn(colours = c("pink", "lightblue", "lightgreen", "green"))+
  #theme_bw() + theme(legend.position = "none")
  theme(axis.text=element_text(size=15),axis.title.x = element_text(size = 20),axis.title.y = element_text(size = 20)) + theme(legend.position = "none")



Reference <- c('MALE', 'MALE', 'FAMELE', 'FAMELE')
MLP <- c('MALE', 'FAMELE', 'MALE', 'FAMELE')
Y<-c(mean(tn_nnet_Sex_Step),mean(fp_nnet_Sex_Step),mean(fn_nnet_Sex_Step),mean(tp_nnet_Sex_Step))
df <- data.frame(Reference, MLP, Y)

X11()
ggplot(data =  df, mapping = aes(x = Reference, y = MLP)) +
  geom_tile(aes(fill = Y), colour = "white") +
  geom_text(aes(label = sprintf("%0.1f", Y)), vjust = 0.5, fontface  = "bold", alpha = 4,size = 10) +
  scale_fill_gradientn(colours = c("pink", "lightblue", "lightgreen", "green"))+
  theme(axis.text=element_text(size=15),axis.title.x = element_text(size = 20),axis.title.y = element_text(size = 20)) + theme(legend.position = "none")