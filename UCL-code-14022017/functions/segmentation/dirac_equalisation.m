function y = dirac_equalisation(x,x0,a)

x(x>x0) = x0;
y = x0*(1-((x0-x)/x0).^a);

end
