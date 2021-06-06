function [x_delta,lambda] = discrep(U,s,V,b,delta,x_0) 
%DISCREP Discrepancy principle criterion for choosing the reg. parameter. 
% 
% [x_delta,lambda] = discrep(U,s,V,b,delta,x_0) 
% [x_delta,lambda] = discrep(U,sm,X,b,delta,x_0)  ,  sm = [sigma,mu] 
% 
% Least squares minimization with a quadratic inequality constraint: 
%    min || x - x_0 ||       subject to   || A x - b || <= delta 
%    min || L (x - x_0) ||   subject to   || A x - b || <= delta 
% where x_0 is an initial guess of the solution, and delta is a 
% positive constant.  Requires either the compact SVD of A saved as 
% U, s, and V, or part of the GSVD of (A,L) saved as U, sm, and X. 
% The regularization parameter lambda is also returned. 
% 
% If delta is a vector, then x_delta is a matrix such that 
%    x_delta = [ x_delta(1), x_delta(2), ... ] . 
% 
% If x_0 is not specified, x_0 = 0 is used. 
 
% Reference: V. A. Morozov, "Methods for Solving Incorrectly Posed 
% Problems", Springer, 1984; Chapter 26. 
 
% Per Christian Hansen, IMM, 12/29/97. 
 
% Initialization. 
[n,p] = size(V);    [p,ps] = size(s);      ld  = length(delta); 
x_k = zeros(n,ld);  lambda = zeros(ld,1);  rho = zeros(p,1); 
if (min(delta)<0) 
  error('Illegal inequality constraint delta') 
end 
if (nargin==5), x_0 = zeros(n,1); end 
if (ps == 1), omega = V'*x_0; else, omega = V\x_0; end 
 
% Compute residual norms corresponding to TSVD/TGSVD. 
beta = U'*b; 
nb   = norm(b); 
snz  = length(find(s(:,1)>0)); 
if (ps == 1) 
  delta_0 = norm(b - U*beta); 
  rho(n) = delta_0^2; 
  for i=n:-1:2 
    rho(i-1) = rho(i) + (beta(i) - s(i)*omega(i))^2; 
  end 
else 
  delta_0 = norm(b - U*beta); 
  rho(1) = delta_0^2; 
  for i=1:p-1 
    rho(i+1) = rho(i) + (beta(i) - s(i,1)*omega(i))^2; 
  end 
end 
 
% Check input. 
if (min(delta) < delta_0) 
  error('Irrelevant delta < || (I - U*U'')*b ||') 
end 
 
% Determine the initial guess via rho-vector, then solve the nonlinear 
% equation || b - A x ||^2 - delta_0^2 = 0 via Newton's method. 
if (ps == 1) 
  s2 = s.^2; 
  for k=1:ld 
    if (delta(k)^2 >= norm(beta - s.*omega)^2 + delta_0^2) 
      x_delta(:,k) = x_0; 
    else 
      [dummy,kmin] = min(abs(rho - delta(k)^2)); 
      lambda_0 = s(kmin); 
      lambda(k) = newton(lambda_0,delta(k),s,beta,omega,delta_0); 
      e = s./(s2 + lambda(k)^2); f = s.*e; 
      x_delta(:,k) = V(:,1:p)*(e.*beta + (1-f).*omega); 
    end 
  end 
else 
  omega = omega(1:p); gamma = s(:,1)./s(:,2); 
  x_u   = V(:,p+1:n)*beta(p+1:n); 
  for k=1:ld 
    if (delta(k)^2 >= norm(beta(1:p) - s(:,1).*omega)^2 + delta_0^2) 
      x_delta(:,k) = V*[omega;U(:,p+1:n)'*b]; 
    else 
      [dummy,kmin] = min(abs(rho - delta(k)^2)); 
      lambda_0 = gamma(kmin); 
      lambda(k) = newton(lambda_0,delta(k),s,beta(1:p),omega,delta_0); 
      e = gamma./(gamma.^2 + lambda(k)^2); f = gamma.*e; 
      x_delta(:,k) = V(:,1:p)*(e.*beta(1:p)./s(:,2) + ... 
                               (1-f).*s(:,2).*omega) + x_u; 
    end 
  end 
end 
