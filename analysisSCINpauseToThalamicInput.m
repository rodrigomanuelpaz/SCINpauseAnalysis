%% analysisSCINpauseToThalamicInput.m
% 
% Script used in Tubert et al., 2025 (eLife)
%
% This script analyzes 15-second cell-attached recordings from striatal 
% cholinergic interneurons with ChR2 expression in thalamic terminals 
% originating from the intralaminar thalamic nuclei. 
%
% Each recording consists of:
%    - 5 seconds of baseline
%    - Optogenetic stimulation of thalamic terminals using a variable number of light pulses
%
% User-defined inputs:
%    - filename: name of the .abf file recorded with pClamp (10 sweeps per file)
%    - num_pulsos: number of square light pulses delivered during stimulation
%    - umbral: spike detection threshold (in mV), crossed by all spikes in the recording
%
% Output:
%    - tabla: a table where each row corresponds to a sweep, with the following columns:
%        1. Baseline ISI (ms)
%        2. Number of spikes during the burst
%        3. Burst duration (ms)
%        4. Pause duration after burst (ms)
%        5. x1
%        6. x2
%
% Note: This script requires the function abfload.m (Harald Hentschke, 2025)
% Available at: https://www.mathworks.com/matlabcentral/fileexchange/6190-abfload
%% 1) Inputs
filename = ['21611002.abf'];
num_pulsos = 1; %user-defined for each recording
umbral = 0.3;  %user-defined for each rcording

%% 2) Load the recordings
[dnf,si,head] = abfload(filename);  
t = 0:(si/1000000):(300000*si/1000000)-(si/1000000);
% plot(t, dnf(:,1,1));
% xlabel('s')
% ylabel('mV')
%% 3) Detect spikes
spikes = zeros(200,10);
for i = 1:10
    d_spikes = dnf(:,:,i) > umbral;
    idx = strfind(d_spikes',[0 1]); %find transitions from 0 to 1
    idx_1 = idx(1);
    for j = 1:(length(idx)-1)
        if idx(j+1) > (idx(j)+200)
            idx_1 = [idx_1, idx(j+1)];
        end
    end
    spikes(1:length(idx_1),i) = idx_1*si/1000; %timestamps of spikes in ms
    clear idx
end

%% 4) Get values
% For all the recordings, the optogenetic stimulation is at 5.17s = 5170 ms
% find spikes for burst: from 5170ms to 5170 + 50*num_pulsos + 250 (up to 250ms after the last pulse)
tabla = zeros(10,6);
for k = 1:10
    spike = spikes(:,k);
    spike(spike == 0) = [];
    %spikes durante el burst
    burst = spike(spike >= 5170 & spike <= 5170+50*num_pulsos+250);
    spikes_previos = spike(spike<5170);
    %ISI previo medio en ms
    ISI_previo_medio = (spikes_previos(size(spikes_previos,1))-spikes_previos(1))/size(spikes_previos,1); %en ms

    spikes_post_burst = spike(spike>5170+50*num_pulsos+250);
    first_spike_post_burst = spikes_post_burst(1);
    if size(burst) > 0  
        % pausa en ms
        pause = first_spike_post_burst - burst(size(burst,1));
        %num spikes durante el burst
        num_spikes_burst = size(burst,1);

        if size(burst,1)>1
            duracion_burst = burst(size(burst,1)) - burst(1);
        else
            duracion_burst = 0;
        end

        % X1: tiempo entre spike previo y estimulo 
        % X2: tiempo entre estimulo y spike previo
        x1 = 5170 - spikes_previos(size(spikes_previos,1));
        x2 = burst(1) - 5170;

        tabla(k,:) = [ISI_previo_medio, num_spikes_burst, duracion_burst, pause, x1, x2];
    else
        x1 = 5170 - spikes_previos(size(spikes_previos,1));
        x2 = first_spike_post_burst - 5170;
        tabla(k,:) = [ISI_previo_medio, 0, 0, 0, x1, x2]; %no hubo spikes durante el burst
    end
    clear ISI_previo_medio num_spikes_burst duracion_burst pause x1 x2;
end
