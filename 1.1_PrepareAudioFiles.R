library(tidyverse)
library(signglossR)
library(rPraat)
library(soundgen)
library(warbleR)

#if you fail to install signglossR from the Packages function, do it by clicking the following line
devtools::install_github("borstell/signglossR")

install.packages("remotes")  # Install or update the 'remotes' package
install.packages("devtools") # Install or update the 'devtools' package
update.packages(ask = FALSE)  # Update all packages


#get duration of files
allaudiofiles <- warbleR::duration_sound_files(path = 'D:/HEART OF THE STORM/audio')

write.csv(allaudiofiles, 'allaudiofiles.csv', row.names = F)








