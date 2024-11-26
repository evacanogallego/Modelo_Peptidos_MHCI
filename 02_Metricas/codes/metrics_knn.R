# Cleaning ---------------------------------------
rm(list = ls())
cat("\014")
gc()

# Libraries ---------------------------------------
library(dplyr)
library(data.table)

# Arguments ----------------------------------------
# path <- "~/Desktop/Proyectos_ML"
# proj <- "Modelo_Peptidos_MHCI"
# algorithm <- "knn"

args <- commandArgs(trailingOnly = TRUE)
args_list <- list()
for (arg in args) {
  key_value <- strsplit(arg, "=")[[1]]
  key <- key_value[1]
  value <- key_value[2]
  value <- gsub("'", "", value)
  args_list[[key]] <- value
}

list2env(args_list, envir = .GlobalEnv)
print(args_list)


# Functions ----------------------------------------
functions <- list.files(file.path(path, "functions"), full.names = T)
lapply(functions, source)

# Paths --------------------------------------------
pathProj <- file.path(path, proj)
pathData <- file.path(pathProj, "01_Modelos/knn/output")
pathTmp <- file.path(pathProj, "tmp")
pathOutput <- file.path(pathProj, "02_Metricas/output", algorithm)
pathDataModel <- file.path(pathProj, "01_Modelos/00_datos")

dir.create(pathOutput, recursive = T, showWarnings = F)

# Code ---------------------------------------------
predicciones <- readRDS(file.path(pathData, "scores_model_output.rds"))
master <- readRDS(file.path(pathTmp, "master.rds"))
test <- readRDS(file.path(pathDataModel, "test_input_modelo.rds"))
target <- test$target

metrics <- data.frame(rbindlist(apply(predicciones[,!names(predicciones) %in% "id"], 2, function(x) metricsBinnaryPred(target, x))))
metrics <- round(metrics, 3)
metrics$model <- names(predicciones[,!names(predicciones) %in% "id"])
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

# Saving ---------------------------------------
saveRDS(metrics, file.path(pathOutput, "metrics_kpis.rds"))
write.csv2(metrics, file.path(pathOutput, "metrics_kpis.csv"), row.names = F)

saveRDS(metrics_ordenado, file.path(pathOutput, "metrics_kpis_ordenado.rds"))
write.csv2(metrics_ordenado, file.path(pathOutput, "metrics_kpis_ordenado.csv"), row.names = F)

# Cleaning ---------------------------------------
rm(list = ls())
cat("\014")
gc()