 function y = prctile2019(varargin)
    par = inputParser();
    par.addRequired('x');
    par.addRequired('p');
    par.addOptional('dim',1,@(x) isnumeric(x) || validateDimAll(x));
    par.addParameter('Delta',1e3);
    par.addParameter('RandStream',[]);

    par.parse(varargin{:});

    x = par.Results.x;
    p = par.Results.p;
    dim = par.Results.dim;
    delta = par.Results.Delta;
    rs = par.Results.RandStream;


    % Figure out which dimension prctile will work along.
    sz = size(x);


    % Permute the array so that the requested dimension is the first dim.
    if ~isequal(dim,1)
        nDimsX = ndims(x);
        dim = sort(dim);
        perm = [dim setdiff(1:max(nDimsX,max(dim)),dim)];
        x = permute(x, perm);
    end
    sz = size(x);
    dimArgGiven = true;



    % Drop X's leading singleton dims, and combine its trailing dims.  This
    % leaves a matrix, and we can work along columns.
    work_dim = 1:numel(dim);

    work_dim = work_dim(work_dim <= numel(sz));
    nrows = prod(sz(work_dim));
    ncols = numel(x) ./ nrows;
    x = reshape(x, nrows, ncols);

    x = sort(x,1);
    n = sum(~isnan(x), 1); % Number of non-NaN values in each column

    % For columns with no valid data, set n=1 to get nan in the result
    n(n==0) = 1;

    % If the number of non-nans in each column is the same, do all cols at once.
    if all(n == n(1))
        n = n(1);
        if isequal(p,50) % make the median fast
            if rem(n,2) % n is odd
                y = x((n+1)/2,:);
            else        % n is even
                y = (x(n/2,:) + x(n/2+1,:))/2;
            end
        else
            y = interpColsSame(x,p,n);
        end

    else
        % Get percentiles of the non-NaN values in each column.
        y = interpColsDiffer(x,p,n);
    end


    % Reshape Y to conform to X's original shape and size.
    szout = sz;
    szout(work_dim) = 1;
    szout(work_dim(1)) = numel(p);
    y = reshape(y,szout);

    % undo the DIM permutation
    if dimArgGiven && ~isequal(dim,1)
        y = ipermute(y,perm);
    end



        function y = interpColsSame(x, p, n)

            if isrow(p)
                p = p';
            end

            % Form the vector of index values (numel(p) x 1)
            r = (p/100)*n;
            k = floor(r+0.5); % K gives the index for the row just before r
            kp1 = k + 1;      % K+1 gives the index for the row just after r
            r = r - k;        % R is the ratio between the K and K+1 rows

            % Find indices that are out of the range 1 to n and cap them
            k(k<1 | isnan(k)) = 1;
            kp1 = bsxfun( @min, kp1, n );

            % Use simple linear interpolation for the valid percentages
            y = (0.5+r).*x(kp1,:)+(0.5-r).*x(k,:);

            % Make sure that values we hit exactly are copied rather than interpolated
            exact = (r==-0.5);
            if any(exact)
                y(exact,:) = x(k(exact),:);
            end

            % Make sure that identical values are copied rather than interpolated
            same = (x(k,:)==x(kp1,:));
            if any(same(:))
                x = x(k,:); % expand x
                y(same) = x(same);
            end
        end

        function y = interpColsDiffer(x, p, n)
            %INTERPCOLSDIFFER A simple 1-D linear interpolation of columns that can
            %deal with columns with differing numbers of valid entries (vector n).

            [nrows, ncols] = size(x);

            % Make p a column vector. n is already a row vector with ncols columns.
            if isrow(p)
                p = p';
            end

            % Form the grid of index values (numel(p) x numel(n))
            r = (p/100)*n;
            k = floor(r+0.5); % K gives the index for the row just before r
            kp1 = k + 1;      % K+1 gives the index for the row just after r
            r = r - k;        % R is the ratio between the K and K+1 rows

            % Find indices that are out of the range 1 to n and cap them
            k(k<1 | isnan(k)) = 1;
            kp1 = bsxfun( @min, kp1, n );

            % Convert K and Kp1 into linear indices
            offset = nrows*(0:ncols-1);
            k = bsxfun( @plus, k, offset );
            kp1 = bsxfun( @plus, kp1, offset );

            % Use simple linear interpolation for the valid percentages.
            % Note that NaNs in r produce NaN rows.
            y = (0.5-r).*x(k) + (0.5+r).*x(kp1);

            % Make sure that values we hit exactly are copied rather than interpolated
            exact = (r==-0.5);
            if any(exact(:))
                y(exact) = x(k(exact));
            end

            % Make sure that identical values are copied rather than interpolated
            same = (x(k)==x(kp1));
            if any(same(:))
                x = x(k); % expand x
                y(same) = x(same);
            end
        end

        function bool = validateDimAll(dim)
            bool = ((ischar(dim) && isrow(dim)) || ...
                (isstring(dim) && isscalar(dim) && (strlength(dim) > 0))) && ...
                strncmpi(dim,'all',max(strlength(dim), 1));
        end
    end
