
clear all; close all;

display = openWindow();

drawText(['This is a sample text that is for the sole purpose of showing ' ...
    'off this function that I made! I particularly like the fact that I can ' ...
    'use html tags to <b>bold</b>, <i>italics</i>, and <u>underline</u> ' ...
    'words (depending on the operating system some of these may work). ' ...
    'I can also change the color of certain text to something other than ' ...
    'the default like <color=[255 0 0]>red</color>, ' ...
    '<color=[0 255 0]>green</color>, <color=[0 0 255]>blue</color>. You can ' ...
    'even change the font to <font=Arial>Arial</font>! The text <size=30>size</size> ' ...
    'as well. And if you''ve noticed the text will automatically wrap around ' ...
    'the specified x boundaries of the screen. And lastly the best part is ' ...
    'the ability to write this all out in one continuous text string. ' ...
    '<color=[0 165 0]><b>THANK YOU!!!</b></color>'], display, ...
    struct('x', display.resolution(1)*[0.1 0.9], 'y', display.resolution(2)*0.15));

Screen('Flip', display.window);
wait4key('space');

Screen('CloseAll');


