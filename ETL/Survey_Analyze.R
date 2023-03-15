# Pulls encounters, combines into "Clean_Encounters"
#Packages: neon, tidyverse
source("OHWSEncounters.r")

#### Lists for grouping by base production ####
Established_Bases <-c("Beale", "Eglin", "Hill", "Moody", "Mountain Home", "Langley")
Established_Bases <- toupper(Established_Bases)

Partial_Bases <- c("Shaw", "Nellis", "Seymour-Johnson", "Tyndall", "Kadena", "Kunsan")
Partial_Bases <- toupper(Partial_Bases)

Recently_Partial_Bases <- c("Spangdhaiem", "Lakenheath", "Aviano", "Davis Monthan")
Recently_Partial_Bases <- toupper(Recently_Partial_Bases)

Poorly_Func_Bases <- c("Misawa", "Hickam", "Eielson", "Elmendorf", "Osan", "ELEMENDORF")
Poorly_Func_Bases <- toupper(Poorly_Func_Bases)




#### Encounter Data Below ####


# Encounter_Summary <- data.frame(`Provider Type` = c("PT", "ATC", "LMT"),
#                                 `Treatment Count`= factor(NA),
#                                 `Neck and Back Treatment Count` = factor(NA),
#                                  `Treatment Cost`= factor(NA),
#                                  ` Encounter Count` = factor(NA))


Base_Encounters <- Clean_Encounters


# Sorts the bases based on establishment status
Base_Encounters <- Base_Encounters %>%
  mutate(Establishment_Status = case_when(
    grepl(pattern = paste(Established_Bases,collapse="|"),x = `Encounter AFB`, ignore.case = TRUE) ~ "Established",
    grepl(pattern = paste(Partial_Bases,collapse="|"),x = `Encounter AFB`, ignore.case = TRUE) ~ "Partial",
    grepl(pattern = paste(Recently_Partial_Bases,collapse="|"),x = `Encounter AFB`, ignore.case = TRUE) ~ "Recently Partial",
    grepl(pattern = paste(Poorly_Func_Bases,collapse="|"),x = `Encounter AFB`, ignore.case = TRUE) ~ "Poorly Functioning",
    
    
    
    ))
    
write.csv(Base_Encounters, "Base_Encounters.csv")





Encounter_Count <- Clean_Encounters %>%
  count(`Provider Type`) #%>%
 # arrange(desc(`Provider Type`))



 Neck_Back_Encounters <- Clean_Encounters %>%
   filter(grepl("craniospinal",`Body Area Summary`, ignore.case = TRUE))
 
 
 
 
 
 NB_Encounter_Count <- Neck_Back_Encounters %>%
   count(`Provider Type`)
 
 
 
#### Survey Data Below ####
 
 
#initializes survey df and pulls it from csv
survey_results <- data.frame()
survey_results <- read.csv("OHWSsurvey.csv", header = TRUE)


#Pertinent survey questions
filtered_survey <- survey_results %>%
  select(Q1_5_TEXT, Q12, Q14, Q15_1, Q15_2, Q16_1, Q16_2, Q16_3, Q16_4, Q16_5, Q16_6, Q16_7, Q16_8,
         Q23_1, Q23_2, Q24_1, Q24_2, Q25_1, Q25_2, Q30, Q32, Q34_1, Q34_2, Q34_3, Q34_4, Q34_5,
         Q36_1, Q36_2, Q36_3, Q36_4, Q36_5, Q36_6, Q39_1, Q39_2, Q40_1, Q40_2, Q41_1, Q41_2, Q47, ajj)



Helmet_Categories <- c(
  "HGU-55/P, AN/AVS-9NVGs",
  "HGU-55/P, PNVGs(?!\\sStowed)",
  "HGU-55/P, PNVGs Stowed",
  "HGU-55/P, JHMCS \\(Day-with HMD\\)",
  "HGU-55/P JHMCS \\(Night-no HMD\\) 49/49 NVGs in Visor",
  "HGU-55/P JHMCS \\(Night-no HMD\\) PNVGs, Step-in Visor",
  "HGU-55/P HMIT \\(Day\\)",
  "HGU-55/P HMIT \\(Night\\)",
  "JSF Gen II(?!I)",
  "JSF Gen III",
  "Other \\(please specify\\)",
  "Sim Helmet")


HGU_Categories <- c("HGU-55/P,HGU-55/P",
                         "HGU-55/P$",
                         "HGU-55/P,JSF",
                         "HGU-55/P,Other")

sum( str_count(survey_results$Q17, "Sim Helmet"))



Helmet_Breakdown <- survey_results %>%
  filter(grepl(paste(Helmet_Categories,collapse="|"),Q17, ignore.case = TRUE))


Hg_Breakdown <- survey_results %>%
  filter(grepl(paste(HGU_Categories,collapse="|"),Q17, ignore.case = TRUE))


Helmet_Results <- survey_results %>%
  count(Q17)


