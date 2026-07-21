function filelst = f_ls_super(searchptr)
    temp = dir(searchptr);
    tempCell = struct2cell(temp)';
    filelst = cellfun(@(x1,x2) fullfile(x1,x2),tempCell(:,2),tempCell(:,1),'UniformOutput',false);
end