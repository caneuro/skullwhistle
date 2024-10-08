
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


condition = {...
    'sw_hig';...
    'sw_low';...
    'sw_med';...
    'sw_orig';...

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
    };


% loop through mvpa
%--------------------------------------------------------------------------
for s = 1:size(subj,1)
    for c1 = 1:size(condition,1)-1
        for c2 = c1+1:size(condition,1)

            disp(['subj: ',subj{s,1},' -- sl: ',condition{c1,1},' - ',condition{c2,1}])
            ima     = [];
            chunk   = [];
            label   = [];
            descr   = [];

            cd(resdir1{1,s,t})
            ima1 = cellstr(spm_select('FPlist',pwd,'^beta_run01.*.nii$'));
            ima2 = cellstr(spm_select('FPlist',pwd,'^beta_run02.*.nii$'));
            ima3 = cellstr(spm_select('FPlist',pwd,'^beta_run03.*.nii$'));
            ima4 = cellstr(spm_select('FPlist',pwd,'^beta_run04.*.nii$'));

            ima = [...
                ima1((c1*8)-7:c1*8);  ima2((c1*8)-7:c1*8);  ima3((c1*8)-7:c1*8);  ima4((c1*8)-7:c1*8);...
                ima1((c2*8)-7:c2*8);  ima2((c2*8)-7:c2*8);  ima3((c2*8)-7:c2*8);  ima4((c2*8)-7:c2*8);...
                ];
            chunk = [...
                ones(8,1)*1; ones(8,1)*2; ones(8,1)*3; ones(8,1)*4;...
                ones(8,1)*1; ones(8,1)*2; ones(8,1)*3; ones(8,1)*4;...
                ];
            label = [ones(8*4,1)*1; ones(8*4,1)*2];
            descr = [repmat(condition{1,1},32,1); repmat(condition{2,1},32,1)];


            % Configure TDT
            %--------------------------------------------------------------
            cd(resdir2{1,s,t})
            model_parameters = '-s 0 -t 0 -c 1 -b 0 -q';

            cfg                        = decoding_defaults;
            cfg.testmode               = 0;
            cfg.analysis               = 'searchlight'; % 'searchlight', 'wholebrain', 'ROI' (if ROI, set one or multiple ROI images as mask files below instead of the mask)
            cfg.results.dir            = pwd; % Specify where the results should be saved
            cfg.results.overwrite      = 1;
            cfg.files.mask             = [resdir2{1,s,t},'/mask.grey.nii'];
            cfg.files.name             = ima;
            cfg.files.chunk            = chunk;
            cfg.files.label            = label;
            cfg.files.set              = [];
            cfg.files.descr            = descr;
            cfg.files.twoway           = 0;
            cfg.design                 = make_design_cv(cfg); % leave-one-run-out cross validation design
            cfg.design.unbalanced_data = 'ok';
            cfg.verbose                = 1;
            cfg.searchlight.unit       = 'mm';
            cfg.searchlight.radius     = 6;
            cfg.searchlight.spherical  = 0;
            cfg.decoding.method        = 'classification';
            cfg.plot_selected_voxels   = 0; % for visualization
            cfg.decoding.train.classification.model_parameters = model_parameters;
            cfg.results.output = { ...  % See decoding_transform_results for more.
                'accuracy';...
                'accuracy_minus_chance';...
                'balanced_accuracy';...
                'balanced_accuracy_minus_chance';...
                };
        end
    end
end

% run: mvpa
parfor s = 1:size(subj,1)
    for c1 = 1:size(condition,1)
        for c2 = c1+1:size(condition,1)
            cd(resdir2{1,s,t})
            temp  = [];
            temp  = load(mvpa{r,s,c1,c2});
            [~,~] = decoding(temp.cfg);
        end
    end
end
