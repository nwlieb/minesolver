%Randomly generates then solves a minesweeper field
function mineSolver
    clear; clc; close all;
    
    addpath('lib/', 'img/');
    
    global minefieldDim mineNum
    global equationMatrix equationMatrixDim equationMatrixPos
    global solvedEqMatrix solvedEqMatrixDim
    global maxPermutations
    
    %Create menu to set minefield dimensions and settings
    settings = getSettings();
    
    %Set minefield dimensions
    minefieldDim(1) = str2double(settings{1});
    minefieldDim(2) = str2double(settings{2});
    mineNum = str2double(settings{3});
    
    initializeFigureWindow(1);
    dncInit();
    
    %generate the minefield into global variable "minefield"
    generateMinefield(minefieldDim(1), minefieldDim(2), mineNum);
    
    %Initially display the minefield
    dispMinefield();
    
    % Get total number of cells
    cellNum = minefieldDim(1)*minefieldDim(2);
    
    %Create global matrix to store calculations
    %Size dynamically grows
    equationMatrix = zeros(1,cellNum+1);
    equationMatrixDim = size(equationMatrix);
    equationMatrixPos = 1;
    
    %Create the solved equation matrix
    solvedEqMatrix = zeros(equationMatrixDim(2),equationMatrixDim(2));
    solvedEqMatrixDim = size(solvedEqMatrix);
    
    maxPermutations = 10;
    solveMinefield();
    bombsSolved = minesSolved();
    
    maxPermutations = 1;
    %Start the guessing loop
    while bombsSolved ~= mineNum
        success = guess();
        if ~success
            break;
        else
            fprintf('Guess was successful!!\n\n');
            solveMinefield();
            bombsSolved = minesSolved();
        end
    end
    
    if bombsSolved == mineNum
        fprintf('What!?? I won!\n');
        %Puzzle is solved, clear all unknowns
        clearAllUnknowns();
    end
end

%initialize divide and conquor data structures
function dncInit()
    global minefieldDim solvedArray grain;
    
    grain = 3;
    saM = ceil(minefieldDim(1)/grain);
    saN = ceil(minefieldDim(2)/grain);
    
    %solvedArray is the solved array which represents each 3*3 block as a flag
    %denoting whether the block is solved or not.
    solvedArray = zeros(saM, saN);
end

%Initialize the figure window with given size, offset and title
function initializeFigureWindow(multiplier)
    %Creates a figure window with defined properties
    global minefieldDim sprites
    
    sprites = {};
    sprites{1} = imread('OneCell.png');
    sprites{2} = imread('TwoCell.png');
    sprites{3} = imread('ThreeCell.png');
    sprites{4} = imread('FourCell.png');
    sprites{5} = imread('FiveCell.png');
    sprites{6} = imread('SixCell.png');
    sprites{7} = imread('SevenCell.png');
    sprites{8} = imread('EightCell.png');
    sprites{9} = imread('MineCell.png');
    sprites{10} = imread('UnknownCell.png');
    sprites{11} = imread('ZeroCell.png');
    sprites{12} = imread('FlagCell.png');
    
    %Get the screensize and figure size
    screenSize = get(0, 'ScreenSize');
    %44x44 for full size
    figureSize = [minefieldDim(2) * multiplier*44, minefieldDim(1) * multiplier*44];
    
    %Get the centered offset for the figure window
    xpos = (screenSize(3)-figureSize(1))/2;
    ypos = (screenSize(4)-figureSize(2))/2;
    
    figure('Position', [xpos, ypos, figureSize(1), figureSize(2)], ...  %Center and size the figure window
           'Name', 'MineSolver', 'NumberTitle', 'off', ...              %Set figure title
           'Resize', 'off', ...
           'Toolbar', 'none', ...
           'Menubar', 'none');
       
    hold('on');
    axis([0, minefieldDim(2)*35, 0, minefieldDim(1)*35]);
    axis('off');
end

function settings = getSettings()

    load('lastSettings', 'settings');
    
    %Set the defaults to the last settings if they exist
    if logical(exist('settings', 'var')) && size(settings,1) == 1 && size(settings,2) == 3
        defaults = {settings{1}, settings{2}, settings{3}};
    else
        defaults = {'16', '30', '99'};
    end
    
    %Set up the prompt for the menu
    prompt = {'Enter the desired number of rows:', ...
              'Enter the desired number of columns:', ...
              'Enter the desired number of mines:'};
          
    %Set the title      
    title = 'Settings';
    
    %Get the settings
    settings = inputdlg(prompt, title, 1, defaults);
            
    %Save those settings as the last known settings
    save('lastSettings', 'settings');
end
