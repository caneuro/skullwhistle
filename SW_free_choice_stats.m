% Binomial test on free choice (fc) data

% load data on number of "noun" and "adjective" occurance
nouns = load('fc_nouns_data.mat'); % 1.colum: which noun, 2. column: "rsubj" with frequency data relative per n subjects
adject = load('fc_adject_data.mat');

cat = {'sw_orig','sw_high','sw_med','sw_low'};

for c = 1:numel(cat)
    temp = [];
    temp = sortrows(nouns{c},'rsubj','descend');

    % do stats
    pout = myBinomTest(...
        nouns{c}.rsubj([1:12]),...
        round(sum(nouns{c}.rsubj)),...
        1/size(nouns{c}.rsubj,1),...
        'two');
    [~,~,padj] = fdr(pout);
end

for c = 1:numel(cat)
    temp = [];
    temp = sortrows(adject{c},'rsubj','descend');

    % do stats
    pout = myBinomTest(...
        adject{c}.rsubj([1:12]),...
        round(sum(adject{c}.rsubj)),...
        1/size(adject{c}.rsubj,1),...
        'two');
    [~,~,padj] = fdr(pout);
end
