function drawText(text, display, opt)
% drawText(text, display, opt)
%
% Input:
%   text
%   display
%   opt
%       size
%       font
%       style
%       color
%       x
%       y
%       increment
%
% Note:
% - Dependencies: <a href="matlab: web('http://psychtoolbox.org/')">Psychtoolbox</a>

% To DO:
% - Optimize Code
% - Document the shit out of this

% Written by Kelly Chang - September 16, 2016

%% Display Control

if ~isfield(display, 'resolution')
    display.resolution = Screen('Rect', display.window);
end

%% Input Control

if ~exist('opt', 'var')
    opt.size = 24;
    opt.font = 'Courier';
    opt.style = 0;
    opt.color = [255 255 255];
    opt.x = [0 display.resolution(1)];
    opt.y = 0;
    opt.increment = display.resolution(2)*0.05;
end

if ~isfield(opt, 'size');
    opt.size = 24;
end

if ~isfield(opt, 'font');
    opt.font = 'Courier';
end

if ~isfield(opt, 'style');
    opt.style = 0;
end

if ~isfield(opt, 'color');
    opt.color = [255 255 255];
end

if ~isfield(opt, 'x');
    opt.x = [0 display.resolution(1)];
end

if length(opt.x) == 1
    opt.x(2) = display.resolution(1);
end

if ~isfield(opt, 'y');
    opt.y = 0;
end

if ~isfield(opt, 'increment');
    opt.increment = display.resolution(2)*0.05;
end

%% Computer Control

c = Screen('Computer');
os = {'macintosh', 'windows', 'osx', 'linux'};
os = os{logical([c.macintosh c.windows c.osx c.linux])};

switch os
    case 'macintosh'
        styleID = {'bold1', 'italic2'};
    case 'windows'
        styleID = {'bold1', 'italic2', 'underline4'};
    case 'osx'
        styleID = {'bold1', 'italic2', 'underline4', 'condense32', 'extend64'};
    case 'linux'
        styleID = {'bold1', 'italic2', 'outline8', 'condense32', 'extend64'};
end

%% Prepare Regular Expression for Information Extraction

textOnly = regexprep(text, '</?[A-Za-z0-9= \[\],]*>', '');
style = regexprep(styleID, '[0-9*]', '');
flds = [style 'size', 'font', 'color'];
pattern = [cellfun(@(x) sprintf('<%s>|</%s>',x(1),x(1)), style, 'UniformOutput', false), ...
    '<size=[0-9a-z ]*>|</size>', '<font=[A-Za-z ]*>|</font>', ...
    '<color=\[[0-9]*[ ,]*[0-9]*[ ,]*[0-9]*\]>|</color>'];
pattern = [pattern; repmat({''}, 1, length(style)) ...
    '<size=(?<size>[0-9]*)>', '<font=(?<font>[A-Za-z ]*)>', ...
    '<color=\[(?<r>[0-9]*)[ ,]*(?<g>[0-9]*)[ ,]*(?<b>[0-9]*)\]>'];
pattern = [pattern; repmat({''}, 1, length(style)), ...
    'str2double(x.size);', 'x.font;', 'str2double({x.r x.g x.b});'];

%% Extracting Formatting Range(s)

flds = flds(cellfun(@(x) ~isempty(regexp(text,x,'once')), pattern(1,:)));
pattern = pattern(:,cellfun(@(x) ~isempty(regexp(text,x,'once')), pattern(1,:)));
for i = 1:length(flds)
    [tmpStart,tmpEnd] = regexp(text, pattern{1,i});
    tmp = mat2cell([tmpStart; tmpEnd], 2, repmat(2, 1, length(tmpStart)/2));
    tags = cellfun(@(x) text(x(1):x(4)), tmp, 'UniformOutput', false);
    match = cellfun(@(x) regexprep(x,'</?[A-Za-z0-9= \[\],]*>',''), tags, 'UniformOutput', false);
    [tmpS,tmpE] = cellfun(@(x) regexp(textOnly,x), unique(match), 'UniformOutput', false);
    format.(flds{i})(1,:) = cellfun(@(x) x(1):x(2), num2cell([tmpS{:}; tmpE{:}],1), 'UniformOutput', false);
    if ~isempty(pattern{2,i}) % if extracting information
        [~,indx] = sort(match);
        tmp = cellfun(@(x) regexp(x,pattern{2,i},'names'), tags(indx), 'UniformOutput', false);
        format.(flds{i})(2,:) = cellfun(@(x) eval(pattern{3,i}), tmp, 'UniformOutput', false);
    end
end

%% Initializing Text Profile

profile = struct();
for i = 1:length(textOnly)
    profile(i).size = opt.size;
    profile(i).font = opt.font;
    profile(i).style = opt.style;
    profile(i).color = opt.color;
    profile(i).y = opt.y;
end

%% Profiling Text

for i = 1:length(textOnly)
    for i2 = 1:length(flds)
        if ismember(i,[format.(flds{i2}){1,:}]) % if has formatting
            if ismember(flds{i2}, style) % if style
                profile(i).style = str2double(regexprep(styleID(strcmp(flds{i2}, ...
                    regexprep(styleID, '[0-9]*', ''))), '[a-z]*', ''));
            else % if other
                profile(i).(flds{i2}) = format.(flds{i2}){2, ...
                    cellfun(@(x) ismember(i,x), format.(flds{i2})(1,:))};
            end
        end
    end
end

%% Adjust Text Positioning

tmp = [0 regexp(textOnly, ' ') length(textOnly)+1];
wordIndx = arrayfun(@(x) (tmp(x)+1):(tmp(x+1)-1), 1:(length(tmp)-1), 'UniformOutput', false);
word = cellfun(@(x) textOnly(x), wordIndx, 'UniformOutput', false);

last = 1;
newLine = false(1, length(word));
for i = 1:length(word)
    tmp = profile(wordIndx{i}(1));
    Screen('TextSize', display.window, tmp.size);
    Screen('TextFont', display.window, tmp.font);
    Screen('TextStyle', display.window, tmp.style);
    [~,b{i}] = Screen('TextBounds', display.window, strjoin(word(last:i), ' '), ...
        opt.x(1), opt.y);
    if b{i}(3) > opt.x(2)
        newLine(i) = true;
        last = i;
    end
end

newLine = find(newLine);
for i = 1:length(newLine)
    for i2 = wordIndx{newLine(i)}(1):length(profile)
        profile(i2).y = profile(i2).y + opt.increment;
    end
end

%% Chunking Text into Formatted Groups

group = 1;
nGroup = 1;
for i = 1:(length(profile)-1)
    if ~isequal(profile(i), profile(i+1))
        nGroup = nGroup + 1;
    end
    group(i+1) = nGroup;
end

resetX = [true false(1, nGroup-1)];
for i = 1:(nGroup-1)
    if ~isequal(unique([profile(group == i).y]), unique([profile(group == (i+1)).y]))
        resetX(i+1) = true;
    end
end

%% Draw Text

for i = 1:nGroup
    tmp = profile(group == i);
    Screen('TextSize', display.window, tmp(1).size);
    Screen('TextFont', display.window, tmp(1).font);
    Screen('TextStyle', display.window, tmp(1).style);
    if resetX(i)
        tmpX = Screen('DrawText', display.window, textOnly(group == i), opt.x(1), ...
            tmp(1).y, tmp(1).color);
    else
        tmpX = Screen('DrawText', display.window, textOnly(group == i), tmpX, ...
            tmp(1).y, tmp(1).color);
    end
end