# IV-SVAR-Hungary-estimation
This repo contains all the necessary files for reproducing the IV-SVAR estimates in the paper 
"A magyar monetáris transzmisszió mérése IV-SVAR-ral" (The estimation of the Hungarian 
monetary transmission using IV-SVAR). This includes the files as well as an RStudio 
code used for transforming the variables and the Matlab code required for the estimation.
For reproducing the results, first download the data IV-SVAR_data.xlsx, then run the R code
IV-SVAR_kód.R. The data transformation is contained in the R file. Running this code results
in DATASET_VAR_TDK.xlsx and DATASET_FACTORS_TDK.xlsx being saved into your directory. After 
this, open all the remaining Matlab files and put them in the same directory. You should first 
run the file "Import_DATA_TDK.m which transforms the previously mentioned two datasets into
DATASET_TDK.mat so as to be compatible with the main file VAR_main_TDK2.m. Then, run VAR_main_TDK2.m
with the desired parameters (the default setting is the final model in the study). 

If you wish to skip the data wrangling part and only wish to focus on the estimation, you only
have to import DATASET_TDK.mat, then run VAR_main_TDK2.m.
