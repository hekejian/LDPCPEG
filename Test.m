
    SNR1 = 0:0.1:10;
    [row,col]=size(A);
    hEnc = comm.LDPCEncoder(A);
    hMod = comm.PSKModulator(4, 'BitInput',true);
    for i = 1:101
    hChan = comm.AWGNChannel(...
            'NoiseMethod','Signal to noise ratio (SNR)','SNR',SNR1(i));
    hDemod = comm.PSKDemodulator(4, 'BitOutput',true,...
            'DecisionMethod','Approximate log-likelihood ratio', ...
            'Variance', 1/10^(hChan.SNR/10));
    hDec = comm.LDPCDecoder(A);
    hError = comm.ErrorRate;
    
      data           = logical(randi([0 1], row, 1));
      encodedData    = step(hEnc, data);
      modSignal      = step(hMod, encodedData);
      receivedSignal = step(hChan, modSignal);
      demodSignal    = step(hDemod, receivedSignal);
      receivedBits   = step(hDec, demodSignal);
      errorStats     = step(hError, data, receivedBits);
      BER(i) = errorStats(1);
    end
    plot(SNR1,BER);
