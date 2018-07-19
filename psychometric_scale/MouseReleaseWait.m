function [] = MouseReleaseWait()

    ok = 1;
    while ok 
        [xMouse,yMouse,buttons] = GetMouse;
        ok = any(buttons);
    end


end