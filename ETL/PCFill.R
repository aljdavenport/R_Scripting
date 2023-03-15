library(neon)
library(tidyverse)
library(lubridate)

#---- Usage History ----
# Ran for PJ PC's 3/14/23 - Alec D
#---- Instructions ----
# Purpose: To populate calculation and summary records for progress checks. 
#
# Setup: Set the 3 PC smartflows to monitor the appropriate groups. 
#
# Process: Specify which PC form you would like to target
#          Adjust group to match what is being monitored by the smartflow
#          Run the script.
#          Remove smartflow groups** (While rework is going on.)
#          Repeat as needed for other PC forms. 

#---- Script ----

Timelist <- c("01:00 AM", "02:00 AM", "03:00 AM", "04:00 AM",
              "05:00 AM", "06:00 AM", "07:00 AM", "08:00 AM", "09:00 AM",
              "10:00 AM", "11:00 AM",
              "12:00 PM", "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM", 
              "05:00 PM", "06:00 PM", "07:00 PM", "08:00 PM", "09:00 PM",
              "10:00 PM", "11:00 PM", "00:00 AM")

# Reference as PCForm[1, 2 or 3]
PCForm <- c("[SW] Course Assessment - PJ and CRO Progress Checks [1.0]", 
            "[SW] Course Assessment - CCS Performance Check [2.0]",
            "[SW] Course Assessment - TACP Progress Check [3.0]"
            )

PCCalcForm <- c("[SW] Course Assessment - PJU Progress Check Calculations [2.0]")


PCSummaryForm <- c("GPSDSU Progress Check Summary")
# SB Pull
ProgressChecks <- pull_smartabase(PCForm[1], filter_user_key = 'group',
                                  filter_user_value = 'ALL SW Candidates',
                                  last = "4 months")


# Backup dataframe to csv file.
PCBackup <- ProgressChecks %>%
  mutate(OGstart_time = start_time) %>%
  mutate(OGend_time = end_time)
write.csv(PCBackup, "PJCROPCBackup.csv")

PCTimeUpdate2 <- PCTimeUpdate

#Update Times to match index
PCTimeUpdate <- ProgressChecks %>%
  mutate(start_time = Timelist[`One Day Index`]) %>%
  mutate(end_time = Timelist[`One Day Index`+1])

# SB Push (PC Form)
push_smartabase(df = PCTimeUpdate,
               form = PCForm[1],
                edit_event = TRUE)

# SB Push (PC Calc Form, PJU only)
n = 40
Split_PCs <- PCTimeUpdate %>% group_by(row_number() %/% n) %>% group_map(~ .x)

view(DF <- as.data.frame(Split_PCs[1]))

push_count = 1
list_length = length(Split_PCs)

while (push_count <= list_length) {
  print(push_count)
  DF <- as.data.frame(Split_PCs[push_count])
push_smartabase(DF,PCCalcForm[1])

push_count = push_count + 1
}

# SB Push (PC Summary Form)
push_smartabase(PCTimeUpdate,PCSummaryForm[1])




headcheck <- head(PCTimeUpdate, 1)




same_date_user <- ProgressChecks %>%
  filter(about == "RYAN DUSH")


findNA <- PCTimeUpdate %>%
  filter(is.na(end_time))

