function [x_alpha,lambda] = lsqi(U,s,V,b,alpha,x_0) 
%LSQI Least squares minimizaiton with a quadratic inequality constraint. 
% 
% [x_alpha,lambda] = lsqi(U,s,V,b,alpha,x_0) 
% [x_alpha,lambda] = lsqi(U,sm,X,b,alpha,x_0)  ,  sm = [sigma,mu] 
% 
% Least squares minimization with a quadratic inequality constraint: 
%    min || A x - b ||   subject to   || x - x_0 ||     <= alpha 
%    min || A x - b ||   subject to   || L (x - x_0) || <= alpha 
% where x_0 is an initial guess of the solution, and alpha is a 
% positive constant.  Requires either the compact SVD of A saved as 
% U, s, and V, or part of the GSVD of (A,L) saved as U, sm, and X. 
% The regularization parameter lambda is also returned. 
% 
% If alpha is a vector, then x_alpha is a matrix such that 
%    x_alpha = [ x_alpha(1), x_alpha(2), ... ] . 
% 
% If x_0 is not specified, x_0 = 0 is used. 
 
% Reference: T. F. Chan, J. Olkin & D. W. Cooley, "Solving quadratically 
% constrained least squares using block box unconstrained solvers", 
% BIT 32 (1992), 481-495. 
% Extension to the case x_0 ~= 0 by Per Chr. Hansen, IMM, 11/20/91. 
% Key point: the initial lambda is almost unaffected by x_0 because 
% || x_unreg || >> || x_0 ||. 
 
% Per Christian Hansen, IMM, 11/22/91. 
 
% Initialization. 
[n,p] = size(V); [p,ps] = size(s); 
if (min(alpha)<0) 
  error('Negative inequality constraint alpha') 
end 
if (nargin==5), x_0 = zeros(n,1); end 
la  = length(alpha); 
x_k = zeros(n,la);            lambda = zeros(la,1); 
snz = length(find(s(:,1)>0)); beta   = U'*b; 
 
% If alpha > || x_LS - x_0 || then return x_LS, otherwise compute 
% lambda via Hebden-Newton iteration using a good initial guess. 
% The initial guess lambda_0 is a modified version of the one from 
% the Chan-Olkin-Cooley paper. 
if (ps == 1) 
  xi = beta(1:snz)./s(1:snz); omega = V'*x_0; s2 = s.^2; 
  x_unreg = V(:,1:snz)*xi; norm_x_unreg = norm(x_unreg - x_0); 
  for k=1:la 
    if (norm_x_unreg <= alpha(k)) 
      x_alpha(:,k) = x_unreg; lambda(k) = 0; 
    else 
      lambda_0 = s(snz)*(norm_x_unreg/alpha(k) - 1); 
      lambda(k) = heb_new(lambda_0,alpha(k),s,beta,omega); 
      e = s./(s2 + lambda(k)^2); f = s.*e; 
      x_alpha(:,k) = V(:,1:p)*(e.*beta + (1-f).*omega); 
    end 
  end 
else 
  x_u   = V(:,p+1:n)*beta(p+1:n);  ps1   = p-snz+1; 
  xi    = beta(ps1:p)./s(ps1:p,1); gamma = s(:,1)./s(:,2); 
  omega = V\x_0; omega = omega(1:p); 
  x_unreg = V(:,ps1:p)*xi + x_u; 
  norm_Lx_unreg = norm(s(ps1:p,2).*(xi - omega(ps1:p))); 
  for k=1:la 
    if (norm_Lx_unreg <= alpha(k)) 
      x_alpha(:,k) = x_unreg; lambda(k) = 0; 
    else 
      lambda_0 = (s(ps1,1)/s(ps1,2))*(norm_Lx_unreg/alpha(k) - 1); 
      lambda(k) = heb_new(lambda_0,alpha(k),s,beta(1:p),omega); 
      e = gamma./(gamma.^2 + lambda(k)^2); f = gamma.*e; 
      x_alpha(:,k) = V(:,1:p)*(e.*beta(1:p)./s(:,2) + ... 
                               (1-f).*s(:,2).*omega) + x_u; 
    end 
  end 
end 