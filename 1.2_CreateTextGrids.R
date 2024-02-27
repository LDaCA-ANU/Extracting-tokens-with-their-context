library(tidyverse)
library(signglossR)
library(rPraat)
library(soundgen)
library(warbleR)
library(readtext)
library(lubridate)

dfsound <- read.csv('allaudiofiles.csv') %>%
  mutate(files = paste0('./data/audio', sound.files)) %>%
  mutate(name = basename(gsub('\\.wav', '', sound.files)))

fls <- data.frame(txts = list.files('D:/HEART OF THE STORM/txt', pattern = '.txt', full.names = T)) %>%
                  mutate(name = basename(gsub('\\.txt', '', txts)))

df <- dfsound %>%
  left_join(fls, by = 'name')

for (i in 1:nrow(df)) {
  print(paste0(i, '/', nrow(df), ':', df$name[i]))
  
  txtin <- data.frame(raw = unlist(strsplit(readtext::readtext(df$txts[i])$text, '\n'))) %>%
    separate(col = raw, sep = '\t', into = c('speaker', 'rawtime', 'text')) %>%
    mutate(start_secs = period_to_seconds(hms(rawtime))) %>%
    mutate(end_secs = c(start_secs[2:n()], df$duration[i])) %>%
    mutate(speakerid = paste0('speaker', speaker))
  
  # create textgrid
  tg <- rPraat::tg.createNewTextGrid(tMin = 0, tMax = df$duration[i])
  
  ind_speakers <- sort(unique(txtin$speakerid))
  
  cntr <- 1
  for (speakeri in ind_speakers) {
    tg <- rPraat::tg.insertNewIntervalTier(tg = tg, newInd = cntr, newTierName = speakeri)
    
    dfspeaker <- txtin %>%
      filter(speakerid == speakeri)
    
    # Sort intervals by start time
    dfspeaker <- dfspeaker[order(dfspeaker$start_secs), ]
    
    for (intervali in 1:nrow(dfspeaker)) {
      tStart <- dfspeaker$start_secs[intervali]
      tEnd <- dfspeaker$end_secs[intervali]
      
      # Check if tStart is lower than tEnd
      if (tStart < tEnd) {
        # Get the previous interval's end time
        prevEnd <- ifelse(intervali > 1, dfspeaker$end_secs[intervali - 1], 0)
        
        # If tStart is before or equal to the previous interval's end time,
        # adjust tStart to be slightly greater
        if (tStart <= prevEnd) {
          tStart <- prevEnd + 0.001
        }
        
        tg <- rPraat::tg.insertInterval(tg = tg, tierInd = cntr,
                                        tStart = tStart, tEnd = tEnd,
                                        label = dfspeaker$text[intervali])
      }
    }
    
    cntr <- cntr + 1
  }
  
  rPraat::tg.write(tg = tg, fileNameTextGrid = paste0('D:/HEART OF THE STORM/output/', df$name[i], '.TextGrid'), format = 'text')
}
