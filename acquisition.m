function acqResult = acquisition(longSignal, settings)
%% Initialization =========================================================

% Find number of samples per spreading code     对于每个扩频码求采样数
samplesPerCode = round(settings.samplingFreq / ...
                        (settings.codeFreqBasis / settings.codeLength));

% Create two 1msec vectors of data to correlate with and one with zero DC
%产生两1ms的数据矢量？？？
signal1 = longSignal(1 : samplesPerCode);
signal2 = longSignal(samplesPerCode+1 : 2*samplesPerCode);

signal0DC = longSignal - mean(longSignal); 

% Find sampling period  求采样周期
ts = 1 / settings.samplingFreq;

% Find phase points of the local carrier wave 
phasePoints = (0 : (samplesPerCode-1)) * 2 * pi * ts;

% Number of the frequency bins for the given acquisition band (500Hz steps)
numberOfFrqBins = round(settings.acqSearchBand * 2) + 1;

% Generate all C/A codes and sample them according to the sampling freq.
caCodeTable = makeCaTable(settings.PRN,settings.codeLength,settings.codeFreqBasis ,settings.samplingFreq);


%--- Initialize arrays to speed up the code -------------------------------
% Search results of all frequency bins and code shifts (for one satellite)
results     = zeros(numberOfFrqBins, samplesPerCode);

% Carrier frequencies of the frequency bins，频率仓的载波频率
frqBins     = zeros(1, numberOfFrqBins);



%% Correlate signals ======================================================   
    %--- Perform DFT of C/A code ------------------------------------------
    caCodeFreqDom = conj(fft(caCodeTable));

    %--- Make the correlation for whole frequency band (for all freq. bins)
    %对整个频段进行关联（针对所有频率箱）
    for frqBinIndex = 1:numberOfFrqBins

        %--- 生成载波频率网格（0.5KHz步进） -----------
        frqBins(frqBinIndex) = settings.IF1 - ...
                               (settings.acqSearchBand/2) * 1000 + ...
                               0.5e3 * (frqBinIndex - 1);

        %--- Generate local sine and cosine -------------------------------
        sinCarr = sin(frqBins(frqBinIndex) * phasePoints);
        cosCarr = cos(frqBins(frqBinIndex) * phasePoints);

        %--- "Remove carrier" from the signal -----------------------------
        I1      = sinCarr .* signal1;
        Q1      = cosCarr .* signal1;
        I2      = sinCarr .* signal2;
        Q2      = cosCarr .* signal2;

        %--- Convert the baseband signal to frequency domain --------------
        IQfreqDom1 = fft(I1 + j*Q1);
        IQfreqDom2 = fft(I2 + j*Q2);

        %--- Multiplication in the frequency domain (correlation in time
        %domain)
        convCodeIQ1 = IQfreqDom1 .* caCodeFreqDom;
        convCodeIQ2 = IQfreqDom2 .* caCodeFreqDom;

        %--- Perform inverse DFT and store correlation results ------------
        acqRes1 = abs(ifft(convCodeIQ1)) .^ 2;
        acqRes2 = abs(ifft(convCodeIQ2)) .^ 2;
        
        %--- Check which msec had the greater power and save that, will
        %"blend" 1st and 2nd msec but will correct data bit issues
        %检查哪个MSEC具有更大的功率并保存，将混合第一个和第二个MSEC，但将纠正数据位问题
        if (max(acqRes1) > max(acqRes2))
            results(frqBinIndex, :) = acqRes1;
        else
            results(frqBinIndex, :) = acqRes2;
        end
        
    end % frqBinIndex = 1:numberOfFrqBins

%% Look for correlation peaks in the results ==============================
    % Find the highest peak and compare it to the second highest peak
    % The second peak is chosen not closer than 1 chip to the highest peak
    
    %--- Find the correlation peak and the carrier frequency --------------
    [peakSize frequencyBinIndex] = max(max(results, [], 2));

    %--- Find code phase of the same correlation peak ---------------------
    [peakSize codePhase] = max(max(results));

    %--- Find 1 chip wide C/A code phase exclude range around the peak ----
    samplesPerCodeChip   = round(settings.samplingFreq / settings.codeFreqBasis);
    excludeRangeIndex1 = codePhase - samplesPerCodeChip;
    excludeRangeIndex2 = codePhase + samplesPerCodeChip;
   
    %--- Correct C/A code phase exclude range if the range includes array
    %boundaries
    if excludeRangeIndex1 < 2
        codePhaseRange = excludeRangeIndex2 : ...
                         (samplesPerCode + excludeRangeIndex1);
                         
    elseif excludeRangeIndex2 >= samplesPerCode
        codePhaseRange = (excludeRangeIndex2 - samplesPerCode) : ...
                         excludeRangeIndex1;
    else
        codePhaseRange = [1:excludeRangeIndex1, ...
                          excludeRangeIndex2 : samplesPerCode];
    end

    %--- Find the second highest correlation peak in the same freq. bin ---
    secondPeakSize = max(results(frequencyBinIndex, codePhaseRange));

    %--- Store result -----------------------------------------------------
    acqResult.peakMetric = peakSize/secondPeakSize;
    
    % If the result is above threshold, then there is a signal ...
    if (peakSize/secondPeakSize) > settings.acqThreshold
%        figure(6);
%        plot(max(results));
%        title('获取伪码的起始点');
%        str=['粗频捕获为=' num2str(frqBins(frequencyBinIndex))];
%        disp(str);


%% 精细分辨率频率搜索 （暂时不精频了）=======================================
        
%         %--- Indicate PRN number of the detected signal -------------------
%         fprintf('');
%         
%         %--- Generate 10msec long C/A codes sequence for given PRN --------
%         caCode =  makeCaTable(18,settings.codeLength,settings.codeFreqBasis ,settings.samplingFreq);
%         
%         codeValueIndex = floor((ts * (1:10*samplesPerCode)) / ...
%                                (1/settings.codeFreqBasis));
%                            
%         longCaCode = caCode((rem(codeValueIndex, 1023) + 1));
%     
%         %--- Remove C/A code modulation from the original signal ----------
%         % (Using detected C/A code phase),剥离C/A码，然后对信号进行傅里叶变换，找到最大的频率点。
%         xCarrier = ...
%             signal0DC(codePhase:(codePhase + 10*samplesPerCode-1)) ...
%             .* longCaCode;
%         
%         %--- Find the next highest power of two and increase by 8x --------
%         fftNumPts = 8*(2^(nextpow2(length(xCarrier))));
%         
%         %--- Compute the magnitude of the FFT, find maximum and the
%         %associated carrier frequency 
%         fftxc = abs(fft(xCarrier, fftNumPts)); 
%         
%         uniqFftPts = ceil((fftNumPts + 1) / 2);
%         [fftMax, fftMaxIndex] = max(fftxc(5 : uniqFftPts-5));
%         
%         fftFreqBins = (0 : uniqFftPts-1) * settings.samplingFreq/fftNumPts;
%         
%         %--- Save properties of the detected satellite signal -------------
         acqResult.carrFreq  = frqBins(frequencyBinIndex);
         acqResult.codePhase = codePhase;
%         str=['精频捕获为=' num2str(acqResults.carrFreq(PRN))];
%         disp(str);
    else
        %--- No signal with this PRN --------------------------------------
        %fprintf('. ');
    end   % if (peakSize/secondPeakSize) > settings.acqThreshold
    


%=== Acquisition is over ==================================================
%fprintf(')\n');