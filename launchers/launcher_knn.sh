echo `date`
echo STARTING 

path="/Users/evacanogallego/Desktop/Proyectos_ML"
proj="Modelo_Peptidos_MHCI"
algorithm="knn"

pathProj=$path/$proj
pathCodes=$pathProj/00_codigos

cd ${pathProj}
echo "Executing create_data.R"
nohup R CMD BATCH "--args path='${path}' proj='${proj}'" ${pathCodes}/create_data.R &
echo "End create_data.R"

echo "Executing training_knn.R"
nohup R CMD BATCH "--args path='${path}' proj='${proj}'" ${pathCodes}/training_knn.R &
echo "End training_knn.R"