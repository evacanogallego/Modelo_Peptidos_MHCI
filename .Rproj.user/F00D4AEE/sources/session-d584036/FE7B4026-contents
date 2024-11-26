# Cleaning ---------------------------------------
rm(list = ls())
cat("\014")
gc()

# Libraries ---------------------------------------
library(dplyr)
library(data.table)

# Arguments ----------------------------------------
path <- "~/Desktop/Proyectos_ML"
proj <- "Pec_1"

# Functions ----------------------------------------
functions <- list.files(file.path(path, "functions"), full.names = T)
lapply(functions, source)

# Paths --------------------------------------------
pathProj <- file.path(path, proj)
pathData <- file.path(pathProj, "01_Modelos/knn/output")
pathTmp <- file.path(pathProj, "tmp")
pathOutput <- file.path(pathProj, "02_Metricas/output")

# Code ---------------------------------------------
predicciones <- readRDS(file.path(pathData, "scores_model_output.rds"))
master <- readRDS(file.path(pathTmp, "master.rds"))

metrics <- data.frame(rbindlist(lapply(predicciones, function(x) metricsBinnaryPred(target, x))))
metrics <- round(metrics, 3)
metrics$model <- paste0("knn_k", k_lista)
metrics <- metrics %>% select(model, everything())

metrics_ordenado <- list()
for(metric in names(metrics)[2:ncol(metrics)]){
  print(metric)
  aux <- metrics[,c("model", metric)]
  aux <- aux[order(aux[,metric], decreasing = T),]
  aux_final <- data.frame(metric = aux$model)
  metrics_ordenado[[metric]] <- aux_final
}

metrics_ordenado <- do.call(cbind, metrics_ordenado)
names(metrics_ordenado) <- names(metrics)[2:ncol(metrics)]


