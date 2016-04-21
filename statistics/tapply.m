function [ output_args ] = tapply( x, list, fname, factorisation, nbin )

% options
    if nargin<4
        for i = 1:length(list)
             factorisation{i} = 'discrete';
        end
    end
    for i = 1:length(list)
        if strcmp(factorisation{i},'continuous') && nargin<5
            nbin = repmat(6,1,length(list));
        end
    end
        

% define factorial space 
% of conditionnal variables from the list
    x=x(:);
    c=['['];
    for i = 1:length(list)
      l=list{i};
      l=l(:);
      if  iscategorical(l) % exclude isundefined
         select = (~isundefined(l));  
      else
         select = (~isnan(l));   
      end
      
      switch factorisation{i}
          case 'discrete'
            dim(i)=length(unique(l(select)));
          case 'continuous'
            dim(i)=nbin(i);
      end

      if length(l) ~=length(x)
          error(['length(var)~=length(list{' num2str(i) '}'])
      end
      c=[c 'i' num2str(i) ' '];
      
    end

    c=[c ']'];

    if length(list)==1
    output_args=nan(1,dim);
    else
    output_args=nan(dim);
    end

% apply function for every instance of the factorial space
    for i = 1:numel(output_args)
        eval([c '=ind2sub(dim,i);']);
        test=ones(1, length(x));
        for j = 1:length(list)
            eval(['ind = i' num2str(j) ';']);
            l=list{j};
            l=l(:);
            switch factorisation{j}
                 case 'discrete'
                    if  iscategorical(l) % exclude isundefined
                         select = (~isundefined(l));  
                    else
                         select = (~isnan(l));   
                    end
                    f=unique(l(select));
                    test(l~=f(ind))=0;
                case 'continuous'
                    f = quantile(l,[1/nbin(j):1/nbin(j):1]);
                    if ind==1
                        exclude = ( l>f(ind));
                        test(exclude)=0;    
                    else
                        exclude = ( l<=f(ind-1) | l>f(ind));
                        while isempty(find(exclude==0)) && ind~=1 ;
                            ind = ind-1;
                            if ind==1
                                exclude = ( l>f(ind));
                            else
                                exclude = ( l<=f(ind-1) | l>f(ind));
                            end
                        end
                        test(exclude)=0;
                    end
            end
        end
        try
        output_args(i)=fname(x(test==1));
        end
    end
    
    
end

