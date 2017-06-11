##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### # user Analysis # ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

#####
# Run the clustering algorithm on the user data
#####


install.packages("tclust")

library ("tclust")
data ("geyser2")
clus <- tkmeans (geyser2, k =3, alpha = 0.03)
xx<-plot (clus)

271*0.03
9/271

clus$par # The analysis parameters
clus$centers # The centres of each cluster
clus$weights
mean(clus$obj)

m1<-kmeans(geyser2,9)




#################################
data(iris)
irisf<-iris
irisf$Species<-NULL
m1<-kmeans(irisf,9)
m1$withinss
m1$tot.withinss
m1$betweenss/m1$totss

plot(irisf)
plot(m1)

Within cluster sum of squares by cluster:
  [1] 15.15100 39.82097 23.87947
(between_SS / total_SS = 88.4 %)
