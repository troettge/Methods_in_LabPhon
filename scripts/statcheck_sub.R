############
#
## Authors:  Mathias Stoeber (m . stober @ posteo . de)
#            Timo Roettger (timo . b . roettger @ gmail . com)
#
## Project: Assessing Methods in LabPhon
#
##          Statcheck
#
##          Scraps all articles from web, makes tidy, applies statcheck, and saves derived files
#
## Version: 02/10/2020

# libraries
library(rstudioapi)
library(tidyverse)

## Getting the path of your current open file
datapath = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(datapath))
setwd("../data/")

# Load processed data (OpenSesame (+ Mouse Tracking) + Eye Tracking)
data <- read_csv("statcheck_out.csv")

# subset only those articles that are flagged as errorneous
statcheck_sub <- data %>% 
  filter(Error == "TRUE")

# make new columns to fill
statcheck_sub$page <- "INSERT"
statcheck_sub$error_type <- "INSERT"

# calculate difference between reported and calculated p-value
statcheck_sub$difference <- statcheck_sub$Reported.P.Value - statcheck_sub$Computed

# is the reported p-value lower
statcheck_sub$p_better <- ifelse(statcheck_sub$difference < 0, 1, 0)

# check for possibly missed one-sided mistake, 
# i.e. is the p-value mismatch half the calculated one


# types of errors
# p = 0 <- "p = 0.000"
# "index mismatch" <- statcheck_sub$Reported.P.Value - statcheck_sub$Computed =! 0

pages <- c(22,
           )

type <- c("p = 0")

