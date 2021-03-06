##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### GGPlot Parameters ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

setwd(global_wd_r_outputs)

##########
# Help
##########
# ?ggplot
# ?ggtitle
# ?labs
# ?geom_bar
# ?geom_col
# ?geom_histogram
# ?annotate
# ?geom_text
# ?geom_vline



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
white = "white"


##########
# Functions
##########
saveToPDF<-function(plot,filename){
  pdf(filename)
  plot(plot)
  dev.off()
}


