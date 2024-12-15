function [rsc,vsc,finalDate] = spacecraft2(initialDate)
%function [rsc,vsc,finalDate] = spacecraft(initialDate)
%This is a placeholder function. The spacecraft stays on Earth.
%% Initialize
mu=1.327e11; %Gravitational parameter for Sun
maxDays=3000; % Number of days to follow the spaceraft
dsmDay = 400; 
fbday1 =  796;
rsc=zeros(maxDays,3); % Position vector array for spacecraft
vsc=zeros(maxDays,3); % Velocity vector array for spacecraft
finalDate=initialDate+days(maxDays); %date when sc stops appearing in simulation
launchDay=1; % # of days to launch Not used in this function
tinit=datetime(initialDate); %date format
%% Stay on Earth until day of launch
for dayCount=1:launchDay
t=tinit+days(dayCount-1); % index dayCount=1 corresponds to initial time.
[y,m,d]=ymd(t); % year month day format of current time
% Use planet_elements_and_sv_coplanar to find current position and
% velocity
[~, r, v, ~] =planet_elements_and_sv_coplanar ...
(1.327e11, 3, y, m, d, 0, 0, 0);
% Update the position and velocity vectors
rsc(dayCount,:)=[r(1),r(2),0];
vsc(dayCount,:)=[v(1), v(2),0];
end
%% Launch Maneuver
    t=tinit+days(launchDay);
    [y,m,d]=ymd(t);
    [~, R, V, ~] =planet_elements_and_sv_coplanar ...
    (1.327e11, 3, y, m, d, 0, 0, 0); %Earth on launch day

    % A rough possible value for the heliocentric velocity change is used
    % below. Can be improved through trial and error
    
    Vsc = V + 5.3*V/norm(V); 
   
    % Calculate the orbital elements for spacecraft
    [h,a,e,w,E0]=scElements(R,Vsc);

    % new orbit for spacecraft. Propagate until the day DSM is executed
    % (dsmDay defined above).
    [rsc,vsc]=propagate(h,a,e,w,E0,launchDay+1,dsmDay,rsc,vsc);

    % On dsmDay we will do a retrograde burn say
Vsc = vsc(dsmDay,:); %velocity on dsmDay
R = rsc(dsmDay,:); %Position vector on dsmDay
Vsc=Vsc - 1*Vsc/norm(Vsc); % Decrease velocity. Experiment with magnitude of Delta V here.
% Determine orbital elements of resulting trajectory
[h,a,e,w,E0]=scElements(R,Vsc);
%propagate until interception of Earth fbday1 (defined above but can
%change)
[rsc,vsc]=propagate(h,a,e,w,E0,dsmDay+1,fbday1,rsc,vsc);

 
 
% Load flyby data from app
load 1stFlyByEarth2.mat

% Calculate the velocity after the flyby
[Vsc1,DeltaMin]=flyby(Vp1,V1,11000,3.986e5,6.378e3,1);
DeltaMin %Can output Deltamin to keep the aiming radius above this value
%Calculate the orbital elements for the spacecraft after the flyby
[h,a,e,w,E0]=scElements(R1,Vsc1);
%propagate orbit to end
[rsc,vsc]=propagate(h,a,e,w,E0,fbday1+1,maxDays,rsc,vsc);
