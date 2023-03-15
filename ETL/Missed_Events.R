library(neon)
library(tidyverse)

today <- Sys.Date()
today <- format(today, format='%d/%m/%Y')

yesterday <- (Sys.Date()-1)
yesterday <- format(yesterday, format='%d/%m/%Y')

courses <- list("A Flight 2202", "B Flight 2202", "C Flight 2202")

print(toString(courses[1]))
for( p in courses){
  print(p)
  eventTracking <- pull_smartabase(
    
    "[SW] Admin - Event Tracking [2.0]",
    type = "event",
    start_date = "20/08/2021",
    end_date = "20/08/2021",
    username = NULL,
    password = NULL,
    last = NULL,
    start_time = "00:00 AM",
    end_time = "11:59 PM",
    filter_user_key = 'group',
    filter_user_value = p,
    filter_data_key = NULL,
    filter_data_value = NULL,
    filter_data_condition = "equal_to",
    include_missing_users = TRUE,
    guess_col_type = TRUE,
  )
  assign( paste(substring(p, 1, 1), "eventTracking", sep = ""), eventTracking)
  
}

Events <- unique(eventTracking$"Event Activity")
Events <- head(Events, -1)
Events <- toString(Events)

StartDate <- unique(eventTracking$start_date)
StartDate <- head(StartDate, -1)
StartDate <- toString(StartDate)

mdata <- eventTracking %>%
  select(get_metadata_names(.))

mEventList <- list(Events)
#Whoa
#wow
mdata$"Missed Events" <- toString(mEventList)
mdata$"Missed Events2" <- mdata$`Missed Events`
mdata$start_date <- StartDate

mdata <-   mdata %>%
  mutate(missing = replace_na(form, "Missing Data"))

musers <- mdata[mdata$missing == "Missing Data",] %>%
  select(about, user_id, missing, start_date, "Missed Events", "Missed Events2")


push_smartabase(
  musers,
  "Missed Events Accountability",
  entered_by_user_id = NULL,
  type = "event",
  get_id = TRUE,
  match_id_to_column = "about",
  table_fields = NULL,
  start_date = "start_date",
  end_date = "start_date",
  current_date_format = NULL,
  start_time = NULL,
  end_time = NULL,
  edit_event = FALSE,
  cloud_mode = FALSE,
  shiny_progress_code = NULL
  
)

sapply(mdata, class)
