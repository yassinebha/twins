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

