function bs = makeBSpline(degree, df, nSamples)

%%% bs = makeBSpline(degree, df, nSamples)
%
% PURPOSE: To generate a regression spline basis set with knots at evenly spaced intervals
%
% INPUTS:
%           'degree':   unsigned integer, degree of each polynomial term in the basis set.
%           'df':       degrees of freedom for basis set, equal to number of
%                       terms or basis functions in the set. Equivalent to n+k+1, where 
%                           n:= degree of the polynomials
%                           k:= the number of internal knots.
%           'nSamples': the number of samples or timepoints in the domain of
%                       the basis functions.
%
% OUTPUT:   'bs':       the basis functions, evaluated at each sample
%                       point. Formatted as a matrix of size nSamples x nBases.
%           
%
% AUTHOR: MJ SINISCALCHI, PNI, 240806
%
% NOTE: For a great intro to regression splines, see this primer by Jeffrey S. Racine: 
%           https://cran.r-project.org/web/packages/crs/vignettes/spline_primer.pdf
%---------------------------------------------------------------------------------------------------

%Order of spline basis set: degree of polynomial + 1 
order = degree+1; %MATLAB spcol takes the order=degree+1, not the degree

%Degrees freedom and order determine number of internal knots
nInternalKnots = df - order;

%Knot sequence
knotSeq = linspace(0, 1, nInternalKnots+2); %including 2 boundary (endpoint) knots
knotSeq = [zeros(1, degree), knotSeq, ones(1, degree)]; %append boundary knots n times; n, degree

%Tau: set of non-decreasing real numbers over which B-spline is evaluated
tau = linspace(0, 1, nSamples); %nIntervals between (0,1)

%Make spline basis set, evaluated at each value of tau 
bs = spcol(knotSeq, order, tau); %output is nSamples x df