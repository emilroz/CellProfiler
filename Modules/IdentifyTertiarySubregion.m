function handles = IdentifyTertiarySubregion(handles)

% Help for the Identify Tertiary Subregion module:
% Category: Object Processing
%
% This module will take the identified objects specified in the first
% box and remove from them the identified objects specified in the
% second box. For example, "subtracting" the nuclei from the cells
% will leave just the cytoplasm, the properties of which can then be
% measured by Measure modules. The first objects should therefore be
% equal in size or larger than the second objects and must completely
% contain the second objects.  Both images should be the result of a
% segmentation process, not grayscale images. Note that creating
% subregions using this module can result in objects that are not
% contiguous, which does not cause problems when running the Measure
% Intensity and Texture module, but does cause problems when running
% the Measure Area Shape Intensity Texture module because calculations
% of the perimeter, aspect ratio, solidity, etc. cannot be made for
% noncontiguous objects.
%
% SAVING IMAGES: In addition to the object outlines and the
% pseudo-colored object images that can be saved using the
% instructions in the main CellProfiler window for this module, this
% module produces a grayscale image where each object is a different
% intensity, which you can save using the Save Images module using the
% name: Segmented + whatever you called the objects (e.g.
% Cytoplasm).
%
% Additional image(s) are normally calculated for display only,
% including the object outlines alone. These images can be saved by
% altering the code for this module to save those images to the
% handles structure (see the SaveImages module help) and then using
% the Save Images module.%
% See also identify Primary and Identify Secondary modules.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Authors:
%   Anne Carpenter <carpenter@wi.mit.edu>
%   Thouis Jones   <thouis@csail.mit.edu>
%   In Han Kang    <inthek@mit.edu>
%
% $Revision$

%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%
drawnow

%%% Reads the current module number, because this is needed to find
%%% the variable values that the user entered.
CurrentModule = handles.Current.CurrentModuleNumber;
CurrentModuleNum = str2double(CurrentModule);
ModuleName = char(handles.Settings.ModuleNames(CurrentModuleNum));

%textVAR01 = What did you call the larger identified objects?
%infotypeVAR01 = objectgroup
SecondaryObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,1});
%inputtypeVAR01 = popupmenu

%textVAR02 = What did you call the smaller identified objects?
%infotypeVAR02 = objectgroup
PrimaryObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,2});
%inputtypeVAR02 = popupmenu

%textVAR03 = What do you want to call the new subregions?
%defaultVAR03 = Cytoplasm
%infotypeVAR03 = objectgroup indep
SubregionObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,3});

%textVAR04 =  What do you want to call the labeled matrix image?
%defaultVAR04 = Do not save
%infotypeVAR04 = imagegroup indep
SaveColored = char(handles.Settings.VariableValues{CurrentModuleNum,4}); 

%textVAR05 = Would you like to save the outlines of the objects?
%defaultVAR05 = OutlineBlue
%infotypeVAR05 = outlinegroup indep
SaveOutlines = char(handles.Settings.VariableValues{CurrentModuleNum,5}); 

%%%VariableRevisionNumber = 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Reads (opens) the image you want to analyze and assigns it to a
%%% variable.
fieldname = ['Segmented', PrimaryObjectName];
%%% Checks whether the image to be analyzed exists in the handles structure.
if isfield(handles.Pipeline, fieldname)==0,
    %%% If the image is not there, an error message is produced.  The error
    %%% is not displayed: The error function halts the current function and
    %%% returns control to the calling function (the analyze all images
    %%% button callback.)  That callback recognizes that an error was
    %%% produced because of its try/catch loop and breaks out of the image
    %%% analysis loop without attempting further modules.
    error(['Image processing was canceled in the ', ModuleName, ' module because it could not find the input image.  It was supposed to be named ', PrimaryObjectName, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
end
PrimaryObjectImage = handles.Pipeline.(fieldname);


%%% Retrieves the Secondary object segmented image.
fieldname = ['Segmented', SecondaryObjectName];
if isfield(handles.Pipeline, fieldname) == 0
    error(['Image processing was canceled in the ', ModuleName, ' module because it could not find the input image.  It was supposed to be named ', SecondaryObjectName, ' but an image with that name does not exist.  Perhaps there is a typo in the name.'])
end
SecondaryObjectImage = handles.Pipeline.(fieldname);

%%% Checks that these images are two-dimensional (i.e. not a color
%%% image), which would disrupt several of the image functions.
if ndims(PrimaryObjectImage) ~= 2
    error(['Image processing was canceled in the ', ModuleName, ' module because it requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.'])
end
if ndims(SecondaryObjectImage) ~= 2
    error(['Image processing was canceled in the ', ModuleName, ' module because it requires an input image that is two-dimensional (i.e. X vs Y), but the image loaded does not fit this requirement.  This may be because the image is a color image.'])
end

%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Erodes the primary object image and then subtracts it from the
%%% secondary object image.  This prevents the subregion from having zero
%%% pixels (which cannot be measured in subsequent measure modules) in the
%%% cases where the secondary object is exactly the same size as the
%%% primary object.
ErodedPrimaryObjectImage = imerode(PrimaryObjectImage, ones(3));
SubregionObjectImage = max(0,SecondaryObjectImage - ErodedPrimaryObjectImage);
       
FinalOutline = bwperim(SubregionObjectImage > 0);

%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%
drawnow

fieldname = ['FigureNumberForModule',CurrentModule];
ThisModuleFigureNumber = handles.Current.(fieldname);

ColoredLabelMatrixImage = CPlabel2rgb(handles,SubregionObjectImage);
SecondaryObjectImage = CPlabel2rgb(handles,SecondaryObjectImage);
PrimaryObjectImage = CPlabel2rgb(handles,PrimaryObjectImage);

drawnow

%%% Activates the appropriate figure window.
CPfigure(handles,ThisModuleFigureNumber);

subplot(2,2,1); imagesc(PrimaryObjectImage);
title([PrimaryObjectName, ' Image, Image Set # ',num2str(handles.Current.SetBeingAnalyzed)]);

subplot(2,2,2); imagesc(SecondaryObjectImage);
title([SecondaryObjectName, ' Image']);

subplot(2,2,3); imagesc(ColoredLabelMatrixImage);
title([SubregionObjectName, ' Image']);

subplot(2,2,4); imagesc(FinalOutline);
title([SubregionObjectName, ' Outlines']);

CPFixAspectRatio(PrimaryObjectImage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

%%% Saves the final, segmented label matrix image of secondary objects to
%%% the handles structure so it can be used by subsequent modules.
fieldname = ['Segmented', SubregionObjectName];
handles.Pipeline.(fieldname) = SubregionObjectImage;

%%% Saves the ObjectCount, i.e. the number of segmented objects.
%%% See comments for the Threshold saving above
if ~isfield(handles.Measurements.Image,'ObjectCountFeatures')
    handles.Measurements.Image.ObjectCountFeatures = {};
    handles.Measurements.Image.ObjectCount = {};
end
column = find(~cellfun('isempty',strfind(handles.Measurements.Image.ObjectCountFeatures,SubregionObjectName)));
if isempty(column)
    handles.Measurements.Image.ObjectCountFeatures(end+1) = {['ObjectCount ' SubregionObjectName]};
    column = length(handles.Measurements.Image.ObjectCountFeatures);
end
handles.Measurements.Image.ObjectCount{handles.Current.SetBeingAnalyzed}(1,column) = max(SubregionObjectImage(:));


%%% Saves the location of each segmented object
handles.Measurements.(SubregionObjectName).LocationFeatures = {'CenterX','CenterY'};
tmp = regionprops(SubregionObjectImage,'Centroid');
Centroid = cat(1,tmp.Centroid);
handles.Measurements.(SubregionObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};

if ~strcmp(SaveOutlines,'Do Not Save')
    handles.Pipeline.(SaveOutlines) = FinalOutline;
end