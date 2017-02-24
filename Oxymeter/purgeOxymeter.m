%% purgeOxymeter
if oxymeter
    purgedone=0;
    while purgedone==0
        ret = ReadOxymeter('livedata');
        purgedone=size(ret,1)==0;
    end
end