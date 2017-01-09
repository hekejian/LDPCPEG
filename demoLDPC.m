% demo for generating regular PEG LDPCs
% Date: May 10 2013
% Hatef Monajemi (monajemi@stanford.edu)

mex GenerateLDPC_mex.cpp BigGirth.cpp CyclesOfGraph.cpp Random.cpp GenerateLDPC.cpp
% n = 972; %252  324*  648  864* 972*  972* 1296
% N = 1944; %504  648* 1296 1296* 1296* 1944* 1944
dc= 5;  %5   5  
n = [252,648];
N = [504, 1296];
s = length(n);
for j = 1:s
    
A = buildLDPCmatrix(n(j),N(j),dc);
M = 4;

    SNR1 = 0:0.002:5;
    [row,col]=size(A);
    hEnc = comm.LDPCEncoder(A);
    data  = logical(randi([0 1], row, 1));
    hMod = comm.PSKModulator(M, 'BitInput',true);
    for i = 1:2501
    hChan = comm.AWGNChannel(...
            'NoiseMethod','Signal to noise ratio (SNR)','SNR',SNR1(i));
    hDemod = comm.PSKDemodulator(M, 'BitOutput',true,...
            'DecisionMethod','Approximate log-likelihood ratio', ...
            'Variance', 1/10^(hChan.SNR/10));
    hDec = comm.LDPCDecoder(A);
    hError = comm.ErrorRate;
    
     
      encodedData    = step(hEnc, data);
      modSignal      = step(hMod, encodedData);
      receivedSignal = step(hChan, modSignal);
      demodSignal    = step(hDemod, receivedSignal);
      receivedBits   = step(hDec, demodSignal);
      errorStats     = step(hError, data, receivedBits);
      BER(i) = errorStats(1);
    end
%     figure;
%     plot(SNR1,BER,'.');
%    title(['PEG-LDPC: N = ',num2str(N), ...
%         ', n = ', num2str(n), ...
%         ', d = ', num2str(dc),...
%         ', Modulation ', M], 'fontsize', 12)
%     xlabel('SNR');
%     ylabel('BER')
%     hold on
    
    P = polyfit(SNR1,BER,6);
    B = polyval(P,SNR1);
    plot(SNR1,B);
    hold on
     title(['PEG-LDPC: N = ',num2str(N), ...
        ', n = ', num2str(n), ...
        ', d = ', num2str(dc),...
        ', Modulation ',M] ,'fontsize', 12)
    xlabel('SNR');
    ylabel('BER')
    
end
legend('N = 504, M = 252','N = 1296, M = 648');
