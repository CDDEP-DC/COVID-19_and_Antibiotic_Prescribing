# COVID-19 and Antibiotic Prescribing
# Generate Supplementary Figures
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

cov_trx=read_csv("[Main file path]/Data/IQVIA_2017_2020_byCounty_forFigures_v3_trx.csv")
cov_trx1=cov_trx[,c("trx2020_per100k","cases_per100k")]

#remove observations with zeros
row_zero = apply(cov_trx1, 1, function(row) all(row >=1))
cov_trx2=cov_trx1[row_zero,]
cov_trx2=na.omit(cov_trx2)

cov_trx2$lg_cases=log(cov_trx2$cases_per100k)
cov_trx2$lg_trx2020=log(cov_trx2$trx2020_per100k)

#scatterplot of cases vs ddd
ggplot(cov_trx,aes(x=cases_per100k, y=trx2020_per100k))+
  geom_point() + 
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)

library('ggpubr')
# scatter plot of log cases and log ddd
ggplot(cov_trx2,aes(x=lg_cases, y=lg_trx2020))+
  geom_point() + stat_cor(method = "pearson")+scale_color_manual(values = "orange")+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)+
  xlab("Cases per 100,000 Population(log)")+ylab("Prescriptions per 100,000 Population(log)")+
  ggtitle(("Prescriptions vs COVID-19 Cases per 100,000 Population in 2020"))+theme(plot.title=element_text(hjust=0.5))

ggplot(cov_trx2,aes(x=cases_per100k, y=lg_trx2020))+
  geom_point() + 
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)

trx_avg=aggregate(x=cov_trx$ddd2020_per100k, by=list(cov_trx$fips, cov_trx$month),FUN=mean)
trx_avg=aggregate(x=cov_trx$ddd2020_per100k, by=list(cov_trx$fips),FUN=mean)

colnames(trx_avg)[1]="fips"
colnames(trx_avg)[2]="trx2020_mean"

trx_avg$avg_cat=as.factor(ifelse(trx_avg$trx2020_mean<5000, "<5000",
                                 ifelse(trx_avg$trx2020_mean>=5000 & trx_avg$trx2020_mean<10000, "5000-10000",
                                        ifelse(trx_avg$trx2020_mean>=10000 & trx_avg$trx2020_mean<20000, "10000-20000",
                                               ifelse(trx_avg$trx2020_mean>=20000 & trx_avg$trx2020_mean<30000, "20000-30000",
                                                      ifelse(trx_avg$trx2020_mean>=30000 & trx_avg$trx2020_mean<40000, "30000-40000",
                                                             ifelse(trx_avg$trx2020_mean>=40000 & trx_avg$trx2020_mean<50000, "40000-50000",
                                                                    ifelse(trx_avg$trx2020_mean>=50000 & trx_avg$trx2020_mean<60000, "50000-60000", 
                                                                           ifelse(trx_avg$trx2020_mean>=60000 & trx_avg$trx2020_mean<70000, "60000-70000",
                                                                                  ifelse(trx_avg$trx2020_mean>=70000 & trx_avg$trx2020_mean<80000, "70000-80000",    
                                                                                         ifelse(trx_avg$trx2020_mean>=80000 & trx_avg$trx2020_mean<90000, "80000-90000",">90000")))))))))))


##########Average############
county_map=us_map("counties")
trx_avg$fips=str_pad(trx_avg$fips, 5, pad = "0") 
county_full= left_join(county_map, trx_avg, by="fips")

setdiff(county_map$fips,trx_avg$fips)

county_full=unique(county_full, by="fips")
county_full=na.omit(county_full)

ggplot(data = county_full,
       mapping = aes(x = x, y = y,
                     fill = avg_cat, 
                     group = group))+
  geom_polygon(color = "gray90", size = 0.05)+coord_equal()+
  labs(fill = "Mean Prescriptions ") +
  guides(fill = guide_legend(nrow = 2)) + 
  theme_map() + theme(legend.position = "bottom")+
  scale_fill_brewer(palette="PuOr",
                    labels = c("<5,000", "5,000-10,000", "10,000-20,000",
                               "20,000-30,000", "30,000-40,000", "40,000-50,000","50,000-60,000","60,000-70,000","70,000-80,000","80,000-90,000",">90,000"))+
  ggtitle("Mean Antibiotics Prescribed by County")+theme(plot.title=element_text(hjust=0.5))

#########################Mean DDD Distribution###########################
trxs_per_100k <- cov_trx$ddd2020_per100k
hist(trxs_per_100k, main="Distribution of Prescriptions per 100k in 2020",xlim = c(0,9e+05), breaks=c(seq(5,1100000,5000)))

ggplot(trx_avg, aes(x=trx2020_mean, fill=..count..))+theme_bw()+
  geom_histogram(binwidth=10000)+ylab("Frequency")+xlab("Mean Prescriptions per 100,000 Population")+
  scale_fill_gradient("Frequency",low = "orange",high = "brown")+
  scale_x_continuous(breaks = seq(0, 700000, by = 50000), labels=comma)+
  ggtitle("Mean Antibiotics Prescribed in 2020")+theme(plot.title=element_text(hjust=0.5))

