function out = strsplit(str,delimiter,tokenNumber)
%FUNCTION out = strsplit(str,delimiter,tokenNumber)
%
%   Splits a string using an specific delimiter and returns the part
%   specified by tokenNumber
%
%PARAMETERS
%
%   str : the string that will be split
%
%   delimiter : the delimiter that determines the string parts
%
%   tokenNumber : the number of the string part that will be returned
%
%RETURNS
%
%   out : a string containing the part of the full initial string
%
    remain = str;
    out = [];
    tokenNum = 1;
    while size(remain,2) ~= 0
        [token, remain] = strtok(remain,delimiter);
        if tokenNum == tokenNumber
            out = token;
        end
        tokenNum = tokenNum + 1;
    end
end