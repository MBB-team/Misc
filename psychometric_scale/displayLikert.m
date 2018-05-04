function [ scaleBox ] = displayLikert( WindowPtr, x,y, rating , target )

% parameters
% - discrete quantities
ngrad = 11;
% - continuous dimensions
pensize = 5;
[windowWidth,windowHeigth]=Screen('WindowSize',WindowPtr);
% scaleWidth = windowWidth/2 ;
% scaleWidth = 800 ;
scaleWidth = windowWidth*4/5 ;

segment=scaleWidth/(ngrad-1);
% yscale = y + windowHeigth/4;
yscale = windowHeigth*3/4;
ovalradius = segment/2;
boxsize = segment;
scaleBox = [x - scaleWidth/2 , yscale-boxsize/4,...
            x + scaleWidth/2 , yscale+boxsize/4] ;
        
% display discrete response fields
for igrad = 1:ngrad
   xoval = x - scaleWidth/2 + (igrad-1)*(scaleWidth/(ngrad-1));
%    Screen('FrameOval', WindowPtr,[255 255 255]*0.5,[xoval-ovalradius/2 yscale-ovalradius/2 xoval+ovalradius/2 yscale+ovalradius/2],pensize,pensize);
   Screen('FrameRect', WindowPtr,[255 255 255]*0.5,[xoval-boxsize/2 yscale-boxsize/4 xoval+boxsize/2 yscale+boxsize/4],pensize);
end

% display confirmed response
if ~isempty(rating)
    irating = round(rating*(ngrad-1)/100) + 1;
    xarrow= x - scaleWidth/2 + (irating-1)*(scaleWidth/(ngrad-1));
%     Screen('FillOval', WindowPtr,[0 255 0],[xarrow-ovalradius/2 yscale-ovalradius/2 xarrow+ovalradius/2 yscale+ovalradius/2]);
    Screen('FillRect', WindowPtr,[0 255 0],[xarrow-boxsize/2 yscale-boxsize/4 xarrow+boxsize/2 yscale+boxsize/4]);
end

% display target
if nargin>4
   targetsize = ovalradius/4;
   itarget = round(target*(ngrad-1)/100) + 1;
   xtarget = x - scaleWidth/2 + (itarget-1)*(scaleWidth/(ngrad-1));
%    Screen('FrameOval', WindowPtr,[255 0 0],[xtarget-ovalradius/2 yscale-ovalradius/2 xtarget+ovalradius/2 yscale+ovalradius/2],pensize,pensize);
   Screen('FrameRect', WindowPtr,[0 255 0],[xtarget-boxsize/2 yscale-boxsize/4 xtarget+boxsize/2 yscale+boxsize/4],pensize);
   Screen('DrawLine', WindowPtr,[0 255 0], xtarget-boxsize/2-targetsize, yscale,  xtarget-boxsize/2, yscale,pensize);
   Screen('DrawLine', WindowPtr,[0 255 0], xtarget+boxsize/2, yscale,  xtarget+boxsize/2+targetsize, yscale,pensize);
   Screen('DrawLine', WindowPtr,[0 255 0], xtarget, yscale-boxsize/4-targetsize,  xtarget, yscale-boxsize/4,pensize);
   Screen('DrawLine', WindowPtr,[0 255 0], xtarget, yscale+boxsize/4,  xtarget, yscale+boxsize/4+targetsize,pensize);
end

end

