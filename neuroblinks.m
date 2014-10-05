% Set up environment and launch app based on which version you want to use
function neuroblinks(varargin)

    DEFAULTDEVICE = 'arduino';
    DEFAULTRIG = 1;

    ALLOWEDDEVICES = {'arduino','tdt'};
    ALLOWEDCAMS = {'02-2020C-07321','02-2020C-07420'};

    % Set up devaults in case user doesn't specify all options
    device = DEFAULTDEVICE;
    rig = DEFAULTRIG;

    % Input parsing
    if nargin > 0
        for i=1:nargin
            if any(strcmpi(varargin{i},ALLOWEDDEVICES))
                device = varargin{i};
            elseif ismember(varargin{i},1:length(ALLOWEDCAMS))
                rig = varargin{i}; 
            end
        end
    end

    % fprintf('Device: %s, Rig: %d\n', device, rig);
    % return

    % Matlab is inconsistent in how it numbers cameras so we need to explicitely search for the right one
    disp('Finding cameras...')

    % Get list of configured cameras
    foundcams = imaqhwinfo('gige');
    founddeviceids = cell2mat(foundcams.DeviceIDs); 

    if isempty(founddeviceids)
        error('No cameras found')
    end
 
    cam = 0;
    for i=length(founddeviceids)
        vidobj = videoinput('gige', founddeviceids(i), 'Mono8');
        src = getselectedsource(vidobj);
        if strcmp(src.DeviceID,ALLOWEDCAMS{rig})
            cam = i;
        end
    end

    if ~cam
        error(sprintf('The camera you specified (%d) could not be found',rig));
    end

    try 
        switch lower(device)
            case 'tdt'
                % TDT version
                % Set up path for this session
                [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
                oldpath=addpath(genpath(fullfile(basedir,'TDT')));
                addpath(genpath(fullfile(basedir,'Shared')));

            case 'arduino'

                % % Arduino version
                % % Set up path for this session
                [basedir,mfile,ext]=fileparts(mfilename('fullpath'));
                oldpath=addpath(genpath(fullfile(basedir,'Arduino')));
                addpath(genpath(fullfile(basedir,'Shared')));

            otherwise
                error(sprintf('Device %s not found', device))

        end
    catch
        error('You did not specify a valid device');
    end
   
    % A different "launch" function should be called depending on whether we're using TDT or Arduino
    % and will be determined by what's in the path generated above
    Launch(rig,cam)