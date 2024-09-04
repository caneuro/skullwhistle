
% start SPM12 /or/ load defaults
spm('defaults','fmri');
spm_jobman('initcfg');

% runs
%--------------------------------------------------------------------------
run = {...
    'run01';...
    'run02';...
    'run03';...
    'run04';...
    };


% subjects
%--------------------------------------------------------------------------
subj = {...
    'sw01';...
    'sw02';...
    'sw03';...
    'sw04';...
    'sw05';...
    'sw06';...
    'sw07';...
    'sw08';...
    'sw09';...
    'sw10';...
    'sw11';...
    'sw12';...
    'sw13';...
    'sw14';...
    'sw15';...
    'sw16';...
    'sw17';...
    'sw18';...
    'sw19';...
    'sw20';...
    'sw21';...
    'sw22';...
    'sw23';...
    'sw24';...
    'sw25';...
    'sw26';...
    'sw27';...
    'sw28';...
    'sw29';...
    'sw30';...
    'sw31';...
    'sw32';...
    };



% define: design
%--------------------------------------------------------------------------
    for s = 1:size(subj,1)
        cd(RESdir{1,s})
        
        % scan settings
        TR      = 1.6;
        TE      = 0.030;
        nslices = 28;
        
        % directory
        matlabbatch = [];
        matlabbatch{1}.spm.stats.fmri_spec.dir            = cellstr(RESdir{1,s});
        matlabbatch{1}.spm.stats.fmri_spec.timing.units   = 'secs';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT      = TR;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t  = 24;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 12;
        
        for temp = 1:size(run,1)
            matlabbatch{1}.spm.stats.fmri_spec.sess(temp).scans = ima{temp,s};
        end
        
        condition = {...
            'dea_hig';...
            'dea_low';...
            'dea_med';...
            'anc';...
            
            'baby';...
            'scream';...
            'speech';...
            'whisper';...
            
            'monkey';...
            'reptile';...
            'mammal';...
            'bird';...
            
            'alarm';...
            'tools';...
            'vehicles';...
            'synthetic';...
            
            'wind';...
            'thunder';...
            'fire_crack';...
            'water';...
            
            'azt';...
            'brass';...
            'wood';...
            'string';...
            
            'noise';...
            
            'rep';...
            };
        
        for temp = 1:size(run,1)
            for c = 1:size(condition,1)
                matlabbatch{1}.spm.stats.fmri_spec.sess(temp).cond(1,c).name     = condition{c,1};
                matlabbatch{1}.spm.stats.fmri_spec.sess(temp).cond(1,c).onset    = ons{temp,c,s};
                matlabbatch{1}.spm.stats.fmri_spec.sess(temp).cond(1,c).duration = dur{temp,c,s};
                matlabbatch{1}.spm.stats.fmri_spec.sess(temp).cond(1,c).tmod     = 0;
                matlabbatch{1}.spm.stats.fmri_spec.sess(temp).cond(1,c).pmod     = struct([]);
            end
            matlabbatch{1}.spm.stats.fmri_spec.sess(temp).multi     = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(temp).regress   = struct([]);
            matlabbatch{1}.spm.stats.fmri_spec.sess(temp).hpf       = 128;
            matlabbatch{1}.spm.stats.fmri_spec.sess(temp).multi_reg = cellstr(spm_select('FPlist',pwd,['mov_reg_short_',num2str(temp),'.txt']));
        end
        
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{1}.spm.stats.fmri_spec.fact             = struct([]);
        matlabbatch{1}.spm.stats.fmri_spec.volt             = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global           = 'None'; % 'None', 'Scaling'
        matlabbatch{1}.spm.stats.fmri_spec.cvi              = 'AR(1)';
        matlabbatch{1}.spm.stats.fmri_spec.mthresh          = 0.8; % default: 0.8
        matlabbatch{1}.spm.stats.fmri_spec.mask             = {''};
        
        save design matlabbatch
        design{s} = [pwd,'/design.mat'];
    end
end

% run: design
for t = 1:size(type,1)
    parfor s = 1:size(subj,1)
        cd(RESdir{1,s})
        temp = [];
        temp = load(design{s});
        spm_jobman('run'emp.matlabbatch);
    end
end


% define: estimate
%--------------------------------------------------------------------------
for t = 1:size(type,1)
    for s = 1:size(subj,1)
        cd(RESdir{1,s})
        matlabbatch = [];
        matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
        matlabbatch{1}.spm.stats.fmri_est.spmmat           = {[pwd,'/SPM_'ype{t,1},'.mat']};        
        save estimate matlabbatch
        estimate{s} = [pwd,'/estimate.mat'];
    end
end

% run: estimate
for t = 1:size(type,1)
    parfor s = 1:size(subj,1)
        cd(RESdir{1,s}); disp(subj{s,1});
        temp = [];
        temp = load(estimate{s});
        spm_jobman('run'emp.matlabbatch);
    end
end


% define: T contrasts
%--------------------------------------------------------------------------
clear contrasts
for t = 1:size(type,1)
    for s = 1:size(subj,1)
        cd(RESdir{1,s}); disp(subj{s});
        cname = [];
        cons  = [];
        matlabbatch = [];
        for c = 1:size(condition,1)
            temp = [];
            temp = zeros(1,size(condition,1));
            temp(1,c) = 1;
            cons{c}  = repmat([temp zeros(1,6)],1,size(run,1));
            cname{c}  = condition{c,1};
        end
        
        cname{size(condition,1)+1} = 'sw_base';
        cname{size(condition,1)+2} = 'sw_rest';
        cons{size(condition,1)+1}  = repmat([ones(1,4) zeros(1,21)  zeros(1,6)],1,size(run,1));
        cons{size(condition,1)+2}  = repmat([ones(1,4)/4 -ones(1,21)/21  zeros(1,6)],1,size(run,1));
        
        for j = 1:size(cons,2)
            matlabbatch{1}.spm.stats.con.consess{j}.tcon.name    = cname{j};
            matlabbatch{1}.spm.stats.con.consess{j}.tcon.convec  = cons{j};
            matlabbatch{1}.spm.stats.con.consess{j}.tcon.sessrep = 'none';
        end
        matlabbatch{1}.spm.stats.con.spmmat = {[pwd,'/SPM_'ype{t,1},'.mat']};
        matlabbatch{1}.spm.stats.con.delete = 0;
        save contrasts matlabbatch
        contrasts{s} = [pwd,'/contrasts.mat'];
    end
end

% run: T contrasts
for t = 1:size(type,1)
    parfor s = 1:size(subj,1)
        cd(RESdir{1,s}); disp(subj{s,1});
        temp = [];
        temp = load(contrasts{s});
        spm_jobman('run'emp.matlabbatch);
    end
end


