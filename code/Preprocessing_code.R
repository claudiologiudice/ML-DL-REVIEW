### Written by A. Lacalamita

setwd(".")
load("../data/Expression_numeric.RData")


#Normalizzation
df_exp_norm = t(Espressioni)
ncolnorm = ncol(df_exp_norm)
nrownorm = nrow(df_exp_norm)
minrow = 0
maxrow = 0
for(i in 1:nrownorm){
  minrow[i] = min(df_exp_norm[i, ])
  maxrow[i] = max(df_exp_norm[i, ])
}


for(i in 1:nrownorm){
  for(j in 1:ncolnorm){
    df_exp_norm[i, j] = (df_exp_norm[i, j] - minrow[i])/(maxrow[i] - minrow[i])
    cat("i:", i, "\r")
  }
}

df_exp_norm = t(df_exp_norm)
df_exp_norm = as.data.frame(df_exp_norm)
df_exp_norm[is.na(df_exp_norm)] = 0



############################################################################################################

# First Feature Selection: We remove features with standard deviation equal to zero

############################################################################################################

devstand = apply(df_exp_norm, 2, sd, na.rm = TRUE)
X11()
h = hist(devstand, breaks = 100, xlim = c(0, max(devstand)), main = "Standard Deviation")

devper = 0
for(i in 1:length(devstand))
  devper[i] = devstand[i]/max(devstand)

h_per = hist(devper, breaks = 100, xlim = c(0, 1), main = "Standard Deviation", xlab = "Normalized Standard Deviation")

DB_exp_norm_clean = df_exp_norm

pos_devst = 0
k = 1
for(i in 1:length(devstand)){
  if((devstand[i]/max(devstand)) == 0){
    pos_devst[k] = i
    k = k+1  
  }
}

DB_exp_norm_clean = DB_exp_norm_clean[, -pos_devst]
save(DB_exp_norm_clean, file = "DB_clean_normalized.RData")
