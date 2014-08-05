

# -----------------------------------------------------------------------------
# UnivariateTwinAnalysis_PathRaw.R  
# Author: Yassine BHA
#
# ModelType: ACE
# DataType: Twin
# Field: Human Behavior Genetics 
#
# Purpose: 
#      Univariate Twin Analysis model to estimate causes of variation 
#      Path style model input - Raw data input
# -----------------------------------------------------------------------------

# Load Library
require(OpenMx)

#Prepare Data
#data(myTwinData)
myTwinData <- read.csv("~/Dropbox/twins_fir_heritability/niak_combine_scan_pedig_scale6.csv", header=TRUE, na.strings="NaN")
names(myTwinData)[1] <- "id_scan" # put the header for the scan's id
myTwinData$id_scan <- as.character(myTwinData$id_scan)
myTwinData <- myTwinData[complete.cases(myTwinData), ] # remove NA rows
allDup <- function (value) 
{ 
  duplicated(value) | duplicated(value, fromLast = TRUE) # function to detect non duplicated variable
}

myTwinData  <- myTwinData[allDup(myTwinData$nofamill),]  # remove non twins based on the familly id
myTwinData$id_subj <- NULL # remove extra colomn
myTwinData$handedness <- NULL # remove extra colomn
# check for duplicated subject IDs
if (any(duplicated(myTwinData$id_scan) == TRUE )) { warning( "the duplicated subjects ID are: \n" ,(myTwinData$id_scan[duplicated(myTwinData$id_scan)]),"\n") }
myTwinData <- myTwinData[!duplicated(myTwinData$id_scan),] # remove the dulicated subject
volume      = 83 # set times points or volume
cluster     = 6 # set the number of clusters 

for (cc in seq(cluster)) {
  for (vv in seq(volume)) {
    clust_vol_tmp <- paste("clust_",cc,"_v",vv,sep='')
    myTwinDataVars <- subset(myTwinData,zygotie == 0 | zygotie == 1 , c("id_scan","nofamill","sexe","zygotie",clust_vol_tmp)) #subset variable of interest
    myTwinDataVars <- myTwinDataVars[order(myTwinDataVars$nofamill),] # oredr table assending 
    TabTmp <- matrix(, nrow = dim(myTwinDataVars)[1]+1, ncol = dim(myTwinDataVars)[2]+3) # create empty matrix to hold Twin1 and Twin2 fir times point
    colnames(TabTmp) <- cbind(paste(names(myTwinDataVars['id_scan']),"_twin1",sep=''),
                              paste(names(myTwinDataVars['id_scan']),"_twin2",sep=''),
                              names(myTwinDataVars['nofamill']),
                              paste(names(myTwinDataVars[clust_vol_tmp]),"_twin1",sep=''),
                              paste(names(myTwinDataVars[clust_vol_tmp]),"_twin2",sep=''),
                              paste(names(myTwinDataVars['sexe']),"_twin1",sep=''),
                              paste(names(myTwinDataVars['sexe']),"_twin2",sep=''),
                              names(myTwinDataVars['zygotie']))
    TabTmp <- data.frame(TabTmp) # empty data frame
    for (i in seq(dim(myTwinDataVars)[1]-1)) {
      if (myTwinDataVars[[c(2,i)]] == myTwinDataVars[[c(2,i+1)]] ) {
        TabTmp[i+1,] <- cbind(myTwinDataVars$id_scan[i],
                              myTwinDataVars$id_scan[i+1],
                              myTwinDataVars$nofamill[i],
                              myTwinDataVars[[clust_vol_tmp]][i],
                              myTwinDataVars[[clust_vol_tmp]][i+1],
                              myTwinDataVars$sexe[i],
                              myTwinDataVars$sexe[i+1],
                              myTwinDataVars$zygotie[i])  # fill table
      }
    }
    
    TabTmp <- TabTmp[complete.cases(TabTmp),] # remove empty rows
    # set varables classes
    TabTmp[[paste(clust_vol_tmp,"_twin1",sep='')]] <- as.numeric(TabTmp[[paste(clust_vol_tmp,"_twin1",sep='')]])
    TabTmp[[paste(clust_vol_tmp,"_twin2",sep='')]] <- as.numeric(TabTmp[[paste(clust_vol_tmp,"_twin2",sep='')]])
    TabTmp[['nofamill']] <- as.numeric(TabTmp[['nofamill']])
    TabTmp[['sexe_twin1']] <- as.numeric(TabTmp[['sexe_twin1']])
    TabTmp[['sexe_twin2']] <- as.numeric(TabTmp[['sexe_twin2']])
    TabTmp[['zygotie']] <- as.numeric(TabTmp[['zygotie']])
    # compute mean and cov dz mz
    selVars <- c(names(TabTmp[4]),names(TabTmp[5]))
    aceVars <- c("A1","C1","E1","A2","C2","E2")
    mzData <- as.matrix(subset(TabTmp, zygotie == 1,selVars))
    dzData <- as.matrix(subset(TabTmp, zygotie == 0, selVars))
    colMeans(mzData,na.rm=TRUE)
    colMeans(dzData,na.rm=TRUE)
    cov(mzData,use="complete")
    cov(dzData,use="complete")
    
    #Fit ACE Model with RawData and Path-Style Input
    ACEModel <- mxModel("ACE",
                        type="RAM",
                        manifestVars=selVars,
                        latentVars=aceVars,
                        # variances of latent variables
                        mxPath(
                          from=aceVars,
                          arrows=2,
                          free=FALSE,
                          values=1
                        ),
                        # means of latent variables
                        mxPath(
                          from="one",
                          to=aceVars,
                          arrows=1,
                          free=FALSE,
                          values=0
                        ),
                        # means of observed variables
                        mxPath(
                          from="one",
                          to=selVars,
                          arrows=1,
                          free=TRUE,
                          values=20,
                          labels="mean",
                        ),
                        # path coefficients for twin 1
                        mxPath(
                          from=c("A1","C1","E1"),
                          to=names(TabTmp[4]),
                          arrows=1,
                          free=TRUE,
                          values=.6,
                          label=c("a","c","e")
                        ),
                        # path coefficients for twin 2
                        mxPath(
                          from=c("A2","C2","E2"),
                          to=names(TabTmp[5]),
                          arrows=1,
                          free=TRUE,
                          values=.6,
                          label=c("a","c","e")
                        ),
                        # covariance between C1 & C2
                        mxPath(
                          from="C1",
                          to="C2",
                          arrows=2,
                          free=FALSE,
                          values=1
                        )
    )
    mzModel <- mxModel(ACEModel, name="MZ",
                       # covariance between A1 & A2
                       mxPath(
                         from="A1",
                         to="A2",
                         arrows=2,
                         free=FALSE,
                         values=1
                       ),
                       mxData(
                         observed=mzData,
                         type="raw"
                       )
    )
    dzModel <- mxModel(ACEModel, name="DZ",
                       # covariance between A1 & A2
                       mxPath(
                         from="A1",
                         to="A2",
                         arrows=2,
                         free=FALSE,
                         values=.5
                       ),
                       mxData(
                         observed=dzData,
                         type="raw"
                       )
    )
    twinACEModel <- mxModel("twinACE", mzModel, dzModel,
                            mxAlgebra(
                              expression=MZ.objective + DZ.objective,
                              name="minus2loglikelihood"
                            ),
                            mxAlgebraObjective("minus2loglikelihood")
    )
    #Run ACE model
    twinACEFit <- mxRun(twinACEModel)
    
    
    MZc <- twinACEFit$MZ.objective@info$expCov    # expected covariance matrix for MZ's
    DZc <- twinACEFit$DZ.objective@info$expCov    # expected covariance matrix for DZ's
    M <- twinACEFit$MZ.objective@info$expMean    # expected mean
    A <- mxEval(a*a, twinACEFit)    # additive genetic variance, a^2
    C <- mxEval(c*c, twinACEFit)    # shared environmental variance, c^2
    E <- mxEval(e*e, twinACEFit)    # unique environmental variance, e^2
    V <- (A+C+E)    # total variance
    a2 <- A/V        # standardized A
    c2 <- C/V        # standardized C
    e2 <- E/V        # standardized E
    ACEest <- rbind(cbind(A,C,E),cbind(a2,c2,e2))    # table of estimates
    LL_ACE <- mxEval(objective, twinACEFit)        # likelihood of ACE model
    # store the result in a tale 
    if (cc == 1 & vv==1) {
      TabResultPath <- matrix(, nrow = (volume*cluster), ncol = 5) # empty matrix to hold results for each fir times point
      colnames(TabResultPath) <- cbind("clust_vol","a2","c2","e2","fir_mean")
      TabResultPath <- data.frame(TabResultPath)
    }
    fir_mean <- mean(myTwinDataVars[[clust_vol_tmp]])
    TabResultPath[83*(cc-1)+vv,] <- cbind(clust_vol_tmp,a2,c2,e2,fir_mean)
  }  
} 

TabResultPath$a2 <- as.numeric(TabResultPath$a2)
TabResultPath$c2 <- as.numeric(TabResultPath$c2)
TabResultPath$e2 <- as.numeric(TabResultPath$e2)
TabResultPath$fir_mean <- as.numeric(TabResultPath$fir_mean)
write.csv(TabResultPath,"Table_result_path.csv")



# # # # # # # # # # plotly tools# # # # # # # # # # # # # 

## First, install and load the devtools package. From within the R console, enter:
# install.packages("devtools")
library("devtools")

## Next, install plotly. From within the R console, enter:
# install_github("ropensci/plotly")

## import the Plotly R library
library(plotly)

## Authentication : to be exuted only the first time using a Plotly API!
#  set_credentials_file(username="YassineBHA", api_key="8d314mov50")


###
p <- plotly(username="YassineBHA", key="8d314mov50")

a2 <- list(
  x = TabResult$clust_vol, 
  y = TabResult$a2, 
  fill = "tozeroy", 
  type = "scatter"
)
c2 <- list(
  x = TabResult$clust_vol, 
  y = TabResult$c2, 
  fill = "tonexty", 
  type = "scatter"
)
e2 <- list(
  x = TabResult$clust_vol, 
  y = TabResult$e2, 
  fill = "tonexty", 
  type = "scatter"
)
data <- list(a2, c2, e2 )

response <- p$plotly(data, kwargs=list(filename="basic-area", fileopt="overwrite"))
url <- response$url
filename <- response$filename
########## stacked histogram ########

p <- plotly(username="YassineBHA", key="8d314mov50")

a2 <- list(
  x = TabResult$a2, 
  type = "histogram"
)
c2 <- list(
  x = TabResult$c2, 
  type = "histogram"
)
e2 <- list(
  x = TabResult$e2, 
  type = "histogram"
)
data <- list(a2,c2,e2)
layout <- list(barmode = "stacked")

response <- p$plotly(data, kwargs=list(layout=layout, filename="stacked-histogram", fileopt="overwrite"))
url <- response$url
filename <- response$filename



# #Run AE model
# AEModel <- mxModel(ACEModel, name="twinAE",
#                    mxPath(
#                      from=c("A1","C1","E1"),
#                      to=names(TabTmp[4]),
#                      arrows=1,
#                      free=c(T,F,T),
#                      values=c(.6,0,.6),
#                      label=c("a","c","e")
#                    ),
#                    mxPath(
#                      from=c("A2","C2","E2"),
#                      to=names(TabTmp[5]),
#                      arrows=1,
#                      free=c(T,F,T),
#                      values=c(.6,0,.6),
#                      label=c("a","c","e")
#                    )
# )
# mzModel <- mxModel(AEModel, name="MZ",
#                    mxPath(
#                      from="A1",
#                      to="A2",
#                      arrows=2,
#                      free=FALSE,
#                      values=1
#                    ),
#                    mxData(
#                      observed=mzData,
#                      type="raw"
#                    )
# )
# dzModel <- mxModel(AEModel, name="DZ",
#                    mxPath(
#                      from="A1",
#                      to="A2",
#                      arrows=2,
#                      free=FALSE,
#                      values=.5
#                    ),
#                    mxData(
#                      observed=dzData,
#                      type="raw"
#                    )
# )
# twinAEModel <- mxModel("twinAE", mzModel, dzModel,
#                        mxAlgebra(
#                          expression=MZ.objective + DZ.objective,
#                          name="twin"
#                        ),
#                        mxAlgebraObjective("twin")
# )
# 
# twinAEFit <- mxRun(twinAEModel)
# 
# 
# MZc <- twinAEFit$MZ.objective@info$expCov
# DZc <- twinAEFit$DZ.objective@info$expCov
# M <- twinAEFit$MZ.objective@info$expMean
# A <- mxEval(a*a, twinAEFit)
# C <- mxEval(c*c, twinAEFit)
# E <- mxEval(e*e, twinAEFit)
# V <- (A+C+E)
# a2 <- A/V
# c2 <- C/V
# e2 <- E/V
# AEest <- rbind(cbind(A, C, E),cbind(a2, c2, e2))
# LL_AE <- mxEval(objective, twinAEFit)
# LRT_ACE_AE <- LL_AE - LL_ACE
# 
# #Print relevant output
# ACEest
# AEest
# LRT_ACE_AE