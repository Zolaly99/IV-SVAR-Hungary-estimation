library(readxl)
library(openxlsx)
library(dplyr)
library(tsbox)
library(data.table)
library(lubridate)
library(tidyr)
library(ggplot2)
library(stringr)
library(fpp)
library(purrr)


#A magyar monetáris transzmisszió mérése IV-SVAR-ral, adatbeolvasás és -átalakítás

directory = 'C:/Users/MSI laptop/Desktop/IV-SVAR/'  #Insert your directory where IV-SVAR_data.xlsx is found between quotes in such a format: "C:/Users/MSI laptop/Desktop/IV-SVAR/"

#1. Referenciahozamok (állampapír)
#Forrás: https://www.akk.hu/statisztika/hozamok-indexek-forgalmi-adatok/referenciahozamok



df_2002_0 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2002_1")
df_2002 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2002_2")
df_2003 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2003")
df_2004 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2004")
df_2005 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2005")
df_2006 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2006")
df_2007 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2007")
df_2008 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2008")
df_2009 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2009")
df_2010 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2010")
df_2011 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2011")
df_2012 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2012")
df_2013 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2013")
df_2014 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2014")
df_2015 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2015")
df_2016 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2016")
df_2017 <-read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2017")
df_2018 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2018")
df_2019 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2019")
df_2020 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2020")
df_2021 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2021")
df_2022 <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "Refhozam_2022")

#Kamatdöntési napok. Forrás: az MNB által közzétett ülésrendek. Pl: https://www.mnb.hu/sajtoszoba/sajtokozlemenyek/2021-evi-sajtokozlemenyek/a-monetaris-tanacs-2022-evi-ulesrendje

FOMC_days <- c("2002-01-07", "2002-01-21", "2002-02-04", "2002-02-18", "2002-03-04", "2002-03-18", "2002-04-08", 
               "2002-04-22", "2002-05-06", "2002-06-10", "2002-06-24", "2002-07-08", "2002-08-05", "2002-09-09", "2002-10-14",
               "2002-11-11", "2002-12-02", "2002-07-29", "2002-08-26",
               "2002-09-23", "2002-10-28", "2002-11-25", "2002-12-16", "2003-01-13", "2003-02-10", "2003-03-10", "2003-04-07", 
               "2003-05-12", "2003-06-10", "2003-07-07", "2003-08-04", "2003-09-01", "2003-10-06", "2003-11-03", "2003-12-01",
               "2003-01-27", "2003-02-24", "2003-03-24", "2003-04-28", "2003-05-26", "2003-06-23", "2003-07-21", "2003-08-18", 
               "2003-09-22", "2003-10-20", "2003-11-17", "2003-12-15", "2004-01-05", "2004-02-09", "2004-03-01", "2004-04-05",
               "2004-05-03", "2004-06-07", "2004-07-05", "2004-01-19", "2004-02-23", "2004-03-22", "2004-04-19", "2004-05-17",
               "2004-06-21", "2004-07-19", "2004-08-16", "2004-09-20", "2004-10-18", "2004-11-22", "2004-12-20", "2005-01-24",
               "2005-02-21", "2005-03-29", "2005-04-25", "2005-05-23", "2005-06-20", "2005-07-18", "2005-08-22", "2005-09-19",
               "2005-10-24", "2005-11-28", "2005-12-19", "2006-01-23", "2006-02-27", "2006-03-20", "2006-04-24", "2006-05-22", 
               "2006-06-19", "2006-07-24", "2006-08-28", "2006-09-25", "2006-10-24", "2006-11-20", "2006-12-18", "2007-01-22",
               "2007-02-26", "2007-03-26", "2007-04-23", "2007-05-21", "2007-06-25", "2007-07-23", "2007-08-27", "2007-09-24",
               "2007-10-29", "2007-11-26", "2007-12-17", "2008-01-21", "2008-02-25", "2008-03-31", "2008-04-28", "2008-05-26",
               "2008-06-23", "2008-07-21", "2008-08-25", "2008-09-29", "2008-10-20", "2008-11-24", "2008-12-22", "2009-01-19",
               "2009-02-23", "2009-03-23", "2009-04-20", "2009-05-25", "2009-06-22", "2009-07-27", "2009-08-24", "2009-09-28", 
               "2009-10-19", "2009-11-23", "2009-12-21", "2010-01-25", "2010-02-22", "2010-03-29", "2010-04-26", "2010-05-31",
               "2010-06-21", "2010-07-19", "2010-08-23", "2010-09-27", "2010-10-25", "2010-11-29", "2010-12-20", "2011-01-24",
               "2011-02-21", "2011-03-28", "2011-04-18", "2011-05-16", "2011-06-20", "2011-07-26", "2011-08-23", "2011-09-20", 
               "2011-10-25", "2011-11-29", "2011-12-20", "2012-01-24", "2012-02-28", "2012-03-27", "2012-04-24", "2012-05-29",
               "2012-06-26", "2012-07-24", "2012-08-28", "2012-09-25", "2012-10-30", "2012-11-27", "2012-12-18", "2013-01-29",
               "2013-02-26", "2013-03-26", "2013-04-23", "2013-05-28", "2013-06-25", "2013-07-23", "2013-08-27", "2013-09-24",
               "2013-10-29", "2013-11-26", "2013-12-17", "2014-01-21", "2014-02-18", "2014-03-25", "2014-04-29", "2014-05-27",
               "2014-06-24", "2014-07-22", "2014-08-26", "2014-09-23", "2014-10-28", "2014-11-25", "2014-12-16", "2015-01-27", 
               "2015-02-24", "2015-03-24", "2015-04-21", "2015-05-26", "2015-06-23", "2015-07-21", "2015-08-25", "2015-09-22", 
               "2015-10-20", "2015-11-17", "2015-12-15", "2016-01-26", "2016-02-23", "2016-03-22", "2016-04-26", "2016-05-24",
               "2016-06-21", "2016-07-26", "2016-08-23", "2016-09-20", "2016-10-25", "2016-11-22", "2016-12-20", "2017-01-24",
               "2017-02-28", "2017-03-28", "2017-04-25", "2017-05-23", "2017-06-20", "2017-07-18", "2017-08-22", "2017-09-19", 
               "2017-10-24", "2017-11-21", "2017-12-19", "2018-01-30", "2018-02-27", "2018-03-27", "2018-04-24", "2018-05-22",
               "2018-06-19", "2018-07-24", "2018-08-21", "2018-09-18", "2018-10-16", "2018-11-20", "2018-12-18", "2019-01-29",
               "2019-02-26", "2019-03-26", "2019-04-30", "2019-05-28", "2019-06-25", "2019-07-23", "2019-08-27", "2019-09-24", 
               "2019-10-22", "2019-11-19", "2019-12-17", "2020-01-28", "2020-02-25", "2020-03-24", "2020-04-28", "2020-05-26",
               "2020-06-23", "2020-07-21", "2020-08-25", "2020-09-22", "2020-10-20", "2020-11-17", "2020-12-15", "2021-01-26", 
               "2021-02-23", "2021-03-23", "2021-04-27", "2021-05-25", "2021-06-22", "2021-07-27", "2021-08-24", "2021-09-21",
               "2021-10-19", "2021-11-16", "2021-12-14", "2022-01-25", "2022-02-22", "2022-03-22", "2022-04-26", "2022-05-31",
               "2022-06-28", "2022-07-26", "2022-08-30", "2022-09-27", "2022-10-25")


#Referenciahozamok összefuzése, adattranszformációk
df <- rbind(df_2002_0, df_2002, df_2003, df_2004, df_2005, df_2006, df_2007, df_2008, df_2009, df_2010,
            df_2011, df_2012, df_2013, df_2014, df_2015, df_2016, df_2017, df_2018, df_2019, df_2020, df_2021, df_2022) %>%
  
  mutate("Day_of_the_week"= (wday(.$Dátum)-1),
         "FOMC"           = (as.character(.$Dátum) %in% FOMC_days %>% as.integer() %>% lag(., n=1) %>% replace(.,is.na(.),0)), #FOMC kreálása: azon napok kijelölése, amikor volt monpol döntés. A lag amiatt kell, mert a VAR-ban levo adott napi kötvényhozamok változásai (Változás), amelyekbol képezzük az instrumentumot, 13.45 és 14.00 közötti értékeket képviselnek, amelyek az adott napi kamatdöntések elotti értékek. Így a "Változás" változó azon értékeit kell venni majd, amelyek a kamatdöntési naphoz kötodnek. Ezt úgy oldom meg ehelyett, hogy az FOMC-napot csúsztatom el 1-gyel.
         "Days_in_month"=days_in_month(.$Dátum),
         "Days_of_the_month" = (.$Dátum %>% substr(9,10) %>% str_remove(., "^0+") %>% as.double()),
         "YearMonth" = substr(.$Dátum, 1, 7),   
         "YEAR" = substr(.$Dátum, 1, 4),
         "MONTH" = substr(.$Dátum, 6, 7) %>% str_remove(., "^0+")) %>%
  
  group_by(Futamido, YearMonth) %>%
  
  mutate("Hozam" = mean(`Hozam (%)`), 
         "Instrument" = sum(Változás[FOMC=="1"])) %>%   #Instrumentum kiszámolása: adott hónap és futamido szerint a "Változás" változó azon értékeinek összege, amelyek kamatdönto napok hatását tükrözik
  
  select(-`Értéknap`, -`ISIN kód`, -`Rövid név`, -Lejárat,                
         -`Felhalmozott kamat (%)`,
         -`Átlag vételi hozam (%)`, -`Átlag eladási hozam (%)`,
         -`Day_of_the_week`, -`Változás`, -`Nettó árfolyam (%)`,
         -'Hozam (%)', -FOMC, -Dátum, -Days_in_month,
         -Days_of_the_month, -YearMonth) %>%
  
  unique() %>% 
  
  select(YEAR, MONTH, Hozam, Instrument) %>% 
  
  pivot_wider(names_from = Futamido, values_from = c("Hozam", "Instrument")) %>%
  
  ungroup() %>%
  
  select(-YearMonth, -`Hozam_5 év`, -`Hozam_10 év`,
         -`Hozam_15 év`, -`Hozam_20 év`, -`Instrument_5 év`, -`Instrument_10 év`,
         -`Instrument_15 év`, -`Instrument_20 év`)

#2. Monthly CPI. Bázis: 2015. 10. hó
#Forrás: https://fred.stlouisfed.org/series/HUNCPIALLMINMEI

#Beolvasás
df_cpi <- read_excel("C:/Users/MSI laptop/Desktop/IV-SVAR/IV-SVAR_data.xlsx", sheet = "CPI") %>% 
  
  slice(-1:-10) %>%
  
  rename("Dátum" = `FRED Graph Observations`,
         "CPI" = `...2`) %>%
  
  mutate("MONTH" = .$Dátum %>% as.numeric() %>% as.Date(., origin = "1899-12-30") %>% substr(., 6, 7) %>% str_remove(., "^0+"),
         "YEAR"  = .$Dátum %>% as.numeric() %>% as.Date(., origin = "1899-12-30") %>% substr(., 1, 4),
         "LCPI" = 100*log(as.numeric(.$`CPI`))) %>%
  
  select(-Dátum, -CPI)


#3. Nomináleffektív árfolyam - bázis: 2000. Átrakás 2015-ös bázisra: leosztottam a NEER-t a 2015. 10. havi értékkel = 1.16798).
#Forrás: https://statisztika.mnb.hu/publikacios-temak/arak_-arfolyamok/arfolyamok/arfolyamstatisztikak

#3.1. Adatok betöltése
df_neer <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "NEER") %>% 
  
  slice(-1:-127) %>% 
  
  select(c(2,6)) %>% 
  
  na.omit() %>% 
  
  rename("Hónap"=...2,
         "NEER"=...6) %>%
  
  mutate("NEER" = 100*log(as.numeric(NEER))/1.16798, #Ezzel az osztással átrakom 2015-ös bázisra (hogy konzisztens legyen a CPI bázisával), és logaritmizálom
         "YEAR" = substr(.$Hónap, 1, 4),
         "MONTH" = substr(.$Hónap, 6, 7) %>% str_remove(., "^0+")) %>%
  
  select(-Hónap) 

#4. Ipari termelés (szezonálisan kiigazított)
#Forrás: https://fred.stlouisfed.org/series/HUNPROINDMISMEI

#Beolvasás, 2000 elotti adatok kitörlése
ind_prod <- read.xlsx(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "IP", detectDates = TRUE) %>% 
  
  tibble() %>% 
  
  slice(-1:-188) %>%
  
  rename("Hónap" = `FRED.Graph.Observations`, "Ipari_termelés"=X2) %>% 
  
  mutate("LIP"=100*log(as.numeric(.$Ipari_termelés))) %>% 
  
  mutate("YEAR" = substr(.$Hónap, 1, 4),
         "MONTH" = substr(.$Hónap, 6, 7) %>% str_remove(., "^0+")) %>%
  
  select(-Ipari_termelés, -Hónap) 


#5. FRA


fra <- read_excel(paste0(directory, "IV-SVAR_data.xlsx"), sheet = "FRA") %>% 
  
  slice(-1:-618) %>% 
  
  select(1, 51:59) %>% 
  
  rename("Dátum"=...1) %>%
  
  mutate("fra_1" = na.locf(fra_1),
         "FOMC" = (as.character(Dátum) %in% FOMC_days %>% as.integer()),
         "Változás" = (fra_1 - lag(fra_1)) %>% replace(., is.na(.), 0),
         "YearMonth" = substr(.$Dátum, 1, 7)) %>%
  
  group_by(`YearMonth`) %>% 
  
  mutate("FF4" = sum(Változás[FOMC==1]),
         "YEAR" = substr(YearMonth, 1, 4),
         "MONTH" = substr(YearMonth, 6, 7) %>% str_remove(., "^0+")) %>% 
  
  ungroup() %>% slice(-1:-11) %>% select(YEAR, MONTH, FF4) %>% unique()


#5. Táblák összefuzése
df_final <- df %>% 
  inner_join(ind_prod, by = c("YEAR", "MONTH")) %>% 
  inner_join(df_neer, by = c("YEAR", "MONTH")) %>% 
  inner_join(df_cpi, by = c("YEAR", "MONTH")) %>%
  left_join(fra, by = c("YEAR", "MONTH")) %>%
  rename("GS3M" = `Hozam_3 hónap`, "GS6M" = `Hozam_6 hónap`, "GS1" = `Hozam_12 hónap`,
         "GS3" = `Hozam_3 év`, "INST_3M"=`Instrument_3 hónap`, "INST_6M" = `Instrument_6 hónap`,
         "INST_12M" = `Instrument_12 hónap`, "INST_3Y" = `Instrument_3 év`)



#Végso adatbázisok létrehozása
DATASET_VAR <- df_final %>% select(YEAR, MONTH, LIP, LCPI, NEER, GS3M, GS6M, GS1, GS3) %>% map_df(., as.double)
DATASET_FACTORS <- df_final %>% select(YEAR, MONTH, INST_3M, INST_6M, INST_12M, INST_3Y, FF4) %>% map_df(., as.double) %>% replace(.,is.na(.),0)


write.csv(DATASET_VAR, paste0(directory, "DATASET_VAR_TDK.csv"), row.names=FALSE)
write.csv(DATASET_FACTORS, paste0(directory, "DATASET_FACTORS_TDK.csv"), row.names=FALSE)
