function datestring = find_datestring(  )

    c = clock;
    
%     datestring = num2str(c(1:5));
%     datestring = strrep(datestring,'     ','-');
%     datestring = strrep(datestring,'    ','-');
    
    datestring = date;
    
end

