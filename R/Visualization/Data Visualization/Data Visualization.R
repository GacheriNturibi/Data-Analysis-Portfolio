#Installing the package for reading the xlsx file
##install.packages("readxl")
##install.packages("xlsx")

#importing all the necessary libraries
library(ggplot2)
library(tidyverse)

#Setting the directory to the folder
setwd("E:/Research_Program/Reserach_Project_considering_land_parcels_V3/Excel_data")

#Reading the data
EV <- read.csv("Post_processed_stats_ready_to_plot_in_R/PCA_Eigen_value.csv")
head(EV)
###Barplot
ggplot(df, aes(x=Month, y=Sales)) + 
  geom_bar(stat = "identity", color="blue",fill=rgb(0.1,0.4,0.5,0.7) )

ggplot(EV, aes(x=PCs, y=Percent_Accumulative_Eigen_value)) + 
  geom_bar(stat="identity",color="blue")

plot2 <- ggplot(EV, aes(x=PCs, y=Percent_Accumulative_Eigen_value,group=1)) + coord_cartesian(ylim=c(0, 120))+
 geom_line()+  xlim(rev(levels(EV$PCs)))

print(plot2)

ggplot(data=EV, aes(x=PCs, y=Percent_Accumulative_Eigen_value)) +
  geom_bar(stat="identity", width=1)

ggplot(data=EV, aes(x=PCs, y=Percent_Accumulative_Eigen_value, fill=Percent_Accumulative_Eigen_value)) +
  geom_bar(stat="identity", color="black", position=position_dodge())+
  theme_minimal()



library(scales)
ggplot(EV, aes(reorder(location, - total_deaths) , total_deaths, group=1)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  geom_bar(stat = "identity", fill = "green") +
  scale_y_continuous(labels = comma) +
  ggtitle("Top 15 Worst Countries") + xlab("Country") + ylab("Number of Deaths")


EV %>% 
  arrange(desc(Percent_Accumulative_Eigen_value)) %>%
  mutate(variable=fct_reorder(PCs,Percent_Accumulative_Eigen_value)) %>% 
  ggplot(aes(PCs,Percent_Accumulative_Eigen_value,fill=PCs)) + geom_bar(stat="identity") + 
  scale_y_continuous("",label=scales::percent) + coord_flip() 


EV <- EV[with(EV,order(-Percent_Accumulative_Eigen_value)), ] ## Sorting
EV$PCs <- ordered(EV$PCs, levels=levels(EV$PCs)[unclass(EV$PCs)])

ggplot(EV, aes(x=PCs,y=Percent_Accumulative_Eigen_value)) + geom_bar(stat = "identity") +
  + coord_flip()





