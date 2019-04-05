function pseudorange = calculatePseudoranges( ...
                                                 codePhase, ...
                                                settings)


%--- For all channels in the list ... 

    %--- Compute the travel times -----------------------------------------    
    travelTime = ...
        (codePhase/settings.codeLength) * settings.CA_Period ;


%--- Truncate the travelTime and compute pseudoranges ---------------------


%--- Convert travel time to a distance ------------------------------------
% The speed of light must be converted from meters per second to meters
% per millisecond. 
pseudorange   = travelTime * settings.c/2^settings.ncoLength ;
