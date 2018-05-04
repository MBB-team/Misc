function [] = displayScale_2(WindowHandle,x,y,question,answers)
    
    [W,H]=Screen('WindowSize',WindowHandle);
    x=W/2;
    y=H/2;
    xScaleLim = [x*1/5,x*9/5];
    yscale = 1/2*y;
%     xScaleLim = [x-400,x+400];
%     yscale = 200;

    DrawMyText(WindowHandle,double(question),30,[100 100 100],[x,y-100+yscale]);
    DrawMyText(WindowHandle,double(answers{1}),30,[255 153 0],[xScaleLim(1)-25,y-60+yscale]);
    DrawMyText(WindowHandle,double(answers{2}),30,[255 153 0],[xScaleLim(2)+25,y-60+yscale]);

end