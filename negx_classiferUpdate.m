function [mu0,sig0] = negx_classiferUpdate(negx,mu0,sig0,lRate)

%--------------------------------------------------

nmu = mean(negx.feature,2);
[nrow,ncol] = size(negx.feature);
negmu = repmat(nmu,1,ncol);
sigm0 = mean((negx.feature-negmu).^2,2);

sig0= sqrt(lRate*sig0.^2+ (1-lRate)*sigm0+lRate*(1-lRate)*(mu0-nmu).^2);
mu0 = lRate*mu0 + (1-lRate)*nmu;