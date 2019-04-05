function caCodesTable = makeCaTable(PRN,codeLength,chiprate,samplingFreq)
%Function generates CA codes for all 32 satellites based on the settings
%provided in the structure "settings". The codes are digitized at the
%sampling frequency specified in the settings structure.
%One row in the "caCodesTable" is one C/A code. The row number is the PRN
%number of the C/A code.

%--- Find number of samples per spreading code
%һ�����ڵĲ�������Ĭ�������38192���ڸ���ʱ��ı�
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
    %ʹ���������ȡC/A����ֵ��������ĳ���ȡ���ڲ���Ƶ��ÿ���������
    %����Ϊһ��C/A����������һ���룩��.
    %ts�Ƕ��ٴβ���һ�Σ�tc����ı任ʱ�䣬��tsͶӰ��tc
    codeValueIndex = ceil((ts * (1:samplesPerCode)) / tc);
    
    %--- Correct the last index (due to number rounding issues) -----------
    codeValueIndex(end) = 1023;
    
    %--- Make the digitized version of the C/A code -----------------------
    % The "upsampled" code is made by selecting values form the CA code
    % chip array (caCode) for the time instances of each sample.
    caCodesTable(1, :) = caCode(codeValueIndex);
    

