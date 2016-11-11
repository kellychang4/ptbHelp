clear all; close all;
cd('~/Desktop/ptb');


onExit = 'Script halted by experimentor';

try
    KbName('UnifyKeyNames');
    display.resolution = [320 200];
    display = openWindow(display);
    
    [~,~,keyCode] = KbCheck();
    while true
        [~,~,keyCode] = KbCheck();
        assert(~keyCode(KbName('Escape')), onExit);
        Screen('Flip', display.window)
    end
catch ME
    Screen('CloseAll');
    rethrow(ME);
end
