%> Name: SetParametersCommon
%>
%> Description: Common parameters for CHOP. This file is called when the
%> dataset we are working on does not have its own parameter set.
%>
%> @param datasetName Name of the dataset to work on. 
%> @param options Program options.
%>
%> @retval options Program options.
%> 
%> Author: Rusen
%>
%> Updates
%> Ver 1.0 on 26.08.2014
function [ options ] = SetParametersCommon( datasetName, options )
    %% ========== DATASET - RELATED PARAMETERS ==========
    options.datasetName = datasetName;
    options.learnVocabulary = 1; % If 1, new vocabulary is learned. 
    options.testImages = 1;      % If 1, the test images are processed.
    options.numberOfGaborFilters = 6; % Number of Gabor filters at level 1.
    
        %% ========== LOW - LEVEL FILTER PARAMETERS ==========
    options.filterType = 'gabor'; % 'gabor': Steerable Gabor filters used 
                                  % as low-level feature detectors.
    options.gaborFilterThr = 0.05; % Min response threshold for convolved features, 
                                  % taken as the percentage of max response 
                                  % in each image.
    options.absGaborFilterThr = 0; % Absolute response threshold for low-level 
                                   % responses. ~80 for natural images 
                                   % (depends on many factors though, including 
                                   % size of the filter).
    options.gaborFilterSize = 10;       % Size of a gabor filter. Please note 
                                        % that the size also depends on the 
                                        % filter parameters, so consider them 
                                        % all when you change this!
    options.gabor.sigma = 1;            % Gabor filter parameters
    options.gabor.theta = 0;
    options.gabor.lambda = 1;
    options.gabor.psi = 0;
    options.gabor.gamma = 0.25;
    options.gabor.inhibitionRadius = floor(options.gaborFilterSize/2);
                                        % The inhibition radius basically 
                                        % defines the half of the cube's
                                        % size in which other weaker
                                        % responses than the seed node will
                                        % be surpressed.
    %% ========== GT Parameters ==========
    options.useGT = true;              % If true, gt info is used. 
    options.gtType = 'contour';        % 'contour' type gt: nodes lying under
                                       % the gt contour is examined (within
                                       % a neighborhood defined by
                                       % contourGTNeighborhood). 
                                       % 'bbox' type gt: nodes in the
                                       % gt bounding box are examined.
    options.contourGTNeighborhood = 8;% width of the band along the contour 
                                       % (half width, actual width is
                                       % double this value)  in which nodes
                                       % are examined.

    %% ========== CRUCIAL METHOD PARAMETERS (COMPLEXITY, RELATIONS) ==========
    options.noveltyThr = 0.5;           % The novelty threshold used in the 
                                        % inhibition process. At least this 
                                        % percent of a neighboring node's leaf 
                                        % nodes should be new so that it is 
                                        % not inhibited by another higher-
                                        % valued one.
    options.edgeNoveltyThr = 0.75;       % The novelty threshold used in the 
                                        % edge generation. At least this 
                                        % percent of a neighbor node's leaf 
                                        % nodes should be new so that they 
                                        % are linked in the object graph.
    options.property = 'mode'; % Geometric property to be examined
                                       % 'co-occurence': uniform edges 
                                       % 'mode': clusters of relative positions
                                       % 'hist': divide space into 8 
                                       % pre-defined regions.
    options.mode.maxSamplesPerMode = 200; % In mode calculation between node1
                                          % and node2, not all samples are
                                          % considered. Randomly chosen
                                          % samples are used, defined with
                                          % this number.
    options.mode.minSamplesPerMode = 4;   % The minimum number of samples to 
                                          % be assigned to each mode (avg). If
                                          % there are not enough samples 
                                          % for statistical learning,
                                          % number of modes for that
                                          % specific part pair is reduced
                                          % automatically to match this
                                          % number, if possible.
    options.scaling = 0.5;            % Each successive layer is downsampled 
                                       % with a ratio of 1/scaling. Changes
                                       % formation of edges in upper
                                       % layers, since edge radius
                                       % stays the same while images are 
                                       % downsampled. DEFAULT 0.5.
    options.edgeType = 'centroid';     % If 'centroid', downsampling is
                                       % applied at each layer, and edges
                                       % link spatially adjacent (within
                                       % its neighborhood) nodes. (No other
                                       % opts at the moment)
    options.reconstructionType = 'leaf'; % 'true': Replacing leaf nodes with 
                                         % average node image in image visualization.
                                         % 'leaf': Detected leaf nodes will
                                         % be marked on the image.
    options.imageReconstructionType = 'all'; % If 'individual' type 
                                         % image reconstruction is used,
                                         % each realization is written to a
                                         % different image, along with its
                                         % normalized mdl score. If 'all'
                                         % type image reconstruction is
                                         % used, all realizations are
                                         % written in a single image.
    options.minIndividualReconstructionLevel = 4;   % Minimum image reconstruction 
                                         % level for individual part
                                         % printing. At least 1.
                                         
    options.vis.nodeReconstructionChildren = 1000; % Max number of children
                                         % to be used in the average image
                                         % for every node in the
                                         % vocabulary.
    
    options.receptiveFieldSize = options.gaborFilterSize*5; % DEFAULT 5
                                         % Size (one side) of the receptive field at
                                         % each level. Please note that in
                                         % each level of the hierarchy, the
                                         % coordinates are downsampled, so our
                                         % receptive field indeed grows.
    options.maxNodeDegreeLevel1 = 10;
    options.maxNodeDegree = 10;         % (N) closest N nodes are considered at
                                       % level 1-l, to link nodes via edges.
                                       % UPDATE: If receptive fields are
                                       % used, no max degree is applied.
    options.maxImageDim = options.gaborFilterSize*100; %Max dimension of the 
                                       % images the algorithm will work
                                       % with. If one size of a image in
                                       % the dataset is larger than this
                                       % value, it will be rescaled to fit
                                       % in a square of
                                       % maxImageDim x maxImageDim. Ratio
                                       % will be preserved. Set to a large
                                       % value to avoid rescaling.
    options.maximumModes = 50;          % Maximum number of modes allowed for 
                                       % a node pair in statistical learning.
    options.edgeRadius = floor(options.receptiveFieldSize/2); % The edge radius for two subs to be 
                                       % determined as neighbors. Centroids
                                       % taken into account.
    
    options.maxLevels = 20;    % The maximum level count for training.
    options.maxInferenceLevels = 20; % The maximum level count for testing.
                                    % Please write 1 off.
    options.maxLabelLength = 100; % The maximum label name length allowed.
    
    %% ========== INFERENCE PARAMETERS ==========
    options.fastInference = true; % If set, faster inference (involves 
                                  % inhibition) is performed.
    
    %% ========== KNOWLEDGE DISCOVERY PARAMETERS ==========
                                           % The following metric is valid
                                           % only in 'self' implementation.
    options.subdue.evalMetric = 'mdl';     % 'mdl' or 'size'. 'mdl' takes 
                                           % the relations between
                                           % receptive fields into account,
                                           % while 'size' based metric
                                           % treats each receptive field as
                                           % separate graphs, and evaluates
                                           % subs based on (size x
                                           % frequency).
                                           
    options.subdue.isMDLExact = false;     % If true, exact mdl is calculated.
                                           % Otherwise, approximate mdl is
                                           % calculated (faster).
    options.subdue.mdlNodeWeight = 8;      % Weight of a node in DL calculations 
                                           % in MDL-based evaluation
                                           % metric. Cost of a node =
                                           % labelId (int,4) + pointer to
                                           % edges (int,4) = 8.
    options.subdue.mdlEdgeWeight = 9;      % Weight of an edge in DL calculations 
                                           % in MDL-based evaluation
                                           % metric. Cost of an edge =
                                           % edgeLabelId (int,4) + 
                                           % destinationNode (int,4) + 
                                           % isDirected (byte, 1) = 9.
    options.subdue.maxTime = 3600;           % Max. number of seconds 'self' 
                                            % type implemented subdue is
                                            % run over data. Typically
                                            % around 100 (secs) for toy data. 
                                            % You can set to higher values
                                            % (e.g. 3600 secs) for large
                                            % datasets.
    options.subdue.threshold = 0.05; % Theshold for elastic part matching. 
                                    % Can be in [0,1]. 
                                    % 0: Strict matching, 
                                    % (value -> 1) Matching criterion 
                                    % gets looser.
    options.subdue.minSize = 2; % Minimum number of nodes in a composition 
    options.subdue.maxSize = 3; % Maximum number of nodes in a composition
    options.subdue.nsubs = 10000;  % Maximum number of nodes allowed in a level
    options.subdue.beam = 200;   % Beam length in SUBDUE
    options.subdue.overlap = false;   % If true, overlaps between a substructure's 
                                     % instances are considered in the
                                     % evaluation of the sub. Otherwise,
                                     % unique (in terms of node sets) instances 
                                     % are taken into account [DEFAULT].
                                     % However, all possible instances are
                                     % returned anyway in order to
                                     % introduce redundancy in the final
                                     % object graphs.
end

