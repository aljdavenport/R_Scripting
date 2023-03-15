library(neon)
library(tidyverse)

#Previously pulled data, template nameset ----
allrecords <- readRDS("test.rds")


template_names <- c("event_id", "form",
                    "Entering Date", "Entering Time",
                    "Entering Course", "4 Digit Course Number",
                    "Entering Comments",
                    "Leaving Date", "Leaving Time", "Reason for leaving course",
                    "Next Location", "Leaving Comments",
                    "OOC Leaving Date", "OOC Reason for leaving course",
                    "OOC Leaving Comments")



# Sync (what's new dog?) For first pull, comment out last_sync_time ----
dfsync <- NULL
dfsync <- pull_smartabase(
  type = "synchronise",
  form = "[SW] Admin - Course Tracking [2.0]",
  last_sync_time = dfsync$last_sync_time
)
saveRDS(dfsync, "sync.rds")
dfsync <- readRDS("sync.rds")

# Formatting of stored data + most recent data pull. ----
#OUTPUT: 2 dataframes, existingRecords and newRecords, formatted for Prod_Course_Tracking.

# formats existing records; selects columns for production, renames for production.
existingRecords <- NULL
existingRecords <- allrecords$new_data %>%
  select_if(names(.) %in% template_names) %>%
  rename(Original_Event_ID = event_id, Original_Form = form,
Entering_Date = `Entering Date`, Entering_Time = `Entering Time`,
Entering_Course = `Entering Course`, Entering_Course_Number = `4 Digit Course Number`,
Entering_Comments = `Entering Comments`,
Leaving_Date = `Leaving Date`, Leaving_Time = `Leaving Time`, Leaving_Reason = `Reason for leaving course`,
Next_Location = `Next Location`, Leaving_Comments = `Leaving Comments`,
OOC_Leaving_Date = `OOC Leaving Date`, OOC_Leaving_Reason = `OOC Reason for leaving course`,
OOC_Leaving_Comments = `OOC Leaving Comments`)


# formats new records; selects columns for production, renames for production.
syncSelect <- dfsync$new_data %>%
  select_if(names(.) %in% template_names)

#Template used to account for dropped columns during sync, if any.
#Update number of columns here if amount pulled ever changes.
newRecords <- data.frame(matrix(ncol = 15, nrow = 1))
colnames(newRecords) <- template_names

#binds new records into "newRecords" template, removes NA row, renames.
newRecords <- newRecords %>% bind_rows(syncSelect)
syncSelect <- NULL
newRecords = newRecords %>%
  filter(if_any(everything(), ~!is.na(.))) %>%
  rename(Original_Event_ID = event_id, Original_Form = form,
         Entering_Date = `Entering Date`, Entering_Time = `Entering Time`,
         Entering_Course = `Entering Course`, Entering_Course_Number = `4 Digit Course Number`,
         Entering_Comments = `Entering Comments`,
         Leaving_Date = `Leaving Date`, Leaving_Time = `Leaving Time`, Leaving_Reason = `Reason for leaving course`,
         Next_Location = `Next Location`, Leaving_Comments = `Leaving Comments`,
         OOC_Leaving_Date = `OOC Leaving Date`, OOC_Leaving_Reason = `OOC Reason for leaving course`,
         OOC_Leaving_Comments = `OOC Leaving Comments`)

#Data Validation ----

# - 4 Digit Course # Validation


#Push validated data to production----




#Push flagged data to "TBD Flagged data form"----
# - Check into emailing users/providers




# Testing stuff ----
duplicate_check <- existingRecords %>%
  filter(Original_Event_ID == newRecords$Original_Event_ID)

# Exclude courses that we may not have had complete oversight over. 
# 


