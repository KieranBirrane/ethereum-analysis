##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### GGPlot Parameters ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

setwd(global_wd_r_outputs)

##########
# Help
##########
?ggplot
?ggtitle
?labs



##########
# Colours
##########
black = "black"
red = "orangered"
orange = "orange"
yellow = "gold"
green = "limegreen"
blue = "dodgerblue1"
indigo = "purple4"
violet = "violetred"


##########
# Functions
##########
saveToPDF<-function(plot,filename){
  pdf(filename)
  plot(plot)
  dev.off()
}


