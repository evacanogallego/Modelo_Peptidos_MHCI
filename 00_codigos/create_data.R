# Cleaning ---------------------------------------
rm(list = ls())
cat("\014")
gc()

# Libraries ---------------------------------------
library(dplyr)
library(data.table)
library(stringr)
library(dummy)
library(tidyverse)
library(caret)
library(class)
library(kknn)

# Arguments ----------------------------------------
path <- "~/Desktop/Proyectos_ML"
proj <- "Modelo_Peptidos_MHCI"

# Functions ----------------------------------------

# Paths --------------------------------------------
pathProj <- file.path(path, proj)
pathData <- file.path(pathProj, "00_datos")
pathTmp <- file.path(pathProj, "tmp")
pathOutput <- file.path(pathProj, "01_Modelos/00_datos")

# Code ---------------------------------------------
datos <- fread(file.path(pathData, "peptidos.csv"), sep=";", data.table = F, stringsAsFactors = F)
blosum <- fread(file.path(pathData, "BLOSUM62_probabilities.csv"), sep=";", data.table = F, stringsAsFactors = F)

### transforming data to dummies

datos_tr <- datos %>%
  mutate(aa = str_split(sequence, "")) %>% # Dividir la cadena en caracteres
  unnest_wider(aa, names_sep = "_") 

columns <- grep("aa", names(datos_tr), value = T)
datos_dummies <- dummy(datos_tr[,columns])
datos_dummies <- cbind(datos[,c("sequence", "label")], datos_dummies)
datos_dummies$id <- 1:nrow(datos_dummies)

### creating target

datos_dummies <- datos_dummies %>% mutate(target = ifelse(label == "SB", 1, 0))
master <- datos_dummies %>% select(id, sequence, label, target)
saveRDS(master, file.path(pathTmp, "master.rds"))
datos_dummies$sequence=NULL
datos_dummies$label=NULL
datos_dummies <- datos_dummies %>% select(id, target, everything())

### splitting data into train-test

set.seed(123)

trainIndex <- createDataPartition(datos_dummies$id, p = 0.7, list = FALSE)
train <- datos_dummies[trainIndex, ]
test <- datos_dummies[-trainIndex, ]

table(train$target)
table(test$target)

# Saving train test data

saveRDS(train, file.path(pathOutput, "train_input_modelo.rds"))
saveRDS(test, file.path(pathOutput, "test_input_modelo.rds"))

# Cleaning ---------------------------------------
rm(list = ls())
cat("\014")
gc()
