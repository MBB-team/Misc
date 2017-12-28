function [gx,dgdx,dgdP] = g_GLM_md(x,P,u,in)

if in.sparsity
    [sP,dsdP] = sparsify(P,in.smooth);
    [gx,dgdx,dgdP] = g_GLM_missingData(x,sP,u,in);
    dgdP = dsdP*dgdP; % for exploiting the analytical gradients from g_GLM
else
    [gx,dgdx,dgdP] = g_GLM_missingData(x,P,u,in);
end

