function [indir,outdir] = set_Exp_control(Subject,Block,Exp)
% Creates input and output directories for the subject, and puts in csv for
%   each block to indicate which stimuli to use
%
% USAGE
%-------
%   set_Exp(Subject,Block,Experiment)
%
% PARAMETERS
%------------
%   Subject : Subject Number
%   Block : Block Number
%   Experiment : 'Exp1' or 'Exp2' or 'Exp3'
%
% RETURNS
%---------
%   Input and Output directories

% Created - 07/15/2016
% Modified - 08/09/2016
% chauhan.vassiki@gmail.com

stimdir = pwd;
indir = fullfile(pwd,['Sub',num2str(Subject)],'Input');
outdir = fullfile(pwd,['Sub',num2str(Subject)],'Output');

if ~exist(stimdir,'dir')
    error('Stimulus Directory does not exist')
end

if ~exist(indir,'dir')
    mkdir(indir);
end

if ~exist(outdir,'dir')
    mkdir(outdir);
end
Exp = 'Exp3';
stim = create_stim_control(stimdir,Exp);

switch Exp
    case {'Exp1',1}
        Fimnames = cellfun(@(x) extractfield(x,'name'),stim.Fam);
        Fdirnames = cellfun(@(x) extractfield(x,'dir'),stim.Fam);
        Fcond = repmat({'Fam'},[length(Fimnames),1]);
        UFimnames = cellfun(@(x) extractfield(x,'name'),stim.UnFam);
        UFdirnames = cellfun(@(x) extractfield(x,'dir'),stim.UnFam);
        UFcond = repmat({'UnFam'},[length(UFimnames),1]);
        
        Names = [[Fimnames;UFimnames],[Fdirnames;UFdirnames],[Fcond;UFcond]];
        for idx=1:length(Names)
            face = Names{idx,1};
            face_id{idx,1} = face(1:2);
        end
        
        Names = [Names,face_id];
        
        %         f1_idx =  ~cellfun(@isempty,regexp(face_id,'f1'));
        %         f1_idx = find(f1_idx);
        %         f1 = Names(f1_idx,:);
        %         f1 = Shuffle(f1,2);
        
        f2_idx =  ~cellfun(@isempty,regexp(face_id,'f2'));
        f2_idx = find(f2_idx);
        f2 = Names(f2_idx,:);
        f2 = Shuffle(f2,2);
        
        m1_idx = ~cellfun(@isempty,regexp(face_id,'m1'));
        m1_idx = find(m1_idx);
        m1 = Names(m1_idx,:);
        m1 = Shuffle(m1,2);
        
        m2_idx = ~cellfun(@isempty,regexp(face_id,'m2'));
        m2_idx = find(m2_idx);
        m2 = Names(m2_idx,:);
        m2 = Shuffle(m2,2);
        
        out = [];
        %counter = {f1,f2,m1,m2};
        counter = {f2,m1,m2};
        counter = Shuffle(counter);
        
        reps = 4;
        
        for rep=1:reps
            iter = 1;
            for i=1:length(f2_idx)
                for col=1:length(counter{1,1}(1,:))
                    new{f2_idx(i),col} = counter{1,1}{iter,col};
                    new{f2_idx(i)+1,col} = counter{1,2}{iter,col};
                    new{f2_idx(i)+2,col} = counter{1,3}{iter,col};
                    %new{f1_idx(i)+3,col} = counter{1,4}{iter,col};
                end
                iter = iter+1;
                counter = Shuffle(counter);
            end
            
            out = vertcat(out,new);
            clear new;
        end
        
        % make sure there are no repetitions at all
        flag_idx = 1;
        while ~isempty(flag_idx)
            for x=2:length(out)
                if strncmp(out{x,4},out{x-1,4},2)
                    flag(x,1) = 1;
                else
                    flag(x,1) = 0;
                end
            end
            flag_idx = find(flag==1);
            
            for idx = 1:length(flag_idx)
                tmp = out(flag_idx(idx),:);
                out(flag_idx(idx),:) = out(flag_idx(idx)+1,:);
                out(flag_idx(idx)+1,:) = tmp;
            end
        end
        
        Stim = out;
    case {'Exp2',2}
        
        % get conditions for the experiment
        conditions = fieldnames(stim);
        
        out = [];
        for c = 1:length(conditions)
            vals = stim.(conditions{c});
            
            for i = 1:length(vals)
                array{i,1} = vals{i,1}.name;
                array{i,2} = 'first';
                array{i,3} = vals{i,1}.dir;
                array{i,4} = vals{i,2}.name;
                array{i,5} = 'second';
                array{i,6} = vals{i,2}.dir;
            end
            
            [r,col] = size(array);
            last_col = repmat({conditions{c}},[r,1]);
            array = [array,last_col];
            
            out = vertcat(out,array);
            clear array;
        end
        
        % stimulus condition
        for idx=1:length(out)
            face = out{idx,1};
            face_id{idx,1} = face(1:2);
        end
        out = [out,face_id];
        
        % main conditions and control conditions
        main = out(1:12,:);
        control = out(13:18,:);
        
        face_id = face_id(1:12);
        
        % unique cells for unique faces
        %         f1_idx =  ~cellfun(@isempty,regexp(face_id,'f1'));
        %         f1_idx = find(f1_idx);
        %         f1 = main(f1_idx,:);
        %         f1 = Shuffle(f1,2);
        
        f2_idx =  ~cellfun(@isempty,regexp(face_id,'f2'));
        f2_idx = find(f2_idx);
        f2 = main(f2_idx,:);
        f2 = Shuffle(f2,2);
        
        m1_idx = ~cellfun(@isempty,regexp(face_id,'m1'));
        m1_idx = find(m1_idx);
        m1 = main(m1_idx,:);
        m1 = Shuffle(m1,2);
        
        m2_idx = ~cellfun(@isempty,regexp(face_id,'m2'));
        m2_idx = find(m2_idx);
        m2 = main(m2_idx,:);
        m2 = Shuffle(m2,2);
        
        out = [];
        % counter = {f1,f2,m1,m2};
        counter = {f2,m1,m2};
        counter = Shuffle(counter);
        
        
        % entering faces to minimize repetitions
        reps = 3;
        for rep=1:reps
            iter = 1;
            for i=1:length(f2_idx)
                for col=1:length(counter{1,1}(1,:))
                    new{f2_idx(i),col} = counter{1,1}{iter,col};
                    new{f2_idx(i)+1,col} = counter{1,2}{iter,col};
                    new{f2_idx(i)+2,col} = counter{1,3}{iter,col};
                    %new{f1_idx(i)+3,col} = counter{1,4}{iter,col};
                end
                iter = iter+1;
                counter = Shuffle(counter);
            end
            
            out = vertcat(out,new);
            clear new;
        end
        
        % inserting catch trials
        num_reps = 0.05;
        reps = round(num_reps*length(out));
        
        % Space the repetitions evenly to begin with
        repeat = 1:round(length(out)/reps):length(out);
        
        % Choose a jitter that avoids overlap between repetitions
        mid_rep = floor((repeat(2)-repeat(1))/3);
        jitter = -mid_rep:mid_rep;
        jitter = datasample(jitter,length(repeat),'Replace',true);
        
        % jitter the repetition indices-ceil to avoid 0 subscript
        repetition = abs(repeat + jitter);
        if repetition(1) == 0
            repetition(1) = randi([1 mid_rep]);
        end
        if repetition(end) == 36
            repetition(end) = 34;
        end
        clear reps;
        
        insert = @(array,val,index)cat(1,array(1:index,:),val,array(index+1:end,:));
        
        for i=1:length(repetition)
            
            catch_trial = datasample(control,1);
            
            out = insert(out,catch_trial,repetition(i));
        end
        
        % make sure there are no repetitions at all
        flag_idx = 1;
        while ~isempty(flag_idx)
            for x=2:length(out)
                if strncmp(out{x,8},out{x-1,8},2)
                    flag(x,1) = 1;
                else
                    flag(x,1) = 0;
                end
            end
            flag_idx = find(flag==1);
            
            for idx = 1:length(flag_idx)
                tmp = out(flag_idx(idx),:);
                out(flag_idx(idx),:) = out(flag_idx(idx)+1,:);
                out(flag_idx(idx)+1,:) = tmp;
            end
        end
        
        Stim = out;
        
    case {'Exp3',3}
        stim = create_stim_control(pwd,'Exp3');
        
        conditions = fieldnames(stim);
        
        out = [];
        for c = 1:length(conditions)
            vals = stim.(conditions{c});
            
            for i = 1:length(vals)
                array{i,1} = vals{i,1}.name;
                array{i,2} = vals{i,1}.dir;
            end
            
            [r,col] = size(array);
            last_col = repmat({conditions{c}},[r,1]);
            array = [array,last_col];
            
            out = vertcat(out,array);
            clear array;
        end
        
        for idx=1:length(out)
            face = out{idx,1};
            face_id{idx,1} = face(1:2);
        end
        
        out = [out,face_id];
        
        for i=1:length(out)
            out{i,5} = 'left';
        end
        
        right_out = out;
        for i=1:length(out)
            right_out{i,5} = 'right';
        end
        
        allout = [out;right_out];
        out = allout;
        
        for idx=1:length(out)
            face = out{idx,1};
            face_id{idx,1} = face(1:2);
        end
        %         f1_idx =  ~cellfun(@isempty,regexp(face_id,'f1'));
        %         f1_idx = find(f1_idx);
        %         f1 = out(f1_idx,:);
        %         f1 = Shuffle(f1,2);
        
        f2_idx =  ~cellfun(@isempty,regexp(face_id,'f2'));
        f2_idx = find(f2_idx);
        f2 = out(f2_idx,:);
        f2 = Shuffle(f2,2);
        
        m1_idx = ~cellfun(@isempty,regexp(face_id,'m1'));
        m1_idx = find(m1_idx);
        m1 = out(m1_idx,:);
        m1 = Shuffle(m1,2);
        
        m2_idx = ~cellfun(@isempty,regexp(face_id,'m2'));
        m2_idx = find(m2_idx);
        m2 = out(m2_idx,:);
        m2 = Shuffle(m2,2);
        
        out = [];
        %counter = {f1,f2,m1,m2};
        counter = {f2,m1,m2};
        counter = Shuffle(counter);
        
        % entering faces to minimize repetitions
        reps = 2;
        for rep=1:reps
            iter = 1;
            for i=1:length(f2_idx)
                for col=1:length(counter{1,1}(1,:))
                    new{f2_idx(i),col} = counter{1,1}{iter,col};
                    new{f2_idx(i)+1,col} = counter{1,2}{iter,col};
                    new{f2_idx(i)+2,col} = counter{1,3}{iter,col};
                    %new{f2_idx(i)+3,col} = counter{1,4}{iter,col};
                end
                iter = iter+1;
                counter = Shuffle(counter);
            end
            
            out = vertcat(out,new);
            clear new;
        end
        flag_idx = 1;
        while ~isempty(flag_idx)
            for x=2:length(out)
                if strncmp(out{x,4},out{x-1,4},2)
                    flag(x,1) = 1;
                else
                    flag(x,1) = 0;
                end
            end
            flag_idx = find(flag==1);
            
            for idx = 1:length(flag_idx)
                tmp = out(flag_idx(idx),:);
                out(flag_idx(idx),:) = out(flag_idx(idx)+1,:);
                out(flag_idx(idx)+1,:) = tmp;
            end
        end
        
        Stim = out;
end
input_filename = [Exp,'_S',num2str(Subject),'B',num2str(Block),'_Control','.csv'];
cell2csv(input_filename,Stim);
[SUCCESS,MESSAGE,MESSAGEID] = movefile(fullfile(pwd,input_filename),...
    fullfile(indir));

end