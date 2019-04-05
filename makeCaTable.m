function caCodesTable = makeCaTable(PRN,codeLength,chiprate,samplingFreq)
%Function generates CA codes for all 32 satellites based on the settings
%provided in the structure "settings". The codes are digitized at the
%sampling frequency specified in the settings structure.
%One row in the "caCodesTable" is one C/A code. The row number is the PRN
%number of the C/A code.

%--- Find number of samples per spreading code
%一个周期的采样数，默认情况是38192，在跟踪时候改变
samplesPerCode = round(samplingFreq / ...
                           (chiprate / codeLength));

%--- Prepare the output matrix to speed up function -----------------------
caCodesTable = zeros(1, samplesPerCode);
 
%--- Find time constants --------------------------------------------------
ts = 1/samplingFreq;   % Sampling period in sec
tc = 1/chiprate;  % C/A chip period in sec
 
%=== For all satellite PRN-s ...

    %--- Generate CA code for given PRN -----------------------------------
    caCode = cacode(PRN);
 
    %=== Digitizing =======================================================
    
    %--- Make index array to read C/A code values -------------------------
    %使索引数组读取C/A代码值索引数组的长度取决于采样频率每毫秒采样数
    %（因为一个C/A代码周期是一毫秒）。.
    %ts是多少次采样一次，tc是码的变换时间，将ts投影到tc
    codeValueIndex = ceil((ts * (1:samplesPerCode)) / tc);
    
    %--- Correct the last index (due to number rounding issues) -----------
    codeValueIndex(end) = 1023;
    
    %--- Make the digitized version of the C/A code -----------------------
    % The "upsampled" code is made by selecting values form the CA code
    % chip array (caCode) for the time instances of each sample.
    caCodesTable(1, :) = caCode(codeValueIndex);
    

