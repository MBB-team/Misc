function [gx,dgdx,dgdP] = g_GLMsparse_md(x,P,u,in)
if in.sparsity
    [sP,dsdP] = sparseTransform(P,1);
end
[gx,dgdx,dgdP] = g_GLM_missingData(x,sP,u,in);
dgdP = dsdP*dgdP; % for exploiting the analytical gradients from g_GLM
