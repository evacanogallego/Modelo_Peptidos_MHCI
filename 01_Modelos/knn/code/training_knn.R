# Cleaning ---------------------------------------
rm(list = ls())
cat("\014")
gc()

# Libraries ---------------------------------------
library(dplyr)
library(data.table)
library(caret)
library(class)
library(kknn)

# Arguments ----------------------------------------
path <- "~/Desktop/Proyectos_ML"
proj <- "Modelo_Peptidos_MHCI"

# Functions ----------------------------------------
functions <- list.files(file.path(path, "functions"), full.names = T)
lapply(functions, source)

# Paths --------------------------------------------
pathProj <- file.path(path, proj)
pathData <- file.path(pathProj, "01_Modelos/00_datos")
pathTmp <- file.path(pathProj, "tmp")
pathOutput <- file.path(pathProj, "01_Modelos/knn/output")

# Code ---------------------------------------------
train <- readRDS(file.path(pathData, "train_input_modelo.rds"))
test <- readRDS(file.path(pathData, "test_input_modelo.rds"))

# trainning knn models

knn_model <- train.kknn(train$target ~ ., data = train, kmax = 50)
print(knn_model) # the best k is 8, but we will try k from 1 to 20.

train_predictoras <- train %>% select(-target, -id)
test_predictoras <- test %>% select(-target, -id)

k_lista = 1:20
predicciones <- lapply(k_lista, function(k) {
  knn(train_predictoras, 
      test_predictoras, 
      cl = train$target, 
      k = k)
})


pred_df <- do.call(cbind, lapply(predicciones, as.data.frame))
names(pred_df) <- paste0("k_", k_lista)
pred_df$id = test$id
pred_df <- pred_df %>% select(id, everything())

# Saving output ------------------------------------------
saveRDS(pred_df, file.path(pathOutput, "scores_model_output.rds"))

# Cleaning ---------------------------------------
rm(list = ls())
cat("\014")
gc()

