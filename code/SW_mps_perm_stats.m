% determine p-value from permutation distribution, shuffle labels

allmps = load('msp_all_sounds_n2567.mat'); % MPS of all sounds: generated by the MPS tbx; 659 x 1806 matrix per sound

combinations = {...
    'anc_hum',1,5;...
    'anc_ani',1,6;...
    'anc_env',1,7;...
    'anc_ext',1,8;...
    'anc_int',1,9;...
    'anc_mus',1,10;...
    'anc_ins',1,11;...
    'anc_azt',1,12;...
    'anc_syn',1,13;...

    'hig_hum',2,5;...
    'hig_ani',2,6;...
    'hig_env',2,7;...
    'hig_ext',2,8;...
    'hig_int',2,9;...
    'hig_mus',2,10;...
    'hig_ins',2,11;...
    'hig_azt',2,12;...
    'hig_syn',2,13;...

    'med_hum',3,5;...
    'med_ani',3,6;...
    'med_env',3,7;...
    'med_ext',3,8;...
    'med_int',3,9;...
    'med_mus',3,10;...
    'med_ins',3,11;...
    'med_azt',3,12;...
    'med_syn',3,13;...

    'low_hum',4,5;...
    'low_ani',4,6;...
    'low_env',4,7;...
    'low_ext',4,8;...
    'low_int',4,9;...
    'low_mus',4,10;...
    'low_ins',4,11;...
    'low_azt',4,12;...
    'low_syn',4,13;...
    };

for comb = [1:9:36 2:9:36 3:9:36 4:9:36 5:9:36 6:9:36 7:9:36 8:9:36 9:9:36]
    for p = 1:40
        allrand = nan(659,1806,50);
        for i = 1:50
            tmp1 = []; tmp2 = [];
            tmp1 = logical(randi([0 1], 60, 1));
            tmp2 = ~tmp1;

            idx1 = []; idx2 = [];
            idx1 = categories2(combinations{comb,2});
            idx2 = categories2{combinations{comb,3}};

            data = [];
            data = allmps(:,:,or(idx1,idx2));

            tmp = [];
            tmp = 1:size(data,3);
            tmp = tmp(randperm(length(tmp)));

            data = data(:,:,tmp);
            allrand(:,:,i) = log(fftshift(nanmean(data(:,:,1:sum(idx1)),3))) - log(fftshift(nanmean(data(:,:,sum(idx1)+1:end),3)));
        end
        allrand = single(allrand);
        save([combinations{comb,1},'_',num2str(p)],'allrand','-v7.3')
    end

    idx1 = categories2{combinations{comb,2}}';
    idx2 = categories2{combinations{comb,3}}';
    target1 = log(fftshift(nanmean(allmps(:,:,idx1),3))) - log(fftshift(nanmean(allmps(:,:,idx2),3)));
    target2 = log(fftshift(nanmean(allmps(:,:,idx2),3))) - log(fftshift(nanmean(allmps(:,:,idx1),3)));

    pmap1 = nan(659,1806);
    pmap2 = nan(659,1806);
    pmap3 = nan(659,1806);
    pmap4 = nan(659,1806);
    pmap5 = nan(659,1806);
    pmap6 = nan(659,1806);
    pmap7 = nan(659,1806);
    pmap8 = nan(659,1806);
    pmap9 = nan(659,1806);

    parfor r = 1:659
        distribution = [];
        for p = 1:40
            matObj = matfile([combinations{comb,1},'_',num2str(p),'.mat']);
            distribution = [distribution;(squeeze(matObj.allrand(r,:,:)))'];
        end
        tmp1 = []; tmp2 = [];
        tmp1 = -log10(1-(2*normcdf(target1(r,:),nanmean(distribution),nanstd(distribution))));
        tmp2 = (1-(2*normcdf(target1(r,:),nanmean(distribution),nanstd(distribution))));

        tmp3 = []; tmp4 = [];
        tmp3 = -log10(1-(2*normcdf(target2(r,:),nanmean(distribution),nanstd(distribution))));
        tmp4 = (1-(2*normcdf(target2(r,:),nanmean(distribution),nanstd(distribution))));

        tmp5 = []; tmp6 = [];
        tmp5 = -log10(2*normcdf(-abs(target1(r,:)),nanmean(distribution),nanstd(distribution)));
        tmp6 = (2*normcdf(-abs(target1(r,:)),nanmean(distribution),nanstd(distribution)));

        for c = 1:1806
            if target1(r,c) < 0
                pmap1(r,c) = tmp1(1,c) * -1;
                pmap2(r,c) = tmp2(1,c) * -1;
                pmap3(r,c) = -log10(tmp2(1,c) * -1);
            else
                pmap1(r,c) = tmp1(1,c);
                pmap2(r,c) = tmp2(1,c);
                pmap3(r,c) = -log10(tmp2(1,c));
            end

            if target2(r,c) < 0
                pmap4(r,c) = tmp3(1,c) * -1;
                pmap5(r,c) = tmp4(1,c) * -1;
                pmap6(r,c) = -log10(tmp4(1,c) * -1);
            else
                pmap4(r,c) = tmp3(1,c);
                pmap5(r,c) = tmp4(1,c);
                pmap6(r,c) = -log10(tmp4(1,c));
            end

            if target1(r,c) < 0
                pmap7(r,c) = tmp5(1,c) * -1;
                pmap8(r,c) = tmp6(1,c) * -1;
                pmap9(r,c) = -log10(tmp6(1,c)) *-1;
            else
                pmap7(r,c) = tmp5(1,c);
                pmap8(r,c) = tmp6(1,c);
                pmap9(r,c) = -log10(tmp6(1,c));
            end

            if target1(r,c) < 0
                pmap10(r,c) = tmp5(1,c) * -1;
                if tmp6(1,c) < 0.05
                    pmap11(r,c) = tmp6(1,c) * -1;
                    pmap12(r,c) = -log10(tmp6(1,c)) *-1;
                else
                    pmap11(r,c) = 0;
                    pmap12(r,c) = 0;
                end
            else
                pmap10(r,c) = tmp5(1,c);
                if tmp6(1,c) < 0.05
                    pmap11(r,c) = tmp6(1,c);
                    pmap12(r,c) = -log10(tmp6(1,c));
                else
                    pmap11(r,c) = 0;
                    pmap12(r,c) = 0;
                end
            end
        end
    end

    save([combinations{comb,1},'.mat'],...
        'pmap1','pmap2','pmap3',...
        'pmap4','pmap5','pmap6',...
        'pmap7','pmap8','pmap9',...
        'pmap10','pmap11','pmap12',...
        '-v7.3')
end
