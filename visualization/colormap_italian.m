function [map] = colormap_italian()

    map(1,:) = [1 0 0]; % colormap
    for nContrast = 2:32
        map(nContrast,:) = [map(nContrast-1,1), map(nContrast-1,2)+(1/31), map(nContrast-1,3)+(1/31)];
    end
    for nContrast = 33:64
        map(nContrast,:) = [map(nContrast-1,1)-(1/33), map(nContrast-1,2), map(nContrast-1,3)-(1/33)];
    end

    colormap(map);
    colorbar;