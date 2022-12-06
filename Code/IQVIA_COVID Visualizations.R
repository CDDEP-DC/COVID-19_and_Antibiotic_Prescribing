# COVID-19 and Antibiotic Prescribing
# Generate figures
# Created by Suprena Poleon

library(readxl)
library(ggplot2)
library(dplyr)
library(RColorBrewer)
library(ggpmisc)
library(Hmisc)
library(lubridate)
library(zoo)
library(data.table)
library(tidyverse)
library(scales)
library(usmap)
library(ggeasy)
#library(tidyr)
library(cowplot)
library(ggpubr)
library("devtools")


options(scipen=999)
setwd("[Main file path]/Data/")
########################### By Month (bar chart) ###############################
# 2017
Data2017 <- read.csv(file = "IQVIAAnalysis2017_AH_v2.csv")[,2:9] #find a better way to remove the 1st column
Data2017$month = substr(Data2017$year_month, start = 5, stop = 6)

ByMonth2017<-Data2017
tot_pop=unique(ByMonth2017$POPESTIMATE2017)
ByMonth2017$POPESTIMATE2017=NULL
ByMonth2017$POPESTIMATE2017=sum(tot_pop)
ByMonth2017 <- ByMonth2017 %>% group_by(POPESTIMATE2017,year_month,month)%>%summarise(trx2017=sum(trx))
ByMonth2017$trx2017_per100k=((ByMonth2017$trx2017/ByMonth2017$POPESTIMATE2017)*100000)

# 2018
Data2018 <- read.csv(file = "IQVIAAnalysis2018_AH_v2.csv")[,2:9]
Data2018$month = substr(Data2018$year_month, start = 5, stop = 6)

ByMonth2018<-Data2018
tot_pop=unique(ByMonth2018$POPESTIMATE2018)
ByMonth2018$POPESTIMATE2018=NULL
ByMonth2018$POPESTIMATE2018=sum(tot_pop)
ByMonth2018 <- ByMonth2018 %>% group_by(POPESTIMATE2018,year_month,month)%>%summarise(trx2018=sum(trx))
ByMonth2018$trx2018_per100k=((ByMonth2018$trx2018/ByMonth2018$POPESTIMATE2018)*100000)

# 2019
Data2019 <- read.csv(file = "IQVIAAnalysis2019_AH_v2.csv")[,2:9]
Data2019$month = substr(Data2019$year_month, start = 5, stop = 6)

ByMonth2019<-Data2019
tot_pop=unique(ByMonth2019$POPESTIMATE2019)
ByMonth2019$POPESTIMATE2019=NULL
ByMonth2019$POPESTIMATE2019=sum(tot_pop)
ByMonth2019 <- ByMonth2019 %>% group_by(POPESTIMATE2019,year_month,month)%>%summarise(trx2019=sum(trx))
ByMonth2019$trx2019_per100k=((ByMonth2019$trx2019/ByMonth2019$POPESTIMATE2019)*100000)

# 2020
Data2020 <- read.csv(file = "IQVIAAnalysis2020_AH_v2.csv")[,2:9]
Data2020$month = substr(Data2020$year_month, start = 5, stop = 6)

ByMonth2020<-Data2020
tot_pop=unique(ByMonth2020$POPESTIMATE2020)
ByMonth2020$POPESTIMATE2020=NULL
ByMonth2020$POPESTIMATE2020=sum(tot_pop)
ByMonth2020 <- ByMonth2020 %>% group_by(POPESTIMATE2020,year_month,month)%>%summarise(trx2020=sum(trx))
ByMonth2020$trx2020_per100k=((ByMonth2020$trx2020/ByMonth2020$POPESTIMATE2020)*100000)

# All years
ByMonthAll <- cbind(ByMonth2017, trx2018=ByMonth2018$trx2018_per100k, trx2019=ByMonth2019$trx2019_per100k, trx2020=ByMonth2020$trx2020_per100k)
ByMonthAll$trx2017=NULL
colnames(ByMonthAll)[4]="trx2017"
ByMonthAll$trx2017_2019 <- rowMeans(ByMonthAll[,c("trx2017", "trx2018", "trx2019")], na.rm=TRUE)
ByMonthAll <- ByMonthAll %>% mutate(percent_change = ((-(trx2020-trx2017_2019)/trx2017_2019)))

#Rename row in order to merge
setnames(Data2017, "POPESTIMATE2017","popestimate")
setnames(Data2018, "POPESTIMATE2018","popestimate")
setnames(Data2019, "POPESTIMATE2019","popestimate")
setnames(Data2020, "POPESTIMATE2020","popestimate")

#Extract year from date
Data2017$date=ym(Data2017$year_month)
Data2017$year=format(Data2017$date, format="%Y")

Data2018$date=ym(Data2018$year_month)
Data2018$year=format(Data2018$date, format="%Y")

Data2019$date=ym(Data2019$year_month)
Data2019$year=format(Data2019$date, format="%Y")

Data2020$date=ym(Data2020$year_month)
Data2020$year=format(Data2020$date, format="%Y")


#Create new datasets
DataAll <- rbind(Data2017,Data2018,Data2019, Data2020)
write.csv(DataAll,"[Main file path]/Data/data_2017_2020.csv", row.names = FALSE)


ByStateAll<-DataAll
ByStateAll <- DataAll %>% group_by(prescriber_st,popestimate,year_month,month,year) %>% summarise(trx = sum(trx, decimals=TRUE, digits=2)) #fix rounding
ByStateAll$trx_per100k=((ByStateAll$trx/ByStateAll$popestimate)*100000)
#states.names <- unique(ByStateAll$prescriber_st)

#Create Year variable
ByMonth2017$Year=2017
ByMonth2018$Year=2018
ByMonth2019$Year=2019
ByMonth2020$Year=2020

#Create trx column for row merge
names(ByMonth2017)[names(ByMonth2017)=="trx2017_per100k"]="trx"
names(ByMonth2018)[names(ByMonth2018)=="trx2018_per100k"]="trx"
names(ByMonth2019)[names(ByMonth2019)=="trx2019_per100k"]="trx"
names(ByMonth2020)[names(ByMonth2020)=="trx2020_per100k"]="trx"

ByMonth2017$trx2017=NULL
ByMonth2018$trx2018=NULL
ByMonth2019$trx2019=NULL
ByMonth2020$trx2020=NULL

setnames(ByMonth2017, "POPESTIMATE2017","popestimate")
setnames(ByMonth2018, "POPESTIMATE2018","popestimate")
setnames(ByMonth2019, "POPESTIMATE2019","popestimate")
setnames(ByMonth2020, "POPESTIMATE2020","popestimate")


###################################BY MONTH######################################
#rowmerge
DataByMonthAll= rbind(ByMonth2017,ByMonth2018,ByMonth2019,ByMonth2020)

#######LINE GRAPH######
#make year a factor before generating line graph
DataByMonthAll$Year=as.factor(DataByMonthAll$Year)

ggplot(DataByMonthAll, aes(x=month,y=trx, group= Year,color=Year))+geom_line()+
  theme_classic()+labs(x="Month", y="Prescriptions per 100k Population", title="Prescriptions per 100k Population by Month for 2017-2020")+
  geom_point()+ scale_x_discrete(labels=month.abb)+scale_y_continuous(labels = comma)+
  theme_bw()+theme(plot.title=element_text(hjust=0.5))

###########################BY YEAR##############################
yr2017=select(Data2017,c(popestimate,trx,year,month))
yr17=subset(yr2017,month>="03")#march 2020
yr17$month=NULL
tot_pop=unique(yr17$popestimate)
yr17$popestimate=sum(tot_pop)
yr17 <- yr17 %>% group_by(popestimate,year)%>%summarise(trx=sum(trx))
yr17$trx_per100k=((yr17$trx/yr17$popestimate)*100000)

yr2018=select(Data2018,c(popestimate,trx,year,month))
yr18=subset(yr2018,month>="03")#march 2020
yr20$month=NULL
tot_pop=unique(yr18$popestimate)
yr18$popestimate=sum(tot_pop)
yr18 <- yr18 %>% group_by(popestimate,year)%>%summarise(trx=sum(trx))
yr18$trx_per100k=((yr18$trx/yr18$popestimate)*100000)

yr2019=select(Data2019,c(popestimate,trx,year,month))
yr19=subset(yr2019,month>="03")#march 2020
yr20$month=NULL
tot_pop=unique(yr19$popestimate)
yr19$popestimate=sum(tot_pop)
yr19 <- yr19 %>% group_by(popestimate,year)%>%summarise(trx=sum(trx))
yr19$trx_per100k=((yr19$trx/yr19$popestimate)*100000)

yr2020=select(Data2020,c(popestimate,trx,year,month))
yr20=subset(yr2020,month>="03")#march 2020
yr20$month=NULL
tot_pop=unique(yr20$popestimate)
yr20$popestimate=sum(tot_pop)
yr20 <- yr20 %>% group_by(popestimate,year)%>%summarise(trx=sum(trx))
yr20$trx_per100k=((yr20$trx/yr20$popestimate)*100000)

yr_17_19=rbind(yr17,yr18,yr19)
yr_17_19$mean=mean(yr_17_19$trx_per100k)
yr_17_19$mean_trx=mean(yr_17_19$trx)
yr_20$mean_trx=mean(yr20$trx)
yr_17_19$trx_per100k=NULL
colnames(yr_17_19)[4]="trx_per100k"
yr_all=rbind(yr_17_19,yr20)

###################################BY STATE#####################################

#Create new datasets grouped by state
Data2017_2=Data2017%>%group_by(prescriber_st,popestimate,year) %>% summarise(trx = sum(trx, decimals=TRUE, digits=2))
Data2017_2$trx2017_per100k=((Data2017_2$trx/Data2017_2$popestimate)*100000)

Data2018_2=Data2018%>%group_by(prescriber_st,popestimate,year) %>% summarise(trx = sum(trx, decimals=TRUE, digits=2))
Data2018_2$trx2018_per100k=((Data2018_2$trx/Data2018_2$popestimate)*100000)

Data2019_2=Data2019%>%group_by(prescriber_st,popestimate,year) %>% summarise(trx = sum(trx, decimals=TRUE, digits=2))
Data2019_2$trx2019_per100k=((Data2019_2$trx/Data2019_2$popestimate)*100000)

Data2020_2=Data2020%>%group_by(prescriber_st,popestimate,year) %>% summarise(trx = sum(trx, decimals=TRUE, digits=2))
Data2020_2$trx2020_per100k=((Data2020_2$trx/Data2020_2$popestimate)*100000)

#merge datasets
ByStateAll2= cbind(Data2017_2, trx2018=Data2018_2$trx2018_per100k, trx2019=Data2019_2$trx2019_per100k, trx2020=Data2020_2$trx2020_per100k)
ByStateAll2$trx=NULL
colnames(ByStateAll2)[4]="trx2017"

#Calulate % change
ByStateAll2$trx2017_2019=rowMeans(ByStateAll2[,c("trx2017", "trx2018", "trx2019")], na.rm=TRUE)
ByStateAll2= ByStateAll2%>%mutate(percent_change = (((trx2020-trx2017_2019)/trx2017_2019)))
ByStateAll2=arrange(ByStateAll2,percent_change)

write.csv(ByStateAll2,"[Main file path]/Data/PctChnge_ByState_trx.csv", row.names = FALSE)

setnames(ByStateAll2,"prescriber_st","state")
ByStateAll2$percent_change=ByStateAll2$percent_change*100

plot_usmap(data = ByStateAll2, values = "percent_change", color = as.factor("percent_change")) + 
  scale_fill_continuous(
    low = "red", high = "white", name = "Percent Decline in Prescriptions(%)", label = scales::comma
  ) + theme(legend.position = "right")+labs(title = "U.S. Map",
                                            subtitle = "Percent Decline in Prescriptions per 100,000 Population by State")

#################Plot Panel##################

pct_chnge=plot_usmap(data = ByStateAll2, values = "percent_change", color = as.factor("percent_change")) + 
  scale_fill_continuous(
    low = "red", high = "white", name = "Percent Change in Prescriptions (%)", label = scales::comma
  ) + theme(legend.position = "right")+labs(title = "U.S. Map",
                                            subtitle = "Percent Change in Prescriptions per 100,000 Population by State")

lineplot=ggplot(DataByMonthAll, aes(x=month,y=trx, group= Year,color=Year))+geom_line()+
  theme_classic()+labs(x="Month", y="Prescriptions per 100,000 Population", title="Prescriptions per 100,000 Population by Month for 2017-2020")+
  geom_point()+ scale_x_discrete(labels=month.abb)+scale_y_continuous(labels = comma)+
  theme_bw()+theme(plot.title=element_text(hjust=0.5))


plot_grid(lineplot,pct_chnge, nrow=2,labels="AUTO")


####################################BY CLASS####################################
class17<-Data2017
class17$class_cat=dplyr::recode(class17$class,"Broad-spectrum Penicillins" = "Broad-spectrum Penicillins",
                                "Tetracyclines" = "Tetracyclines","Trimethoprim and combinations"="Trimethoprim and combinations", 
                                "Macrolides"="Macrolides","Cephalosporins"="Cephalosporins","Quinolones"="Quinolones", 
                                "Narrow-spectrum Penicillins"="Narrow-spectrum Penicillins", .default="Others")
tot_pop=unique(class17$popestimate)
class17$POPESTIMATE=sum(tot_pop)
class2017 <- class17 %>% group_by(class,POPESTIMATE,year)%>%summarise(trx=sum(trx))
class2017$trx_per100k=((class2017$trx/class2017$POPESTIMATE)*100000)


class18<-Data2018
class18$class_cat=dplyr::recode(class18$class,"Broad-spectrum Penicillins" = "Broad-spectrum Penicillins",
                                "Tetracyclines" = "Tetracyclines","Trimethoprim and combinations"="Trimethoprim and combinations", 
                                "Macrolides"="Macrolides","Cephalosporins"="Cephalosporins","Quinolones"="Quinolones", 
                                "Narrow-spectrum Penicillins"="Narrow-spectrum Penicillins", .default="Others")
tot_pop=unique(class18$popestimate)
class18$POPESTIMATE=sum(tot_pop)
class2018 <- class18 %>% group_by(class,POPESTIMATE,year)%>%summarise(trx=sum(trx))
class2018$trx_per100k=((class2018$trx/class2018$POPESTIMATE)*100000)


class19<-Data2019
class19$class_cat=dplyr::recode(class19$class,"Broad-spectrum Penicillins" = "Broad-spectrum Penicillins",
                                "Tetracyclines" = "Tetracyclines","Trimethoprim and combinations"="Trimethoprim and combinations", 
                                "Macrolides"="Macrolides","Cephalosporins"="Cephalosporins","Quinolones"="Quinolones", 
                                "Narrow-spectrum Penicillins"="Narrow-spectrum Penicillins", .default="Others")
tot_pop=unique(class19$popestimate)
class19$POPESTIMATE=sum(tot_pop)
class2019 <- class19 %>% group_by(class,POPESTIMATE,year)%>%summarise(trx=sum(trx))
class2019$trx_per100k=((class2019$trx/class2019$POPESTIMATE)*100000)


class20<-Data2020
class20$class_cat=dplyr::recode(class20$class,"Broad-spectrum Penicillins" = "Broad-spectrum Penicillins",
                                "Tetracyclines" = "Tetracyclines","Trimethoprim and combinations"="Trimethoprim and combinations", 
                                "Macrolides"="Macrolides","Cephalosporins"="Cephalosporins","Quinolones"="Quinolones", 
                                "Narrow-spectrum Penicillins"="Narrow-spectrum Penicillins", .default="Others")
tot_pop=unique(class20$popestimate)
class20$POPESTIMATE=sum(tot_pop)
class2020 <- class20 %>% group_by(class,POPESTIMATE,year)%>%summarise(trx=sum(trx))
class2020$trx_per100k=((class2020$trx/class2020$POPESTIMATE)*100000)


classtot=rbind(class2017,class2018,class2019,class2020)

#line graph of all antibiotic classes
ggplot(classtot, aes(x=year,y=trx_per100k, group= class, color=class))+
  geom_line()+geom_point()+theme_classic()+xlab("Year")+ylab("Total Prescriptions per 100k")
ggtitle(("Total Prescriptions per Capita By Antibiotic Class for 2017-2020"))

#Recategorize Class
recat17 <- class17 %>% group_by(class_cat,POPESTIMATE,year)%>%summarise(trx=sum(trx))
recat17$trx_per100k=((recat17$trx/recat17$POPESTIMATE)*100000)

recat18 <- class18 %>% group_by(class_cat,POPESTIMATE,year)%>%summarise(trx=sum(trx))
recat18$trx_per100k=((recat18$trx/recat18$POPESTIMATE)*100000)

recat19 <- class19 %>% group_by(class_cat,POPESTIMATE,year)%>%summarise(trx=sum(trx))
recat19$trx_per100k=((recat19$trx/recat19$POPESTIMATE)*100000)

recat20 <- class20 %>% group_by(class_cat,POPESTIMATE,year)%>%summarise(trx=sum(trx))
recat20$trx_per100k=((recat20$trx/recat20$POPESTIMATE)*100000)

recat=rbind(recat17,recat18,recat19,recat20)

#########LINE GRAPH of recategorized antibiotic class######
ggplot(recat, aes(x=year,y=trx_per100k, group= class_cat, color=class_cat))+geom_line()+
  geom_point()+theme_classic()+xlab("Year")+ylab("Total Prescriptions(100k)")+
  guides(color=guide_legend(title="Antibiotic Class"))+
  ggtitle(("Total Prescribed Prescriptions per Capita By Antibiotic Class for 2017-2019"))



totalclass=subset(recat, select = c(class_cat, trx_per100k,year))

classmeans_17_19=subset(totalclass,year<2020)
classmeans_20=subset(totalclass,year==2020)

Classmeans=classmeans_17_19 %>% 
  spread(year, trx_per100k)
Classmeans=Classmeans%>%rowwise()%>%mutate(trx_per100k=mean(c(`2017`,`2018`,`2019`)))
Classmeans$year=2019

Classmeans <- select(Classmeans, -(2:4))

Classmeans=rbind(Classmeans,classmeans_20)

############BARPLOT by Class for 2017-2019 vs 2020#########
Classmeans$class_cat=factor(Classmeans$class_cat)
ggplot(Classmeans, aes(x = reorder(class_cat,trx_per100k), y = trx_per100k, group=trx_per100k,fill = year))+
  geom_bar(stat = "identity", width = 0.5, position="dodge") +
  xlab("Antibiotic Drug Class")+ylab("Mean Prescriptions per 100k Population")+
  scale_fill_discrete(name="Year", labels=c("2017-2019","2020"))+
  ggtitle(("Mean Prescriptions per 100k Population by Class for 2017-2020"))+
  coord_flip()+theme_bw()+theme(plot.title=element_text(hjust=0.5))


########################AGE##########################
byage=read_csv("[Main file path]/Data/IQVIA_AgeGroups_AllYears_v3_trx.csv")
byage$...1=NULL

trx2017=subset(byage,year==2017)
trx_pop=select(trx2017,c(age_group,pop))
trx_pop=unique(trx_pop,by=age_group)
trx2017_pop<- trx_pop %>% group_by(age_group)%>%summarise(pop=sum(pop))
trx2017$pop=NULL
trx2017 <- trx2017 %>% group_by(age_group,year)%>%summarise(trx=sum(trx))
trx2017=left_join(trx2017,trx2017_pop)
trx2017$trx_per100k=((trx2017$trx/trx2017$pop)*100000)


trx2018=subset(byage,year==2018)
trx2018=select(trx2018,c(age_group,year,trx,pop))
trx_pop=select(trx2018,c(age_group,pop))
trx_pop=unique(trx_pop,by=age_group)
trx2018_pop<- trx_pop %>% group_by(age_group)%>%summarise(pop=sum(pop))
trx2018$pop=NULL
trx2018 <- trx2018 %>% group_by(age_group,year)%>%summarise(trx=sum(trx))
trx2018=left_join(trx2018,trx2018_pop)
trx2018$trx_per100k=((trx2018$trx/trx2018$pop)*100000)


trx2019=subset(byage,year==2019)
trx2019=select(trx2019,c(age_group,year,trx,pop))
trx_pop=select(trx2019,c(age_group,pop))
trx_pop=unique(trx_pop,by=age_group)
trx2019_pop<- trx_pop %>% group_by(age_group)%>%summarise(pop=sum(pop))
trx2019$pop=NULL
trx2019 <- trx2019 %>% group_by(age_group,year)%>%summarise(trx=sum(trx))
trx2019=left_join(trx2019,trx2019_pop)
trx2019$trx_per100k=((trx2019$trx/trx2019$pop)*100000)


trx2020=subset(byage,year==2020)
trx2020=select(trx2020,c(age_group,year,trx,pop))
#trx2020=trx2020%>%group_by(age_group)
#trx2017_2019=select(byage,c(age_group,trx,pop))
#trx_pop=trx2020 %>% group_by(age_group,year,trx)%>%filter(row_number(pop)==1)


#tot_pop=unique(trx2020)
#trx2020$pop=sum(tot_pop)

#trx2020_trx<- trx2020 %>% group_by(age_group)%>%summarise(trx=sum(trx))

trx_pop=select(trx2020,c(age_group,pop))
trx_pop=unique(trx_pop,by=age_group)
trx2020_pop<- trx_pop %>% group_by(age_group)%>%summarise(pop=sum(pop))
trx2020$pop=NULL
trx2020 <- trx2020 %>% group_by(age_group,year)%>%summarise(trx=sum(trx))
trx2020=left_join(trx2020,trx2020_pop)
trx2020$trx_per100k=((trx2020$trx/trx2020$pop)*100000)

agemeans_17_19=rbind(trx2017,trx2018,trx2019)#merge data
agemeans_17_19 <- select(agemeans_17_19, -(3:4))

Agemeans=agemeans_17_19 %>% 
  spread(year, trx_per100k)
Agemeans=Agemeans%>%rowwise()%>%mutate(trx_per100k=mean(c(`2017`,`2018`,`2019`)))
Agemeans$year=2019

Agemeans <- select(Agemeans, -(2:4))
#colnames(Agemeans)[3]="Year"

trx2020=select(trx2020, -(3:4))
Agemeans=rbind(Agemeans,trx2020)

Agemeans$year=format(Agemeans$year, format="%Y")
Agemeans$age_group=as.factor(Agemeans$age_group)

Agemeans$age_group=factor(Agemeans$age_group, levels=c("0-2","3-9","10-19","20-39","40-59","60-74","75+"))

#ordered by age and means
ggplot(Agemeans, aes(x = reorder(age_group,trx_per100k), y = trx_per100k, group=trx_per100k,fill = year))+
  geom_bar(stat = "identity", width = 0.5, position="dodge") +
  xlab("Age Group (Years)")+ylab("Mean DDDs per 100k Population")+
  scale_fill_discrete(name="Year", labels=c("2017-2019","2020"))+
  ggtitle(("Mean DDDs per 100k Population by Age for 2017-2020"))+
  coord_flip()+theme_bw()+theme(plot.title=element_text(hjust=0.5))

ggplot(Agemeans, aes(x = age_group, y = trx_per100k, group=trx_per100k,fill = year))+
  geom_bar(stat = "identity", width = 0.5, position="dodge") +
  xlab("Age Group (Years)")+ylab("Mean DDDs per 100k Population")+
  scale_fill_discrete(name="Year", labels=c("2017-2019","2020"))+
  ggtitle(("Mean DDDs per 100k Population by Age for 2017-2020"))+
  coord_flip()+theme_bw()+theme(plot.title=element_text(hjust=0.5))

