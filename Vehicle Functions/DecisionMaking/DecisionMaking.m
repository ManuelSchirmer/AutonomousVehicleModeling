classdef DecisionMaking < matlab.System & handle & matlab.system.mixin.Propagates & matlab.system.mixin.SampleTime & matlab.system.mixin.CustomIcon
% Select driving mode and decide if to execute lane changing maneuver 

% Driving Mode
%   1 = FreeDrive
%   2 = VehicleFollowing
%   3 = EmergencyBrake

% Change Lane Cmd
%   0 = Command to follow current trajectory (left lane, right lane, lane change)
%   1 = Command to start changing to left lane
%  -1 = Command to start changing to right lane

    properties(Nontunable)
        vEgo_ref % Reference velocity for ego vehicle [m/s]
        
        LaneWidth % Width of road lane [m]
        RoadTrajectory % Road trajectory according to MOBATSim map format
        Ts % Sample time [s]
    end
    
    % Pre-computed constants
    properties(Access = protected)
        drivingModes % Possible driving modes
        laneChangeCmds % Possible commands for lane changing
        plannerModes % Possible planner modes
        
        states % Possible driving states
        currentState % Current driving state
        previousState % Previous driving state
        
        toleranceReachLane % Accepted tolerance to reach destination lane
        
        waitingCounter % Counter to wait some time before recheck for lane changing
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.drivingModes = ...
                containers.Map({'FreeDrive', 'VehicleFollowing', 'EmergencyBrake'}, [1, 2, 3]);
            
            obj.laneChangeCmds = ...
                containers.Map({'CmdIdle', 'CmdStartToLeftLane', 'CmdStartToRightLane'}, [0, 1, -1]);
            
            obj.plannerModes = ...
                containers.Map({'MANUAL', 'FORMAL'}, [1, 2]);
            
            obj.toleranceReachLane = 0.05;
            
            obj.waitingCounter = 0;
        end
        
        function displayNewState(obj, currentState, previousState)
        % Display state name if switched to another state
            
            if currentState ~= previousState
                newState = currentState;
                
                stateNames = keys(obj.states);
                % https://www.mathworks.com/matlabcentral/answers/98444-how-can-i-retrieve-the-key-which-belongs-to-a-specified-value-using-the-array-containers-map-in-matl
                id = cellfun(@(x) isequal(x, newState), values(obj.states));
                
                key_newState = stateNames(id);
                name_newState = key_newState{:};
                
                t = get_param('VehicleFollowing', 'SimulationTime');
                
                fprintf('@t=%fs: Switched to State: ''%s''.\n', t, name_newState);
            end
        end
    end
end
