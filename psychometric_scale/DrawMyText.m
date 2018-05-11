function []= DrawMyText(window,textstring,textsize,textcol,textcenter)
% DrawMyText - personalized DrawFormattedText parametrization
% Nicolas Borderies
% February 2017

wrapat=60;
Screen('TextSize', window, textsize);
[w,h]=RectSize(Screen('TextBounds',window,textstring));
DrawFormattedText(window, textstring,textcenter(1)-w/2, textcenter(2)-h/2,textcol, wrapat, 0, 0, 1, 0, []);


end