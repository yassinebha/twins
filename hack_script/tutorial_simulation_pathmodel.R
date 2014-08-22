#----------------------------------------------------------------------------------------------------------------------
#                                                             Twin_simulate
# DVM Bishop, 11th March 2010, Based on script in OpenMXUserGuide, p 15
#----------------------------------------------------------------------------------------------------------------------
require(OpenMx)   # not needed for the simulation, but will be needed when we come to model specification
require(MASS)    # needed for multivariate random number generation
set.seed(200)        # specified seed ensures same random number set generated on each run

mya2<-0.5 #Additive genetic variance component (a squared)
myc2<-0.3 #Common environment variance component (c squared)
mye2<-1-mya2-myc2 #Specific environment variance component (e squared)

my_rMZ <-mya2+myc2          # correlation between MZ twin1 and twin2
my_rDZ <- .5*mya2+myc2     # correlation between DZ twin 1 and twin 2

mzData <- mvrnorm (1000, c(0,0), matrix(c(1,my_rMZ,my_rMZ,1),2,2))
dzData <- mvrnorm (1000, c(0,0), matrix(c(1,my_rDZ,my_rDZ,1),2,2))
# create  permutation vector for fir_t1 and fir_t2
permute <- 100
set.seed(200)
permMZ <- replicate(permute,sample(TabTmp[[paste(clust_vol_tmp,"_twin1",sep='')]]))
permTab_t1 <- cbind(TabTmp[[paste(clust_vol_tmp,"_twin1",sep='')]],permTab_t1)
set.seed(100)
permDZ<-replicate(permute,sample(TabTmp[[paste(clust_vol_tmp,"_twin2",sep='')]]))
permTab_t2 <- cbind(TabTmp[[paste(clust_vol_tmp,"_twin2",sep='')]],permTab_t2)
permTab <- cbind(permTab_t1,permTab_t2)
for (pp in seq(permute+1)) { #permutation test for fir_twin1 and fir_twin2 column


colnames(mzData) <- c('twin1', 'twin2') # assign column names
colnames(dzData) <- c('twin1', 'twin2')
summary(mzData)
summary(dzData)
colMeans(mzData,na.rm=TRUE) #na.rm means ignore NA values (non-numeric)
colMeans(dzData,na.rm=TRUE) 
cov(mzData,use="complete") # "complete" specifies use only cases with data in all columns
cov(dzData,use="complete")

# do scatterplots for MZ and DZ
split.screen(c(1,2))        # split display into two screens side by side
# (use c(2,1) for screens one above the other)
screen(1)
plot(mzData,main='MZ')    # main specifies overall plot title

screen(2)
plot(dzData, main='DZ')
#use drag and drop to resize the plot window if necessary


alltwin=cbind(mzData,dzData)
colnames(alltwin)=c("MZ_twin1","MZ_twin2","DZ_twin1","DZ_twin2")
# write.table(alltwin,"mytwinfile")     # Saves a copy of mydata in your R directory under name "mytwinfile"
selVars <- c('twin1','twin2')

twinACEModel <- mxModel("twinACE",
                        mxModel("ACE",
                                # Matrices a, c, and e to store a, c, and e path coefficients
                                mxMatrix(
                                  type="Lower",
                                  nrow=1,
                                  ncol=1,
                                  free=TRUE,
                                  values=0.6,
                                  labels="a11",
                                  name="a"
                                ),
                                mxMatrix(
                                  type="Lower",
                                  nrow=1,
                                  ncol=1,
                                  free=TRUE,
                                  values=0.6,
                                  labels="c11",
                                  name="c"
                                ),
                                mxMatrix(
                                  type="Lower",
                                  nrow=1,
                                  ncol=1,
                                  free=TRUE,
                                  values=0.6,
                                  labels="e11",
                                  name="e"
                                ),
                                # Matrices A, C, and E compute variance components
                                mxAlgebra(
                                  expression=a %*% t(a),
                                  name="A"
                                ),
                                mxAlgebra(
                                  expression=c %*% t(c),
                                  name="C"
                                ),
                                mxAlgebra(
                                  expression=e %*% t(e),
                                  name="E"
                                ),
                                # Matrix & Algebra for expected means vector
                                mxMatrix(
                                  type="Full",
                                  nrow=1,
                                  ncol=1,
                                  free=TRUE,
                                  values=20,
                                  label="mean",
                                  name="Mean"
                                ),
                                mxAlgebra(
                                  expression= cbind(Mean,Mean),
                                  name="expMean"
                                ),
                                # Algebra for expected variance/covariance matrix in MZ
                                mxAlgebra(
                                  expression=rbind (cbind(A + C + E , A + C),
                                                    cbind(A + C     , A + C + E)),
                                  name="expCovMZ"
                                ),
                                # Algebra for expected variance/covariance matrix in DZ
                                mxAlgebra(
                                  expression=rbind (cbind(A + C + E     , 0.5 %x% A + C),
                                                    cbind(0.5 %x% A + C , A + C + E)),
                                  name="expCovDZ"
                                )
                        ),
                        mxModel("MZ",
                                mxData(
                                  observed=mzData,
                                  type="raw"
                                ),
                                mxFIMLObjective(
                                  covariance="ACE.expCovMZ",
                                  means="ACE.expMean",
                                  dimnames=selVars
                                )
                        ),
                        mxModel("DZ",
                                mxData(
                                  observed=dzData,
                                  type="raw"
                                ),
                                mxFIMLObjective(
                                  covariance="ACE.expCovDZ",
                                  means="ACE.expMean",
                                  dimnames=selVars
                                )
                        ),
                        mxAlgebra(
                          expression=MZ.objective + DZ.objective,
                          name="minus2loglikelihood"
                        ),
                        mxAlgebraObjective("minus2loglikelihood")
)
twinACEFit <- mxRun(twinACEModel)
MZc <- mxEval(ACE.expCovMZ, twinACEFit)
DZc <- mxEval(ACE.expCovDZ, twinACEFit)
M <- mxEval(ACE.expMean, twinACEFit)
A <- mxEval(ACE.A, twinACEFit)
C <- mxEval(ACE.C, twinACEFit)
E <- mxEval(ACE.E, twinACEFit)
V <- (A+C+E)
a2 <- A/V
c2 <- C/V
e2 <- E/V
ACEest <- rbind(cbind(A,C,E),cbind(a2,c2,e2))
LL_ACE <- mxEval(objective, twinACEFit)


# #Run AE model
# twinAEModel <- mxRename(twinACEModel, "twinAE")
# 
# # drop shared environmental path
# twinAEModel$ACE.c <-
#   mxMatrix(
#     type="Full",
#     nrow=1,
#     ncol=1,
#     free=F,
#     values=0,
#     label="c11"
#   )
# 
# twinAEFit <- mxRun(twinAEModel)
# 
# MZc1 <- mxEval(ACE.expCovMZ, twinAEFit)
# DZc1 <- mxEval(ACE.expCovDZ, twinAEFit)
# A1 <- mxEval(ACE.A, twinAEFit)
# C1 <- mxEval(ACE.C, twinAEFit)
# E1 <- mxEval(ACE.E, twinAEFit)
# V1 <- (A1+C1+E1)
# a21 <- A1/V1
# c21 <- C1/V1
# e21 <- E1/V1
# AEest1 <- rbind(cbind(A1,C1,E1),cbind(a21,c21,e21))
# LL_AE1 <- mxEval(objective, twinAEFit)
# 
# #Run CE model
# twinCEModel <- mxRename(twinACEModel, "twinCE")
# # drop additive genetic path
# twinCEModel$ACE.a <-
#   mxMatrix(
#     type="Full",
#     nrow=1,
#     ncol=1,
#     free=F,
#     values=0,
#     label="a11"
#   )
# 
# twinCEFit <- mxRun(twinCEModel)
# 
# MZc2 <- mxEval(ACE.expCovMZ, twinCEFit)
# DZc2 <- mxEval(ACE.expCovDZ, twinCEFit)
# A2 <- mxEval(ACE.A, twinCEFit)
# C2 <- mxEval(ACE.C, twinCEFit)
# E2 <- mxEval(ACE.E, twinCEFit)
# V2 <- (A2+C2+E2)
# a22 <- A2/V2
# c22 <- C2/V2
# e22 <- E2/V2
# AEest2 <- rbind(cbind(A2,C2,E2),cbind(a22,c22,e22))
# LL_AE2 <- mxEval(objective, twinCEFit)
# 
# 
