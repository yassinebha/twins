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

myDataMZ <- mvrnorm (1000, c(0,0), matrix(c(1,my_rMZ,my_rMZ,1),2,2))
myDataDZ <- mvrnorm (1000, c(0,0), matrix(c(1,my_rDZ,my_rDZ,1),2,2))

colnames(myDataMZ) <- c('twin1', 'twin2') # assign column names
colnames(myDataDZ) <- c('twin1', 'twin2')
summary(myDataMZ)
summary(myDataDZ)
colMeans(myDataMZ,na.rm=TRUE) #na.rm means ignore NA values (non-numeric)
colMeans(myDataDZ,na.rm=TRUE) 
cov(myDataMZ,use="complete") # "complete" specifies use only cases with data in all columns
cov(myDataDZ,use="complete")

# do scatterplots for MZ and DZ
split.screen(c(1,2))        # split display into two screens side by side
# (use c(2,1) for screens one above the other)
screen(1)
plot(myDataMZ,main='MZ')    # main specifies overall plot title

screen(2)
plot(myDataDZ, main='DZ')
#use drag and drop to resize the plot window if necessary


alltwin=cbind(myDataMZ,myDataDZ)
colnames(alltwin)=c("MZ_twin1","MZ_twin2","DZ_twin1","DZ_twin2")
write.table(alltwin,"mytwinfile")     # Saves a copy of mydata in your R directory under name "mytwinfile"
