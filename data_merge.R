# =============================================================================
# Merge separate tables from FM Pro into a single data frame for analysis
# Created: 2019-09-20

# Tables read-in in data_import.R:
#   call_log
#   participant_scheduler
#   gift_card
#   moca
# =============================================================================

# Load packages & functions
source("make_posixct.R") # Used to convert dates to POSIXct
library(dplyr)

# =============================================================================
# Initial data wrangling
#   - Convert all variable names to snake case
#   - Convert timestamps to POSIXct class (combine like commands across data frames later)
# =============================================================================

# Convert all variable names to snake case
purrr::walk(
  # Grab the names of all data frames in the global envrironment
  .x = ls()[purrr::map_lgl(ls(), ~ is.data.frame(get(.)))],
  .f = function(x) {
    # Grab individual df from environment
    df <- get(x)
    # Grab the variables names
    var_names <- names(df)
    # Convert variable names to snake case
    var_names <- stringr::str_replace_all(var_names, '(\\B)([A-Z])', '_\\2')
    # Convert variable names to lower case
    var_names <- tolower(var_names)
    # Fix medstar_id
    var_names[var_names == "medstar_i_d"] <- "medstar_id"
    # assign back to the dataframe
    names(df) <- var_names
    # Replace df with new names in global environment
    assign(x, df, envir = .GlobalEnv)
  }
)


# Clean call_log
# -----------------------------------------------------------------------------
call_log <- call_log %>% 
  mutate(
    # Change classes
    x_created_timestamp  = make_posixct(x_created_timestamp),
    x_modified_timestamp = make_posixct(x_modified_timestamp),
    call_date            = as.Date(call_date, "%m/%d/%Y"),
    # Separate date and time
    created_date = as.Date(x_created_timestamp),
    created_time = hms::as_hms(x_created_timestamp),
    # Create a call time hour variable
    call_hour = lubridate::hour(created_time),
    # Fix call_date typos
    # If call_date is earlier than created_date, then set call_date equal to 
    # the date in x_created_timestamp.
    call_date = if_else(call_date < created_date, created_date, call_date),
    # If call_date or call_time are missing, use the record created timestamp
    call_date = if_else(is.na(call_date), created_date, call_date),
    call_time = if_else(is.na(call_time), created_time, call_time),
    # Add call day variable
    day = weekdays(call_date),
    day = forcats::fct_relevel(day, "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"),
    # Fill-in missing record month and year
    x_record_month = if_else(is.na(x_record_month), months(created_date), x_record_month),
    x_record_year  = if_else(is.na(x_record_year), lubridate::year(created_date), x_record_year)
  )

# Check call hours - because we sometimes have problems with this
call_hours_in_df <- sort(unique(call_log$call_hour))
call_hours_expected <- c(8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18)
if (!setequal(call_hours_in_df, call_hours_expected)) {
  stop(
    "There are unexpected call times in the call_log data. The following", 
    "times were expected: ", paste(call_hours_expected, collapse = ", "), 
    ". However, the following times appear in the data: ", 
    paste(call_hours_in_df, collapse = ", "), "."
  )
}

# Create a factor version of the call hour variable
call_log <- call_log %>% 
  mutate(call_hour_f = factor(call_hour, labels = c(
    "08-08:59", "09-09:59", "10-10:59", "11-11:59", "12-12:59", "13-13:59", 
    "14-14:59", "15-15:59", "16-16:59", "17-17:59", "18-18:59"
  )))

# Clean participant_scheduler
# -----------------------------------------------------------------------------
## Keep scheduled rows only
scheduled_ids <- participant_scheduler %>% 
  filter(!is.na(appointment_date))

## Keep only the information needed for merging with call log
scheduled_ids <- scheduled_ids %>% 
  select(x_created_timestamp, medstar_id) %>% 
  mutate(
    scheduled = 1L,
    # Change classes
    x_created_timestamp  = make_posixct(x_created_timestamp),
    # Separate date and time
    scheduled_date = as.Date(x_created_timestamp),
    scheduled_time = hms::as_hms(x_created_timestamp),
    # Create a call time hour variable
    scheduled_hour = lubridate::hour(scheduled_time),
    scheduled_hour_f = factor(
      scheduled_hour, 
      levels = c(10, 11, 12, 13, 14, 15),
      labels = c("10-10:59", "11-11:59", "12-12:59", "13-13:59", "14-14:59", "15-15:59")
    )
  ) %>% 
  select(-x_created_timestamp)


# Clean gift_card
# -----------------------------------------------------------------------------
## All we need at this point is the number of gift cards given out, i.e. rows
## in this data
n_completed <- nrow(gift_card)


# Clean moca
# -----------------------------------------------------------------------------
## Deidentify data for local storage
moca_deid <- moca %>% 
  select(phone_eligible_consent:phone_more_info)

## Save locally
readr::write_csv(moca_deid, "data/moca_deid.csv")


# Clean up
# -----------------------------------------------------------------------------
rm(make_posixct, participant_scheduler, gift_card, moca)
