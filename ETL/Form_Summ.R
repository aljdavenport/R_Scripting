library(neon)
library(lubridate)
library(tidyverse)

# MOST RECENT SYNC: 7/15/22 #

# Summarizes encounter records from multiple sources, to be used with OHWS Provider DB
# Corresponding Dashboard: BETA SUMMARY FORM OHWS-PROVIDER USAGE 7/1/22

### Notes: ----
# Look into pulling provider type from DB when not given on record.
# Look into matching types of providers from Database form to LMT, PT, ATC, etc.
# Look into implementing sync function. Will require:
#   - TESTING with a small sync, don't crash the system.
#   - An initial run, can be done with current set up.
#   - Updating loop to account for "last_sync_time" for each form.

### Initialize vars and reads csv files ----

#formatted dates for sbpull


last_sync_date <- as.character(read.csv("last_sync_date.csv")[2][1])
today <- Sys.Date()
today <- format(today, format='%d/%m/%Y')


#list of forms and abbreviations for them, for naming their data frames.
Forms <- data.frame( `Form Name` = c("OHWS - PT/ATC Incidents and Encounters",
              "OHWS - LMT Incidents and Encounters",
              "BETA OHWS - PT/ATC Encounters",
              "OHWS - LMT Encounters",
              "OHWS - SC Encounters",
              "OHWS - Cognitive Specialist Encounters"),
              `Form Abbr` = c("OGPTATC", "OGLMT", "PTATC", "LMT", "SC", "CPS"))

provider_DB <- read.csv("ProviderLocationDB.csv") %>%
 select(Provider, DB.Provider.AFB)

last_sync_DF <- read.csv("synced_records.csv") %>%
  select( -X)

#SB Pull ----
counter = 1;
for( p in Forms$Form.Name){
tryCatch( {
Encounters <-pull_smartabase(
  p,
  type = "event",
  download_attachment = FALSE,
  start_date = last_sync_date,
  end_date = today,
  last = NULL,
  start_time = "00:00 AM",
  end_time = "11:59 PM",
  filter_user_key = NULL,
  filter_user_value = NULL,
  filter_data_key = NULL,
  filter_data_value = NULL,
  filter_data_condition = "equal_to",
  include_missing_users = FALSE,
  guess_col_type = TRUE,
  get_uuid = FALSE,
  cloud_mode = FALSE,
  last_sync_time = NULL,
  shiny_progress_code = NULL
)

assign(paste( Forms$Form.Abbr[counter], sep = ""), Encounters)

# counter <- counter + 1;
   }, error=function(e){cat("ERROR :", "no", "\n")})
  counter <- counter + 1;
}



### Select Fields, Combine DF's, remove erroneous records. ----

# OG LMT ----
Stripped_OGLMT <- OGLMT %>% select(form,`about`, user_id, `start_date`,`Treatment Date`,`Provider`,
                                   `Provider Type`,`Treatment Modalities`, 
                                   `Purpose`, `DB Treatment Count`,
                                   `DB Treatment Cost`, `Body Area Summary`,
                                   `Incident Type`, `DB Month Year`)

Stripped_OGLMT <- left_join(Stripped_OGLMT, provider_DB, 'Provider')

Stripped_OGLMT <- rename(Stripped_OGLMT, `Provider AFB` = `DB.Provider.AFB`, `Month Year` = `DB Month Year`,
                         `Treatment Count` = `DB Treatment Count`, `Treatment Cost` = `DB Treatment Cost`,
                         `Treatment_Date` = `Treatment Date`)


# OG PT / ATC----
Stripped_OGPTATC <- OGPTATC %>% select(form,`about`, user_id, `start_date`,`Treatment Date`,`Provider`,
                                       `Provider Type`,`Treatment Modalities`,
                                       `Purpose`, `DB Treatment Count`,
                                       `DB Treatment Cost`, `Body Area Summary`,
                                       `Incident Type`, `DB Month Year`)

Stripped_OGPTATC <- left_join(Stripped_OGPTATC, provider_DB, "Provider")

Stripped_OGPTATC <- rename(Stripped_OGPTATC, `Provider AFB` = `DB.Provider.AFB`, `Month Year` = `DB Month Year`,
                           `Treatment Count` = `DB Treatment Count`, `Treatment Cost` = `DB Treatment Cost`,
                           `Treatment_Date` = `Treatment Date`)

#LMT      ----
Stripped_LMT <- LMT %>% select(form,`about`, user_id, `start_date`,`Treatment Date`,`Provider`, `Created By`,
                                   R_Provider_Type,`Treatments:`,
                                   `Purpose`, `Treatment Count`,
                                   `Table Treatment Cost`, `Body Area Summary`,
                                   `Encounter Type`, `DB Month Year`) %>%
  drop_na(`Treatment Date`) %>%
  mutate(Provider = ifelse(is.na(Provider), `Created By`, Provider)) %>%
  select(- `Created By`)


Stripped_LMT <- left_join(Stripped_LMT, provider_DB, 'Provider')

Stripped_LMT <- rename(Stripped_LMT, `Provider AFB` = `DB.Provider.AFB`, `Month Year` = `DB Month Year`,
                          `Treatment Cost` = `Table Treatment Cost`,
                         `Treatment_Date` = `Treatment Date`, `Treatment Modalities` = `Treatments:`,
                         `Incident Type` = `Encounter Type`, `Provider Type` = `R_Provider_Type`)


# PT / ATC ----
#   Not in use yet.


# Cog Spec ----
Stripped_CPS <- CPS %>% select(form,`about`, user_id, `start_date`,`Encounter Date`,`Provider`, `Created By`,
                               R_Provider_Type,`Topics and Abilities Summary`,
                               `Purpose Text Summary`, `Treatment Count`,
                               `Encounter Type Text Summary`, `DB Month Year`)  %>%
  mutate(`Table Treatment Cost` = NA  ,  `Body Area Summary` = NA ) %>%
   drop_na(`Encounter Date`) %>%
   mutate(Provider = ifelse(is.na(Provider), `Created By`, Provider)) %>%
   select(- `Created By`)


Stripped_CPS <- left_join(Stripped_CPS, provider_DB, 'Provider')

Stripped_CPS <- rename(Stripped_CPS, `Provider AFB` = `DB.Provider.AFB`, `Month Year` = `DB Month Year`,
                       `Treatment Cost` = `Table Treatment Cost`,
                       `Treatment_Date` = `Encounter Date`, `Treatment Modalities` = `Topics and Abilities Summary`,
                       `Incident Type` = `Encounter Type Text Summary`, `Provider Type` = `R_Provider_Type`,
                       `Purpose` = `Purpose Text Summary`)

# SC       ----
Stripped_SC <- SC %>% select(form,`about`, user_id, `start_date`,`Session Date`,`Created By`,
                               R_Provider_Type,`Encounter Type Text Summary`,
                               `Purpose Text Summary`, `Training Program Count`,
                             `Body Area Summary`, `Training Program List`,
                               `Encounter Type Text Summary`, `DB Month Year`) %>%
  mutate(`Provider` = NA) %>%
   mutate(`Treatment Cost` = NA) %>%
  drop_na(`Session Date`) %>%
  mutate(Provider = ifelse(is.na(Provider), `Created By`, Provider)) %>%
  select(- `Created By`)



Stripped_SC <- left_join(Stripped_SC, provider_DB, 'Provider')

Stripped_SC <- rename(Stripped_SC, `Provider AFB` = `DB.Provider.AFB`, `Month Year` = `DB Month Year`,
                       `Treatment_Date` = `Session Date`, `Treatment Modalities` = `Training Program List`,
                       `Incident Type` = `Encounter Type Text Summary`, `Provider Type` = `R_Provider_Type`,
                      `Purpose` = `Purpose Text Summary`, `Treatment Count` = `Training Program Count`) 


# SC  BETA ----
#   Not in use yet.


# Combines entries. ----
## Fills down Inc type and Body area summary. Needed due to NA's in records w/ multiple rows.
### Removes table entries made in error, i.e. with no entered data.


Test_Accounts <- c("Test", "Program")
Clean_Encounters <- rbind(Stripped_OGLMT,Stripped_OGPTATC, Stripped_LMT, Stripped_CPS, Stripped_SC) %>%
  filter(!grepl(paste(Test_Accounts,collapse="|"),about, ignore.case = TRUE)) %>%
  drop_na(`Treatment_Date`) %>%  
  fill(`Incident Type`, `Body Area Summary`) %>%  
  mutate(across(c(`Treatment Modalities`, Purpose), ~gsub("\\]|\\[", "",.))) %>%
   select(- form, - `start_date`) %>%
  rename(Provider.Type = `Provider Type`, Treatment.Modalities = `Treatment Modalities`, Treatment.Count = `Treatment Count`,
         Treatment.Cost = `Treatment Cost`, Body.Area.Summary = `Body Area Summary`, Incident.Type = `Incident Type`, 
         Month.Year = `Month Year`, Provider.AFB = `Provider AFB`)
  



#Convert Encounter AFB to Uppercase
Clean_Encounters$`Provider.AFB` <- toupper(Clean_Encounters$`Provider.AFB`)

#Corrects Date Formatting
Clean_Encounters$`Treatment_Date` <-mdy(Clean_Encounters$`Treatment_Date`)
Clean_Encounters$Weekday <- weekdays(Clean_Encounters$Treatment_Date)
 Clean_Encounters$Treatment_Date <- format(Clean_Encounters$Treatment_Date, format='%d/%m/%Y')
 
#Prep for push ----
 
 

# view(DF <- as.data.frame(Split_Encounters[1]))


# Pushes dataframe into Smartabase ----
# Pulls in new entries, compared to the previous DF.
#Splits them into groups of > 500, and returns lenght of list for sbpush.
 
 
Diff_Entries = setdiff(Clean_Encounters, last_sync_DF)
n = 500 
Split_Encounters <- Diff_Entries %>% group_by(row_number() %/% n) %>% group_map(~ .x)
list_length <- length(Split_Encounters)
push_count = 1

while (push_count <= list_length) {
  print(push_count)
  DF <- as.data.frame(Split_Encounters[push_count])
push_smartabase(
  DF,
  "DEV_Encounter_Summary_Two",
  entered_by_user_id = NULL,
  type = "event",
  # get_id = TRUE,
  # match_id_to_column = "about",
  table_fields = NULL,
  start_date = 'Treatment_Date',
  end_date = 'Treatment_Date',
  current_date_format = "dmy",
  start_time = NULL,
  end_time = NULL,
  edit_event = FALSE,
  cloud_mode = FALSE,
  shiny_progress_code = NULL

)

push_count = push_count + 1
}

last_sync_DF <- rbind(Diff_Entries, last_sync_DF)
write.csv(last_sync_DF, "synced_records.csv")
write.csv(today, "last_sync_date.csv")
