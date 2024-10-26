% Hierarchical Clustering Dendrograms

cat_lookup = load('categories_n86.mat'); % load 86 categories labels
zvals = load('zvals_nsound_by_ncat.mat'); % load z-value data: 1582 acoustic x 86 categories data matrix

dendax(r) = axes('Position', axpos);
links = linkage(squareform(pdist(zvals, 'correlation')), 'weighted');
[h,nodes,orig] = dendrogram(links, 0, 'labels', ...
    strrep(cat_lookup(:,1), '_', ' '), ...
    'colorthreshold', 2.0);
xtickangle(45)