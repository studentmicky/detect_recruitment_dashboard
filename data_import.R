# =============================================================================
# Read-in data from FM Pro DB
# Created: 2019-09-20
# 
# You must first connect to the UTHealth VPN
# =============================================================================

library(dplyr)

# Open the Connection to the FM database
# Keyring notes: https://db.rstudio.com/best-practices/managing-credentials/
# Keychain error: https://github.com/r-lib/keyring/issues/45#issuecomment-332491293
con <- DBI::dbConnect(
  odbc::odbc(),
  driver   = "/Library/ODBC/FileMaker ODBC.bundle/Contents/MacOS/FileMaker ODBC",
  server   = "spsqlapwv003.sph.uthouston.edu",
  database = "DETECT",
  uid      = keyring::key_list("detect_fm_db_readonly")[1,2],
  pwd      = keyring::key_get("detect_fm_db_readonly")
)

# Pull tables into R as data frames
call_log              <- DBI::dbReadTable(con, "ParticipantCallLog")
participant_scheduler <- DBI::dbReadTable(con, "ParticipantScheduler")
gift_card             <- DBI::dbReadTable(con, "GiftCard")
moca                  <- DBI::dbReadTable(con, "PhoneRecruitment")

# Close the connection to the database
DBI::dbDisconnect(con)
rm(con)

# NOTES on data 
# -----------------------------------------------------------------------------
# 2019-08-31 (From Sunil): 

# Originally Participant Call Log was not configured to be an exportable table, 
# since there was no research data coming out of there. So this table did not 
# include the following variables, NameFull, xRecordMonth, and xRecordYear (which 
# pulls in participant's full name and related record month and year respectively 
# from the Participant table).

# On or around 8/22/19 you had asked about including the phone call log in the 
# Analytics section. I ran a script that updated all records in the Calls Log 
# with the xRecordMonth and xRecordYear, which is the modification timestamp 
# showing 8/22/2019 at 11:17 AM.

# During the above change, I didn't pull in NameFull because of the way that 
# variable is configured, instead changed the code so that all future call 
# logs would pull in the name going forward. However, if you need the name I 
# can update this, not complicated to do. The modification timestamp would 
# update though with when I do this.

# 8/8/19 seems more likely to be a data entry error than a test case. The 
# record was created on 8/15/2019 by Jennifer (jtoro) and there are valid 
# records before and after with CallDate set to 8/15/2019. Also 8/8/19 is 
# right above 8/15/19 when using the drop-down calendar. It might make more 
# sense to change CallDate for that record from 8/8/19 to 8/15/19.
