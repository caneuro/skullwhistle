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


% define: realign
%--------------------------------------------------------------------------
for s = 1:size(subj,1)
    for r = 1:size(run,1)
        cd(RUNdir{s,r});
        matlabbatch = [];
        ima  = [];
        ima  = cellstr(spm_select('FPlist',pwd,'^f.*.nii$'));
        temp = cellstr(repmat(',1',length(ima),1));
        ima  = strcat(ima,temp);
        matlabbatch{1}.spm.spatial.realign.estwrite.data{1,1}        = ima;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp  = 7;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight  = '';
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp  = 7;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask    = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';
        save realign matlabbatch
        realign{s,r} = [pwd,'/realign.mat'];
    end
end

% run: realign
parfor s = 1:size(subj,1)
    for r = 1:size(run,1)
        cd(RUNdir{s,r})
        temp = [];
        temp = load(realign{s,r});
        spm_jobman('run',temp.matlabbatch);
    end
end


% define: slicetime
%--------------------------------------------------------------------------
for s = 1:size(subj,1)
    for r = 1:size(run,1)
        cd(RUNdir{s,r})
        matlabbatch = [];
        matlabbatch{1}.spm.temporal.st.scans{1} = cellstr(spm_select('FPlist',pwd,'^rf.*.nii$'));
        matlabbatch{1}.spm.temporal.st.nslices  = 28;
        matlabbatch{1}.spm.temporal.st.tr       = 1.6;
        matlabbatch{1}.spm.temporal.st.ta       = 1.6-(1.6/28);
        matlabbatch{1}.spm.temporal.st.so       = [1:1:28];
        matlabbatch{1}.spm.temporal.st.refslice = 14;
        matlabbatch{1}.spm.temporal.st.prefix   = 'a';
        save slicetime matlabbatch
        slicetime{s,r} = [pwd,'/slicetime.mat'];
    end
end

% run: slicetime
parfor s = 1:size(subj,1)
    for r = 1:size(run,1)
        cd(RUNdir{s,r})
        temp = [];
        temp = load(slicetime{s,r});
        spm_jobman('run',temp.matlabbatch);
    end
end


% define: coregister
%--------------------------------------------------------------------------
for s = 1:size(subj,1)
    for r = 1:size(run,1)
        cd(RUNdir{s,r})
        matlabbatch = []; ima = []; ima1 = []; ima2 = [];
        ima1 = cellstr(spm_select('FPlist',pwd,'^arf.*.nii$'));
        ima2 = cellstr(spm_select('FPlist',pwd,'^rf.*.nii$'));
        ima = [ima1;ima2];
        matlabbatch{1}.spm.spatial.coreg.estimate.ref               = cellstr(['sanlm_rrs_',subj{s,1},'_t1.nii']);
        matlabbatch{1}.spm.spatial.coreg.estimate.source            = cellstr(spm_select('FPlist',pwd,'^meanf.*.nii$'));
        matlabbatch{1}.spm.spatial.coreg.estimate.other             = ima;
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = char('nmi');
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = [...
            0.02  0.02  0.02 ...
            0.001 0.001 0.001 ...
            0.01  0.01  0.01 ...
            0.001 0.001 0.001];
        save coregister matlabbatch
        coregister{s,r} = [pwd,'/coregister.mat'];
    end
end

% run: coregister
parfor s = 1:size(subj,1)
    for r = 1:size(run,1)
        cd(RUNdir{s,r})
        temp = [];
        temp = load(coregister{s,r});
        spm_jobman('run',temp.matlabbatch);
    end
end


% define: segment
%--------------------------------------------------------------------------
for s = 1:size(subj,1)
    for r = 1:size(run,1)
        if r == 1
            cd(RUNdir{s,r})
            matlabbatch = [];
            ngaus = [1 1 2 3 4 2];
            for tissue = 1:6
                matlabbatch{1}.spm.spatial.preproc.tissue(tissue).tpm    = {[TPMdir,'/TPM.nii,',num2str(tissue)]};
                matlabbatch{1}.spm.spatial.preproc.tissue(tissue).ngaus  = ngaus(tissue);
                matlabbatch{1}.spm.spatial.preproc.tissue(tissue).native = [1 1];
                matlabbatch{1}.spm.spatial.preproc.tissue(tissue).warped = [0 0];
            end
            matlabbatch{1}.spm.spatial.preproc.channel.vols     = cellstr(spm_select('FPlist',pwd,'^s_.*_t1.nii$'));
            matlabbatch{1}.spm.spatial.preproc.channel.biasreg  = 0.001;
            matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
            matlabbatch{1}.spm.spatial.preproc.channel.write    = [0 0];
            matlabbatch{1}.spm.spatial.preproc.warp.mrf         = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.cleanup     = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.reg         = [0 0.001 0.5 0.05 0.2];
            matlabbatch{1}.spm.spatial.preproc.warp.affreg      = 'mni';
            matlabbatch{1}.spm.spatial.preproc.warp.fwhm        = 0;
            matlabbatch{1}.spm.spatial.preproc.warp.samp        = 3;
            matlabbatch{1}.spm.spatial.preproc.warp.write       = [1 1];
            save T1segment1 matlabbatch
            T1segment1{s,r} = [pwd,'/T1segment1.mat'];
        end
    end
end

% run: segment
parfor s = 1:size(subj,1)
    for r = 1
        cd(RUNdir{s,r})
        temp = [];
        temp = load(T1segment1{s,r});
        spm_jobman('run',temp.matlabbatch);
    end
end


% SHOOT tool
for r = 1
    cd(shootdir)
    matlabbatch = [];
    matlabbatch{1}.spm.tools.shoot.warp.images{1,1} = cellstr(spm_select('FPlist',pwd,'^rc1s_.*t1.nii$'));
    matlabbatch{1}.spm.tools.shoot.warp.images{1,2} = cellstr(spm_select('FPlist',pwd,'^rc2s_.*t1.nii$'));
    matlabbatch{1}.spm.tools.shoot.warp.images{1,3} = cellstr(spm_select('FPlist',pwd,'^rc3s_.*t1.nii$'));
    save shoot matlabbatch
    spm_jobman('run',matlabbatch);
end


% define: fnormalize + smooth (SHOOT)
clear fnormalise*
for s = 1:size(subj,1)
    for r = 1:size(run,1)
        cd(RUNdir{s,r})
        matlabbatch = [];
        matlabbatch{1}.spm.tools.shoot.norm.template              = {[SHOOTdir{1,1},'/Template_4.nii']};
        matlabbatch{1}.spm.tools.shoot.norm.data.subj.deformation = {[SHOOTdir{1,1},'/y_rc1sanlm_rrs_',subj{s,1},'_t1_Template.nii']};
        matlabbatch{1}.spm.tools.shoot.norm.data.subj.images      = cellstr(spm_select('FPlist',pwd,'^arf.*.nii$'));
        matlabbatch{1}.spm.tools.shoot.norm.vox                   = [2 2 2];
        matlabbatch{1}.spm.tools.shoot.norm.bb                    = bound;
        matlabbatch{1}.spm.tools.shoot.norm.preserve              = 0;
        matlabbatch{1}.spm.tools.shoot.norm.fwhm                  = 8;
        save fnormalise1 matlabbatch
        fnormalise1{s,r} = [pwd,'/fnormalise1.mat'];
    end
end

% run: normalize
parfor s = 1:size(subj,1)
    for r = 1:size(run,1)
        cd(RUNdir{s,r})
        temp = [];
        temp = load(fnormalise1{s,r});
        spm_jobman('run',temp.matlabbatch);
    end
end

