function answer = isInsideTheBox(pointCoord,boxCoord)
% function answer = isInsideTheBox(pointCoord,boxCoord)

    answer = 0;
    
    if  pointCoord(1)>= boxCoord(1) &&...
        pointCoord(1)<= boxCoord(3) &&...
        pointCoord(2)>= boxCoord(2) &&...
        pointCoord(2)<= boxCoord(4) 
        
        answer = 1;
    
    end

    

end
