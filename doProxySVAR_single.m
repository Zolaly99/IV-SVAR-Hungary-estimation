function VAR = doProxySVAR_single(VAR)
%Mertens-Ravn 2013 external instrument, modified to 
%1) handle different length of VAR and factors
%2) Multiple instruments to explain the same variable

 X      = lagmatrix(VAR.vars,1:VAR.p);
 X      = X(VAR.p+1:end,:);
 Y      = VAR.vars(VAR.p+1:end,:);
 [VAR.T,VAR.n] = size(Y);
 [VAR.T_m,VAR.n_m] = size(VAR.proxies);

 
 % number of proxies
 VAR.k  = 1;
 %Assuming proxies start at least p periods later
 VAR.m  = VAR.proxies(1:end,:);
 
% Run VAR
%%%%%%%%%%%%
VAR.bet=[X ones(length(X),1)]\Y; 
VAR.res = Y-[X ones(length(X),1)]*VAR.bet;
              
% Identification
%%%%%%%%%%%%%%%%%

% Only the restricted sample is used for identification
VAR.Sigma_m = (VAR.res(VAR.T-VAR.T_m-VAR.T_m_end+1:VAR.T-VAR.T_m_end,:)'*VAR.res(VAR.T-VAR.T_m-VAR.T_m_end+1:VAR.T-VAR.T_m_end,:))/(VAR.T_m-VAR.n*VAR.p-1);  %variance-covariance matrix of the residuals of the equations

Phib = [ones(VAR.T_m,1) VAR.m]\VAR.res(VAR.T-VAR.T_m-VAR.T_m_end+1:VAR.T-VAR.T_m_end,:);   %Instrument's design matrix * Phib = residuals of the VAR


Res_m = VAR.res(VAR.T-VAR.T_m-VAR.T_m_end+1:VAR.T-VAR.T_m_end,:)-[ones(VAR.T_m,1) VAR.m]*Phib; %A reziduumokra (u) felírt instrumentumos egyenlet reziduuma
Res_const   =   VAR.res(VAR.T-VAR.T_m-VAR.T_m_end+1:VAR.T-VAR.T_m_end,1)-ones(VAR.T_m,1)*(ones(VAR.T_m,1)\VAR.res(VAR.T-VAR.T_m-VAR.T_m_end+1:VAR.T-VAR.T_m_end,1));
XX_m    =   [ones(VAR.T_m,1) VAR.m];
%Calculate robust standard errors
SS_m  =   zeros(VAR.n_m+1,VAR.n_m+1);
for ii=1:VAR.T_m
    SS_m  =   SS_m+1/VAR.T_m*XX_m(ii,:)'*XX_m(ii,:)*Res_m(ii,1)^2;
end;
Avarb_m     =   inv(1/VAR.T_m*XX_m'*XX_m)*SS_m*inv(1/VAR.T_m*XX_m'*XX_m);
RR_m     =   [zeros(VAR.n_m,1) eye(VAR.n_m)];
WW_m    =   VAR.T_m*(RR_m*Phib(:,1))'*inv(RR_m*Avarb_m*RR_m')*(RR_m*Phib(:,1));
VAR.F_m_rob     =   WW_m/VAR.n_m;

SST_m = Res_const'*Res_const;
SSE_m = Res_m(:,1)'*Res_m(:,1);
VAR.F_m = ((SST_m-SSE_m)/VAR.n_m)/(SSE_m/(length(VAR.res(VAR.T-VAR.T_m-VAR.T_m_end+1:VAR.T-VAR.T_m_end,1))-(VAR.n_m+1)));
VAR.R2_m = (1-SSE_m/(SST_m));
VAR.R2adj_m = VAR.R2_m-(VAR.n_m/((length(VAR.res(VAR.T-VAR.T_m-VAR.T_m_end+1:VAR.T-VAR.T_m_end,1))-(VAR.n_m+1))))*(1-VAR.R2_m); 

%TSLS, get a forecast of u1
uhat1           =   [ones(VAR.T_m,1) VAR.m]*Phib(:,1);
b21ib11_TSLS    =   [ones(VAR.T_m,1) uhat1]\VAR.res(VAR.T-VAR.T_m-VAR.T_m_end+1:VAR.T-VAR.T_m_end,2:end);    %13-as egyenlet a cikkben
b21ib11_TSLS    =   b21ib11_TSLS(2:end,:)';

b21ib11     =   b21ib11_TSLS;


% Identification of b11 and b12 from the covariance matrix of the VAR
Sig11   = VAR.Sigma_m(1:VAR.k,1:VAR.k);
Sig21   = VAR.Sigma_m(VAR.k+1:VAR.n,1:VAR.k);
Sig22   = VAR.Sigma_m(VAR.k+1:VAR.n,VAR.k+1:VAR.n);
ZZp     = b21ib11*Sig11*b21ib11'-(Sig21*b21ib11'+b21ib11*Sig21')+Sig22;
b12b12p = (Sig21- b21ib11*Sig11)'*(ZZp\(Sig21- b21ib11*Sig11));
b11b11p = Sig11-b12b12p;
b11 = sqrt(b11b11p);
VAR.b1 = [b11; b21ib11*b11];
VAR.Phib = Phib;

% Impulse Responses
%%%%%%%%%%%%%%%%%%%%
%initial shock: eps(1,1)=1
VAR.b1(3,1) = 0;
irs(VAR.p+1,:) = VAR.b1(:,1);


for jj=2:VAR.irhor
    lvars = (irs(VAR.p+jj-1:-1:jj,:))';
    irs(VAR.p+jj,:) = lvars(:)'*VAR.bet(1:VAR.p*VAR.n,:);     
end

VAR.irs   = irs(VAR.p+1:VAR.p+VAR.irhor,:);
