
### check whether lubridate identifies the AEST and AEDT (local time)
library(lubridate)

# AEST (WINTER)
AUS_AEST_df = data.frame(Date_Time = c("20190501040000", "20190501050000")) %>% 
  mutate(Date_Time = ymd_hms(Date_Time, tz = "GMT"))  %>%
  mutate(Date_Time_Local = as_datetime(Date_Time, tz = "Australia/Sydney"))

# AUS_AEST_df
# Date_Time     Date_Time_Local
# 1 2019-05-01 04:00:00 2019-05-01 14:00:00
# 2 2019-05-01 05:00:00 2019-05-01 15:00:00

AUS_AEDT_df = data.frame(Date_Time = c("20191101040000", "20191101050000")) %>% 
  mutate(Date_Time = ymd_hms(Date_Time, tz = "GMT"))  %>%
  mutate(Date_Time_Local = as_datetime(Date_Time, tz = "Australia/Sydney"))

# > head(AUS_AEDT_df)
# Date_Time     Date_Time_Local
# 1 2019-11-01 04:00:00 2019-11-01 15:00:00
# 2 2019-11-01 05:00:00 2019-11-01 16:00:00
