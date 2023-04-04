
% TDK based on the code of Gertler & Karádi (2015)

clear all; close all; clc;
%Import and load time-series data
load DATASET_TDK;


nboot  = 1000;  % Number of Bootstrap Samples
clevel = 95;    % Bootstrap Percentile Shown
VAR.fontsize        =   14; %fontsize in figures

%Setting up possible specifications
smpl_min_VAR_vec    =   [2002 1];   
smpl_max_VAR_vec    =   [2016 5]; %End-of-sample (change for robustness exercises)  
monpol_vars_cell     =   {'GS6M'}; %Monetary policy variables (change for robustness exercises)  
monpol_vars_label_cell =  {'6 hónapos ráta'}; %Names of the monetary policy variables    
instrument = 'INST_3M'     %INST_3M or FF4;
VAR.irhor  = 72;                                        % Impulse Response Horizon
VAR.p      = 6;                                        % VAR lag length

smpl_min_factors_vec =   [ones(1,1)*[2002 7]];          %Starting date for all of the factors (2003 1)
smpl_max_factors_vec =   [ones(1,1)*[2016 5]];          %Finishing date for all of the factors (2022 6 / 2015 6)
figure_name         =     'ALL';


factors1_cell_GS1     =   {instrument};     
factors1_label_cell_GS1=   {instrument};
factors2_cell_GS1        =   {''};    
factors2_label_cell_GS1  =   {''};  
factors1_cell_GS3       =   {instrument};
factors1_label_cell_GS3   =  {instrument};
factors2_cell_GS3      =   {''};
factors2_label_cell_GS3    = {''};
factors1_cell_GS6M     =   {instrument};    
factors1_label_cell_GS6M=   {instrument};
factors2_cell_GS6M        =   {''};    
factors2_label_cell_GS6M  =   {''};
factors1_cell_GS3M     =   {instrument};     
factors1_label_cell_GS3M=   {instrument};
factors2_cell_GS3M        =   {''};    
factors2_label_cell_GS3M  =   {''};

extern_vars_cell    =    {'GS6M', 'GS1','GS3'};  %(FF needs to be the first)
extern_vars_label_cell   =   {'6-month rate', '1 year rate','3 year rate'};
extern_vars_smpl_min_vec =  [ones(4,1)*[2002 1]]; %a VAR datasetben a változók kezdő dátumai

%Number of...

no_monpol_vars      =   length(monpol_vars_cell);
no_extern_vars      =   length(extern_vars_cell);


ii=cell(no_monpol_vars,1);     %creates an array of empty matrices whose length is equal to the number of monpol variables 
        %Counting the figures       
        VAR.monpol_FF = 'no';
        ii{1} = 1;
        eval(['factors1_cell=factors1_cell_' monpol_vars_cell{1} ';']);                 
        eval(['factors2_cell=factors2_cell_' monpol_vars_cell{1} ';']);
        eval(['factors1_label_cell=factors1_label_cell_' monpol_vars_cell{1} ';']);
        eval(['factors2_label_cell=factors2_label_cell_' monpol_vars_cell{1} ';']);
        no_factors          =   length(factors1_cell);
        no_factors1         =   length(factors1_cell);
        no_factors2         =   length(factors2_cell);

                    
           
                    tic;
                    VAR.switch_extern   =    0;    %Switch off extended VAR for simple VARs
                    smpl_min_VAR = smpl_min_VAR_vec(1,:);

                    %factors sample starts minimum p periods after the VAR sample
                    
                    smpl_min_FACTORS = smpl_min_factors_vec(1,:);    %ehhez az kell, hogy a faktorok legalább 12 időszakkal a VAR után kezdődjenek
                    smpl_max_VAR = smpl_max_VAR_vec(1,:);
                    
                        smpl_max_FACTORS = smpl_max_factors_vec(1,:); %smpl_max_VAR; %[2012 6]; %this has crisis in it!

                    %print what is being calculated
                    fprintf('\n\n#%3.0f\n',ii{1});
                    
                        fprintf(['MONPOL: ' monpol_vars_cell{1,1} ...
                            '\nFACTORS: ' factors1_label_cell{1,1} ', ' factors2_label_cell{1,1} ...
                            ' ' num2str(smpl_min_FACTORS(1,1)) '-' ...
                            '\nSAMPLE: ' num2str(smpl_min_VAR(1,1)) '-' num2str(smpl_max_VAR(1,1)) '\n']);
                    
                     %Find the dates in the sample
                    VAR.smpl_min_VAR = find(and(DATASET_VAR.TSERIES(:,cell2mat(values(DATASET_VAR.MAP,{'YEAR'})))==smpl_min_VAR(1,1), ...
                        DATASET_VAR.TSERIES(:,cell2mat(values(DATASET_VAR.MAP,{'MONTH'})))==smpl_min_VAR(1,2)));
                    VAR.smpl_max_VAR = find(and(DATASET_VAR.TSERIES(:,cell2mat(values(DATASET_VAR.MAP,{'YEAR'})))==smpl_max_VAR(1,1), ...
                        DATASET_VAR.TSERIES(:,cell2mat(values(DATASET_VAR.MAP,{'MONTH'})))==smpl_max_VAR(1,2)));
                    VAR.smpl_max_VAR_factors = find(and(DATASET_VAR.TSERIES(:,cell2mat(values(DATASET_VAR.MAP,{'YEAR'})))==smpl_max_FACTORS(1,1), ...
                        DATASET_VAR.TSERIES(:,cell2mat(values(DATASET_VAR.MAP,{'MONTH'})))==smpl_max_FACTORS(1,2)));        %Maximum place of factors in the VAR dataset
                    
                    VAR.smpl_min_FACTORS = find(and(DATASET_FACTORS.TSERIES(:,cell2mat(values(DATASET_FACTORS.MAP,{'YEAR'})))==smpl_min_FACTORS(1,1), ...
                            DATASET_FACTORS.TSERIES(:,cell2mat(values(DATASET_FACTORS.MAP,{'MONTH'})))==smpl_min_FACTORS(1,2)));
                    VAR.smpl_max_FACTORS = find(and(DATASET_FACTORS.TSERIES(:,cell2mat(values(DATASET_FACTORS.MAP,{'YEAR'})))==smpl_max_FACTORS(1,1), ...
                            DATASET_FACTORS.TSERIES(:,cell2mat(values(DATASET_FACTORS.MAP,{'MONTH'})))==smpl_max_FACTORS(1,2)));
                 
           
                    %Select the variables in the VAR
                    VAR.select_vars      = {monpol_vars_cell{1,1}};
                    VAR.select_vars_label= {monpol_vars_label_cell{1,1}};
                    ii_vars             = 1;  

                    VAR.select_vars      =  [VAR.select_vars,{'LCPI','LIP', 'NEER'}];   %Add prices and industrial production
                    VAR.select_vars_label=  [VAR.select_vars_label,{'CPI','IP', 'NEER'}];                                    
                    VAR.chol_order       = [2 3 1 4];       %Cholesky ordering of the selected variables
                                     
               
                        VAR.select_factors   = {factors1_cell{1,1}};
                        VAR.select_factors_label   = {factors1_label_cell{1,1}};
                  
                    
                    VAR.extern_vars     =   {};
                    VAR.extern_vars_label=  {};
                    zz=1;
                    for uu=1:no_extern_vars
                        if ~strcmp(extern_vars_cell{1,uu},monpol_vars_cell{1}) %drop if it is the monetary policy variable, akkor 
                                VAR.extern_vars     =   [VAR.extern_vars,{extern_vars_cell{1,uu}}];   %hozzárakja a VAR változóihoz
                                VAR.extern_vars_label=  [VAR.extern_vars_label,{extern_vars_label_cell{1,uu}}];
                                VAR.extern_vars_smpl_min_vec(zz,:)=extern_vars_smpl_min_vec(uu,:);
                              
                                  VAR.smpl_min_VAR_e(1,zz) = find(and(DATASET_VAR.TSERIES(:,1)==VAR.extern_vars_smpl_min_vec(zz,1), ...
                                  DATASET_VAR.TSERIES(:,2)==VAR.extern_vars_smpl_min_vec(zz,2)));

                                  VAR.smpl_min_VAR_e(1,zz) = find(and(DATASET_VAR.TSERIES(:,cell2mat(values(DATASET_VAR.MAP,{'YEAR'})))==VAR.extern_vars_smpl_min_vec(zz,1), ...
                                  DATASET_VAR.TSERIES(:,cell2mat(values(DATASET_VAR.MAP,{'MONTH'})))==VAR.extern_vars_smpl_min_vec(zz,2)));
                                zz=zz+1;
                        end;
                    end;
                    
                                                   
                    %Run the VAR
                    [VAR,VARChol,VARbs,VARCholbs]=doVAR(VAR,DATASET_VAR,DATASET_FACTORS,nboot,clevel);
                     
                    %Create figures
                
                        nRow_e    =   3;
                        nCol_e    =   2;                                                    
                        if length(VAR.select_vars)>4
                                nRow    =   length(VAR.select_vars);
                                nCol    =   2;                            
                                no_fig=plot_figure_sep(VAR,VARChol,VARbs,VARCholbs,nRow,nCol,1,VAR.switch_extern);
                        elseif length(VAR.select_vars)==4
                                nRow    =   4;
                                nCol    =   2;                            
                                no_fig=plot_figure_sep(VAR,VARChol,VARbs,VARCholbs,nRow,nCol,1,VAR.switch_extern);
                        else
                                nRow    =   3;
                                nCol    =   2;                            
                                no_fig=plot_figure_sep(VAR,VARChol,VARbs,VARCholbs,nRow,nCol,1,VAR.switch_extern);
                        end;
                        ii{1} = ii{1}+no_fig;

                       VAR