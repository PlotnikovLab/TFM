% Regularization Tools. 
% Version 3.1  13-September-01. 
% Copyright (c) 1993 and 1998 by Per Christian Hansen and IMM. 
% 
% Demonstration. 
%   regudemo  - Tutorial introduction to Regularization Tools. 
% 
% Test examples. 
%   baart     - Fredholm integral equation of the first kind. 
%   blur      - Image deblurring test problem. 
%   deriv2    - Computation of the second derivative. 
%   foxgood   - Severely ill-posed problem. 
%   heat      - Inverse heat equation. 
%   ilaplace  - Inverse Laplace transformation. 
%   parallax  - Stellar parallax problem with 28 fixed observations. 
%   phillips  - Philips' "famous" test problem. 
%   shaw      - One-dimensional image restoration problem. 
%   spikes    - Test problem with a "spiky" solution. 
%   ursell    - Integral equation with no square integrable solution. 
%   wing      - Test problem with a discontinuous solution. 
% 
% Regularization routines. 
%   cgls      - Computes the least squares solution based on k steps 
%               of the conjugate gradient algorithm. 
%   discrep   - Minimizes the solution (semi-)norm subject to an upper 
%               bound on the residual norm (discrepancy principle). 
%   dsvd      - Computes the damped SVD/GSVD solution. 
%   lsqi      - Minimizes the residual norm subject to an upper bound 
%               on the (semi-)norm of the solution. 
%   lsqr_b    - Computes the least squares solution based on k steps 
%               of the LSQR algorithm (Lanczos bidiagonalization). 
%   maxent    - Computes the maximum entropy regularized solution. 
%   mtsvd     - Computes the modified TSVD solution. 
%   nu        - Computes the solution based on k steps of Brakhage's 
%               iterative nu-method. 
%   pcgls     - Same as cgls, but for general-form regularization. 
%   plsqr_b   - Same as lsqr, but for general-form regularization. 
%   pnu       - Same as nu, but for general-form regularization. 
%   tgsvd     - Computes the truncated GSVD solution. 
%   tikhonov  - Computes the Tikhonov regularized solution. 
%   tsvd      - Computes the truncated SVD solution. 
%   ttls      - Computes the truncated TLS solution. 
% 
% Analysis routines. 
%   fil_fac   - Computes filter factors for some regularization methods. 
%   gcv       - Plots the GCV function and computes its minimum. 
%   l_corner  - Locates the L-shaped corner of the L-curve. 
%   l_curve   - Computes the L-curve, plots it, and computes its corner. 
%   lagrange  - Plots the Lagrange function ||Ax-b||^2 + lambda^2*||Lx||^2, 
%               and its derivative. 
%   picard    - Plots the (generalized) singular values, the Fourier 
%               coefficient for the right-hand side, and a (smoothed curve of) 
%               the solution's Fourier-coefficients. 
%   plot_lc   - Plots an L-curve. 
%   quasiopt  - Plots the quasi-optimality function and computes its minimum. 
% 
% Routines for transforming a problem in general form into one in 
% standard form, and back again. 
%   gen_form  - Transforms a standard-form solution back into the 
%               general-form setting. 
%   std_form  - Transforms a general-form problem into one in 
%               standard form. 
% 
% Utility routines. 
%   bidiag    - Bidiagonalization of a matrix by Householder transformations. 
%   cgsvd     - Computes the compact generalized SVD of a matrix pair. 
%   csvd      - Computes the compact SVD of an m-by-n matrix. 
%   get_l     - Produces a p-by-n matrix which is the discrete 
%               approximation to the d'th order derivative operator. 
%   lanc_b    - Performs k steps of the Lanczos bidiagonalization 
%               process with/without reorthogonalization. 
%   regutm    - Generates random test matrices for regularization methods. 
% 
% Auxiliary routines required by some of the above routines. 
%   app_hh_l  - Applies a Householder transformation from the left. 
%   gen_hh    - Generates a Householder transformation. 
%   heb_new   - Newton-Raphson iteration with Hebden's rational 
%               approximation, used in lsqi. 
%   lsolve    - Inversion with A-weighted generalized inverse of L. 
%   ltsolve   - Inversion with transposed A-weighted inverse of L. 
%   newton    - Newton iteration, used in discrep. 
%   pinit     - Initialization for treating general-form problems. 
%   pythag    - Computes sqrt(a^2 + b^2). 
%   spleval   - Computes points on a spline or spline curve. 
 
% The following three routines are not documented, since they are only used
% internally by gcv, l_corner, and quasiopt, respectively.
%   gcvfun    - Computes the GCV function
%   lcfun     - Computes the curvature of the L-curve
%   quasifun  - Computes the quasi-optimality function.
%
% In certain occations (cf. the manual), the function l_corner requires the 
% following nine functions from the Spline Toolbox, Version 2.0: 
%   fnder, ppbrk, ppmak, ppual, sp2pp, sorted, spbrk, spmak, sprpp. 
% If the Spline Toolbox is not available, then the package can still be used 
% with almost full functionality, the only exception being that one is not 
% able to compute the "corner" of discrete L-curves. 
