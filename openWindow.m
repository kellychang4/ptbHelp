function [display] = openWindow(display)
% [display] = openWindow(display)
%
% Input:
%   display
%       screen
%       resolution
%       color
%       skipChecks
%   
% Output:
%   display
%       window
%       frameRate
%
% Note:
% - Dependencies: <a href="matlab: web('http://psychtoolbox.org/')">Psychtoolbox</a>

% Inspired by OpenWindow.m written by Geoffrey Boynton - Novermber 13, 2007
% Written by Kelly Chang - September 16, 2016

%% Input Control

if ~exist('display', 'var');
    display.screen = max(Screen('Screens'));
    display.resolution = Screen('Rect', display.screen);
    display.color = [0 0 0]; 
    display.skipChecks = true;
end

if ~isfield(display, 'nScreen')
    display.screen = max(Screen('Screens'));
end

if ~isfield(display, 'resolution');
    display.resolution = Screen('Rect', display.screen);
end

if length(display.resolution) == 2
    display.resolution = [0 0 display.resolution];
end

if ~isfield(display, 'color')
    display.color = [0 0 0];
end

if ~isfield(display, 'skipChecks')
    display.skipChecks = true;
end

%% Open Window

if display.skipChecks
    Screen('Preference', 'Verbosity', 0);
    Screen('Preference', 'SkipSyncTests',1);
    Screen('Preference', 'VisualDebugLevel',0);
    Screen('Preference', 'SuppressAllWarnings', 1);
end

[display.window,res] = Screen('OpenWindow', display.screen, display.color, ...
    display.resolution);
display.resolution = res(3:4);
display.frameRate = 1/Screen('GetFlipInterval', display.window);