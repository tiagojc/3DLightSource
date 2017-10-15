%function in set gauges code to perform gauges setting
performUserTest('spie-01.jpg',100,[0 0 0])

% Procedures to estimate light source position
estimateDisturbedLightSourceRawData('spie01',20000,0.6);
filterRawData('users-tests-spie02-20000',2);
calculateProbabilityMap('users-tests-spie02-20000',15,25,180,0.99);
expContours('users-tests-spie02-20000',99)
expContoursMultipleObjects('combination')