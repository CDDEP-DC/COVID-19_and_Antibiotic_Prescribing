# COVID-19 and Antibiotic Prescribing
# Generate Figures 1 and 2
# Created by Suprena Poleon

options(scipen=999)
library(ggplot2)
library(cowplot)
library(grid)
library(gridExtra)

setwd("[Maine file path]/Data")
dat1 <- read.csv(file = "IQVIA_AgeClass_byState.csv") 
dat1$X=NULL

Data2017=subset(dat1, year==2017)
Data2017=select(Data2017, -(8:10))
ByMonth2017=Data2017
ByMonth2017$POPEST2017_CIV=sum(unique(ByMonth2017$POPEST2017_CIV))#323931513
ByMonth2017 <- ByMonth2017 %>% group_by(POPEST2017_CIV,month)%>%summarise(trx=sum(trx))
ByMonth2017$trx_per100k=((ByMonth2017$trx/ByMonth2017$POPEST2017_CIV)*100000)
ByMonth2017$POPEST2017_CIV=NULL
ByMonth2017$year=2017

Data2018=subset(dat1, year==2018)
Data2018=select(Data2018, -(7))
Data2018=select(Data2018, -(8:9))
ByMonth2018=Data2018
ByMonth2018 <- ByMonth2018[complete.cases(ByMonth2018), ]
ByMonth2018$POPEST2018_CIV=sum(unique(ByMonth2018$POPEST2018_CIV))#325651278
ByMonth2018 <- ByMonth2018 %>% group_by(POPEST2018_CIV,month)%>%summarise(trx=sum(trx))
ByMonth2018$trx_per100k=((ByMonth2018$trx/ByMonth2018$POPEST2018_CIV)*100000)
ByMonth2018$POPEST2018_CIV=NULL
ByMonth2018$year=2018

Data2019=subset(dat1, year==2019)
Data2019=select(Data2019, -(7:8))
Data2019=select(Data2019, -(8))
ByMonth2019=Data2019
ByMonth2019 <- ByMonth2019[complete.cases(ByMonth2019), ]
ByMonth2019$POPEST2019_CIV=sum(unique(ByMonth2019$POPEST2019_CIV))#327143032
ByMonth2019 <- ByMonth2019 %>% group_by(POPEST2019_CIV,month)%>%summarise(trx=sum(trx))
ByMonth2019$trx_per100k=((ByMonth2019$trx/ByMonth2019$POPEST2019_CIV)*100000)
ByMonth2019$POPEST2019_CIV=NULL
ByMonth2019$year=2019

Data2020=subset(dat1, year==2020)
Data2020=select(Data2020, -(7:9))
ByMonth2020=Data2020
ByMonth2020 <- ByMonth2020[complete.cases(ByMonth2020), ]
ByMonth2020$POPEST2020_CIV=sum(unique(ByMonth2020$POPEST2020_CIV))#328297202
ByMonth2020 <- ByMonth2020 %>% group_by(POPEST2020_CIV,month)%>%summarise(trx=sum(trx))
ByMonth2020$trx_per100k=((ByMonth2020$trx/ByMonth2020$POPEST2020_CIV)*100000)
ByMonth2020$POPEST2020_CIV=NULL
ByMonth2020$year=2020

Data2017$popestimate=Data2017$POPEST2017_CIV
Data2017$POPEST2017_CIV=NULL

Data2018$popestimate=Data2018$POPEST2018_CIV
Data2018$POPEST2018_CIV=NULL
Data2018 <- Data2018[complete.cases(Data2018), ]

Data2019$popestimate=Data2019$POPEST2019_CIV
Data2019$POPEST2019_CIV=NULL

Data2020$popestimate=Data2020$POPEST2020_CIV
Data2020$POPEST2020_CIV=NULL

DataAll= rbind(Data2017,Data2018,Data2019,Data2020)
################total antibiotics for march to december 2017-2019 vs 2020#########
data_17_19=rbind(Data2017,Data2018,Data2019)
data_17_19=subset(data_17_19,month>=3)
data_17_19 <- data_17_19 %>% group_by(year)%>%summarise(trx=sum(trx),popestimate=sum(unique(popestimate)))
data_17_19$trx_per100k=(data_17_19$trx/data_17_19$popestimate)*100000
mean(data_17_19$trx_per100k)

data_20=subset(Data2020,month>=3)
data_20 <- data_20 %>% group_by(year)%>%summarise(trx=sum(trx),popestimate=sum(unique(popestimate)))
data_20$trx_per100k=(data_20$trx/data_20$popestimate)*100000

###################################BY MONTH######################################
#rowmerge
DataByMonthAll= rbind(ByMonth2017,ByMonth2018,ByMonth2019,ByMonth2020)

DataByMonthAll$year=as.factor(DataByMonthAll$year)
DataByMonthAll$month=as.factor(DataByMonthAll$month)

ggplot(DataByMonthAll, aes(x=month,y=trx, group= year,color=year))+geom_line()+
  theme_classic()+labs(x="Month", y="Prescriptions per 100k Population", title="Prescriptions per 100k Population by Month for 2017-2020")+
  geom_point()+ scale_x_discrete(labels=month.abb)+scale_y_continuous(labels = comma)+
  theme_bw()+theme(plot.title=element_text(hjust=0.5))

###################################BY STATE#####################################
#Create new datasets grouped by state

Data2017_2=Data2017%>%group_by(prescriber_st,year) %>% summarise(trx = sum(trx), popestimate=sum(unique(popestimate)))
Data2017_2$trx2017_per100k=((Data2017_2$trx/Data2017_2$popestimate)*100000)

Data2018_2=Data2018%>%group_by(prescriber_st,year) %>% summarise(trx = sum(trx), popestimate=sum(unique(popestimate)))
Data2018_2$trx2018_per100k=((Data2018_2$trx/Data2018_2$popestimate)*100000)

Data2019_2=Data2019%>%group_by(prescriber_st,year) %>% summarise(trx = sum(trx), popestimate=sum(unique(popestimate)))
Data2019_2$trx2019_per100k=((Data2019_2$trx/Data2019_2$popestimate)*100000)

Data2020_2=Data2020%>%group_by(prescriber_st,year) %>% summarise(trx = sum(trx),popestimate=sum(unique(popestimate)))
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

#################Month and State Plot Panel##################
pdf(file = "[Main file path]/Results/Figure1_Prescriptions_by_Month_and_State.pdf",   # The directory you want to save the file in
    width = 8, # The width of the plot in inches
    height =8 ) # The height of the plot in inches

pct_chnge=plot_usmap(data = ByStateAll2, values = "percent_change", color = as.factor("percent_change")) + 
  scale_fill_continuous(
    low = "red", high = "white", name = "Percent Change in Prescriptions (%)", label = scales::comma
  ) + theme(legend.position = "right")+labs(title = "U.S. Map",
                                            subtitle = "Percent Change in Prescriptions per 100,000 Population by State")

lineplot=ggplot(DataByMonthAll, aes(x=month,y=trx, group= year,color=year))+geom_line()+
  theme_classic()+labs(x="Month", y="Prescriptions per 100,000 Population", title="Prescriptions per 100,000 Population by Month for 2017-2020")+
  geom_point()+ scale_x_discrete(labels=month.abb)+scale_y_continuous(labels = comma)+
  theme_bw()+theme(plot.title=element_text(hjust=0.5))


cowplot::plot_grid(lineplot,pct_chnge, nrow=2,labels="AUTO")
dev.off()
####################################BY CLASS####################################
class_all=DataAll%>%group_by(class,year)%>%summarise(trx = sum(trx),popestimate=sum(unique(popestimate)))
class_all$trx_per100k=(class_all$trx/class_all$popestimate)*100000

#line graph of all antibiotic classes
ggplot(class_all, aes(x=year,y=trx_per100k, group= class, color=class))+
  geom_line()+geom_point()+theme_classic()+xlab("Year")+ylab("Total DDD Per Thousand")
ggtitle(("Total DDDs per Capita By Antibiotic Class for 2017-2020"))


#RECATEGORIZE
class17<-Data2017
class17$class_cat=dplyr::recode(class17$class,"Broad-spectrum Penicillins" = "Broad-spectrum Penicillins",
                                "Tetracyclines" = "Tetracyclines","Trimethoprim and combinations"="Trimethoprim and combinations", 
                                "Macrolides"="Macrolides","Cephalosporins"="Cephalosporins","Quinolones"="Quinolones", 
                                "Narrow-spectrum Penicillins"="Narrow-spectrum Penicillins", .default="Others")
#class17$POPESTIMATE=sum(unique(class17$popestimate))
class2017 <- class17 %>% group_by(class_cat,year)%>%summarise(trx = sum(trx),POPESTIMATE=sum(unique(popestimate)))
class2017$trx_per100k=((class2017$trx/class2017$POPESTIMATE)*100000)


class18<-Data2018
class18$class_cat=dplyr::recode(class18$class,"Broad-spectrum Penicillins" = "Broad-spectrum Penicillins",
                                "Tetracyclines" = "Tetracyclines","Trimethoprim and combinations"="Trimethoprim and combinations", 
                                "Macrolides"="Macrolides","Cephalosporins"="Cephalosporins","Quinolones"="Quinolones", 
                                "Narrow-spectrum Penicillins"="Narrow-spectrum Penicillins", .default="Others")
class2018 <- class18 %>% group_by(class_cat,year)%>%summarise(trx = sum(trx),POPESTIMATE=sum(unique(popestimate)))
class2018$trx_per100k=((class2018$trx/class2018$POPESTIMATE)*100000)


class19<-Data2019
class19$class_cat=dplyr::recode(class19$class,"Broad-spectrum Penicillins" = "Broad-spectrum Penicillins",
                                "Tetracyclines" = "Tetracyclines","Trimethoprim and combinations"="Trimethoprim and combinations", 
                                "Macrolides"="Macrolides","Cephalosporins"="Cephalosporins","Quinolones"="Quinolones", 
                                "Narrow-spectrum Penicillins"="Narrow-spectrum Penicillins", .default="Others")
class2019 <- class19 %>% group_by(class_cat,year)%>%summarise(trx = sum(trx),POPESTIMATE=sum(unique(popestimate)))
class2019$trx_per100k=((class2019$trx/class2019$POPESTIMATE)*100000)


class20<-Data2020
class20$class_cat=dplyr::recode(class20$class,"Broad-spectrum Penicillins" = "Broad-spectrum Penicillins",
                                "Tetracyclines" = "Tetracyclines","Trimethoprim and combinations"="Trimethoprim and combinations", 
                                "Macrolides"="Macrolides","Cephalosporins"="Cephalosporins","Quinolones"="Quinolones", 
                                "Narrow-spectrum Penicillins"="Narrow-spectrum Penicillins", .default="Others")
class2020 <- class20 %>% group_by(class_cat,year)%>%summarise(trx = sum(trx),POPESTIMATE=sum(unique(popestimate)))
class2020$trx_per100k=((class2020$trx/class2020$POPESTIMATE)*100000)


classtot=rbind(class2017,class2018,class2019,class2020)

#########LINE GRAPH of recategorized antibiotic class######
ggplot(classtot, aes(x=year,y=trx_per100k, group= class_cat, color=class_cat))+geom_line()+
  geom_point()+theme_classic()+xlab("Year")+ylab("Total Prescriptions(100k)")+
  guides(color=guide_legend(title="Antibiotic Class"))+
  ggtitle(("Total Prescribed Prescriptions per Capita By Antibiotic Class for 2017-2019"))

totalclass=subset(classtot, select = c(class_cat, trx_per100k,year))

classmeans_17_19=subset(totalclass,year<2020)
classmeans_20=subset(totalclass,year==2020)

Classmeans=classmeans_17_19 %>% 
  spread(year, trx_per100k)
Classmeans=Classmeans%>%rowwise()%>%mutate(trx_per100k=mean(c(`2017`,`2018`,`2019`)))
Classmeans$year=2019

Classmeans <- select(Classmeans, -(2:4))

Classmeans=rbind(Classmeans,classmeans_20)

############BARPLOT by Class for 2017-2019 vs 2020#########
Classmeans$class_cat=as.factor(Classmeans$class_cat)
Classmeans$year=as.factor(Classmeans$year)

ggplot(Classmeans, aes(x = reorder(class_cat,trx_per100k), y = trx_per100k, group=trx_per100k,fill = year))+
  geom_bar(stat = "identity", width = 0.5, position="dodge") +
  xlab("Antibiotic Drug Class")+ylab("Mean Prescriptions per 100k Population")+
  scale_fill_discrete(name="Year", labels=c("2017-2019","2020"))+
  ggtitle(("Mean Prescriptions per 100k Population by Class for 2017-2020"))+
  coord_flip()+theme_bw()+theme(plot.title=element_text(hjust=0.5))

########################AGE##########################3
#byage=read_csv("/Users/suprenapoleon/Library/CloudStorage/OneDrive-CenterforDiseaseDynamics,Economics&Policy/CDDEP Research Projects (active)/IMS/2017-2020 IQVIA Data/ProcessedData/IQVIA_AgeGroups_AllYears_v3_trx.csv")
#byage$...1=NULL
byage=DataAll
byage=byage %>% group_by(age_group,year)%>%summarise(trx = sum(trx),popestimate=sum(unique(popestimate)))
byage$trx_per100k=((byage$trx/byage$popestimate)*100000)
byage=select(byage,-(3:4))

agemeans_17_19=subset(byage,year<2020)
agemeans_20=subset(byage,year==2020)

Agemeans=agemeans_17_19 %>% 
  spread(year, trx_per100k)
Agemeans=Agemeans%>%rowwise()%>%mutate(trx_per100k=mean(c(`2017`,`2018`,`2019`)))
Agemeans$year=2019

Agemeans <- select(Agemeans, -(2:4))
#colnames(Agemeans)[3]="Year"

#trx2020=select(trx2020, -(3:4))
Agemeans=rbind(Agemeans,agemeans_20)

Agemeans$year=format(Agemeans$year, format="%Y")
Agemeans$age_group=as.factor(Agemeans$age_group)

Agemeans$age_group=factor(Agemeans$age_group, levels=c("0-2","3-9","10-19","20-39","40-59","60-74","75+"))

ggplot(Agemeans, aes(x = age_group, y = trx_per100k, group=trx_per100k,fill = year))+
  geom_bar(stat = "identity", width = 0.5, position="dodge") +
  xlab("Age Group (Years)")+ylab("Mean Prescriptions per 100,000 Population")+
  scale_fill_discrete(name="Year", labels=c("2017-2019 Average","2020"))+
  scale_y_continuous(breaks = seq(0, 120000, by = 20000), labels=comma)+
  ggtitle(("Mean Prescriptions per 100,000 Population by Age for 2017-2020"))+
  coord_flip()+theme_bw()+theme(plot.title=element_text(hjust=0.5))

################Class and Age Means Plot Panel#########################
pdf(file = "[Main file path]/Results/Figure2_Prescriptions_by_Class_and_Age_Means.pdf",   # The directory you want to save the file in
    width = 8, # The width of the plot in inches
    height =8 ) # The height of the plot in inches

bargraph=ggplot(Classmeans, aes(x = reorder(class_cat,trx_per100k), y = trx_per100k, group=trx_per100k,fill = year))+
  geom_bar(stat = "identity", width = 0.5, position="dodge") +
  xlab("Antibiotic Drug Class")+ylab("Mean Prescriptions per 100,000 Population")+
  scale_fill_discrete(name="Year", labels=c("2017-2019 Average","2020"))+
  ggtitle(("Mean Prescriptions per 100,000 Population by Class for 2017-2020"))+
  scale_y_continuous(breaks = seq(0, 30000, by = 5000), labels=comma)+
  coord_flip()+theme_bw()+theme(plot.title=element_text(hjust=0.5))

bargraph2=ggplot(Agemeans, aes(x = age_group, y = trx_per100k, group=trx_per100k,fill = year))+
  geom_bar(stat = "identity", width = 0.5, position="dodge") +
  xlab("Age Group (Years)")+ylab("Mean Prescriptions per 100,000 Population")+
  scale_fill_discrete(name="Year", labels=c("2017-2019 Average","2020"))+
  scale_y_continuous(breaks = seq(0, 120000, by = 20000), labels=comma)+
  ggtitle(("Mean Prescriptions per 100,000 Population by Age for 2017-2020"))+
  coord_flip()+theme_bw()+theme(plot.title=element_text(hjust=0.5))

cowplot::plot_grid(bargraph,bargraph2, nrow=2,labels="AUTO")
dev.off()




