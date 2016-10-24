function [stim] = create_stim_control(indir,exp)
% Returns stimulus list required for intended experiment

% USAGE
%-------
%   stimuli = create_stim_control(indir,exp)
%
% PARAMETERS
%------------
%   indir :  Name of directory where images reside
%   exp : Experiment handle (eg: 'Exp1' or 1) 
%
% RETURNS
%---------
%   stim appropriate for the experiment

% Created - 08/09/2016
% Modified - 08/09/2016
% chauhan.vassiki@gmail.com

if nargin < 2
    error('Stimulus Directory and Experiment Number Required')
end

%indir = '/Users/vassiki/Desktop/CatPercep';


switch exp
    case {'Exp1',1}
        % Face Scanning Experiment
        imdir = fullfile(indir,'orig_id');
        
        origs = extractfield(dir(imdir),'name');
        origs = origs(cellfun('isempty',strfind(origs,'.')));
        
        fam = cell(length(origs),1);
        unfam = cell(length(origs),1);
        for idx=1:length(origs)
            curdir = fullfile(imdir,origs{idx});
            all_ims = extractfield(dir(curdir),'name');
            fam{idx}.name = all_ims{~cellfun('isempty',strfind(all_ims,'100'))};
            fam{idx}.image = imread(fullfile(curdir,fam{idx}.name));
            fam{idx}.dir = curdir;
            unfam{idx}.name = all_ims{~cellfun('isempty',strfind(all_ims,'0'))};
            unfam{idx}.image = imread(fullfile(curdir,unfam{idx}.name));
            unfam{idx}.dir = curdir;
        end
        stim.Fam = fam;
        stim.UnFam = unfam;
        
    case {'Exp2',2}
        % Biasing Identity Perception
        imdir = fullfile(indir,'morph_pairs');
        
        pair_ims = extractfield(dir(imdir),'name');
        pair_ims = pair_ims(cellfun('isempty',strfind(pair_ims, '.')));
        
        morphs = {'10','30','50','70','90'};

        ims = cell(length(pair_ims),length(morphs));
        for pair=1:length(pair_ims)
            curdir = fullfile(imdir,pair_ims{pair});
            for m=1:length(morphs)
                all_ims = extractfield(dir(curdir),'name');
                ims{pair,m}.name = all_ims{~cellfun('isempty',strfind(all_ims,morphs{m}))};
                ims{pair,m}.image = imread(fullfile(curdir,ims{pair,m}.name));  
                ims{pair,m}.dir = curdir;
            end
        end
        
        stim.ReFam = ims(:,[4,5]);
        stim.ReUnFam = ims(:,[2,1]);
        stim.AmbFam = ims(:,[4,3]);
        stim.AmbUnFam = ims(:,[2,3]);
        stim.CatFam = ims(:,[4,4]);
        stim.CatUnFam = ims(:,[2,2]);
        
    case {'Exp3',3}
        % Categorical Perception Curve
        imdir = fullfile(indir,'morph_pairs_control');
        
        pair_ims = extractfield(dir(imdir),'name');
        pair_ims = pair_ims(cellfun('isempty',strfind(pair_ims, '.')));
        
        morphs = {'10','20','30','40','50','60','70','80','90'};
        
        ims = cell(length(pair_ims),length(morphs));
        for pair=1:length(pair_ims)
            curdir = fullfile(imdir,pair_ims{pair});
            for m=1:length(morphs)
                all_ims = extractfield(dir(curdir),'name');
                ims{pair,m}.name = all_ims{~cellfun('isempty',strfind(all_ims,morphs{m}))};
                ims{pair,m}.image = imread(fullfile(curdir,ims{pair,m}.name));
                ims{pair,m}.dir = curdir;
            end
        end
        stim.mp10 = ims(:,1);
        stim.mp20 = ims(:,2);
        stim.mp30 = ims(:,3);
        stim.mp40 = ims(:,4);
        stim.mp50 = ims(:,5);
        stim.mp60 = ims(:,6);
        stim.mp70 = ims(:,7);
        stim.mp80 = ims(:,8);
        stim.mp90 = ims(:,9);
end
end
