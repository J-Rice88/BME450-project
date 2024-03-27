%BME 450 data set maker

clear
clc
load C:\Users\jettm\Downloads\Simulator\C_Easy1_noise01.mat
chan1d = data;
len = length(chan1d);
x = [1:len];
sd = std(chan1d);
threshcalc = mean(chan1d) - 1.9405*sd;
threshold = threshcalc;
thresh = find((chan1d <= threshold));
dfirstthresh = [];
for x = 1:length(thresh)-1
    if thresh(x+1) ~= (1+thresh(x)) 
        dfirstthresh = [dfirstthresh, thresh(x)];
    end
end
value_at_thresh_crossing = chan1d(dfirstthresh);
N = length(dfirstthresh);
nsamp = 15;
wave_len = nsamp*2+1;
WF = NaN(N,nsamp*2+1);
for k = 1:N
    j = dfirstthresh(k);
    WF(k,:) = chan1d(j-nsamp:j+nsamp);
end
WFalign = nan(size(WF));
for k = 1:N
   x = min(WF(k,nsamp-5:nsamp+5));
   loc = find(WF(k,:) == x);
   WFalign(k,nsamp+1) = x;
   loc = loc(1);
   j = dfirstthresh(k);
   j = j + (loc - (nsamp+1));
   if (j+nsamp < length(chan1d)) & (j-nsamp > 0)
   WFalign(k,:) = chan1d(j-nsamp:j+nsamp);
   end
 end
zWF = nan(size(WF));
for k = 1:N
    zWF(k,:) = (WFalign(k,:) - mean(WFalign(k,:))) ./ std(WFalign(k,:));
end

[coeff, score, latent, tsquared, explained] = pca(WF,'NumComponents',3);
colordiff = zeros(3,3);
colordiff(1,:) = [0,0,1];
colordiff(2,:) = [1,0,0];
colordiff(3,:) = [0,1,0];

figure(7),
plot(score(:,1),score(:,2),'.')
xlabel('PC1')
ylabel('PC2')
PC1 = explained(1);
PC2 = explained(2);
var = PC1 + PC2;
title(['These 2 PCs capture ',num2str(var),'% of the variance'])

sorted = nan(1,3522);

for z = 1:length(score)
    if score(z,1) < -.5
        sorted(z) = 1;
    end
    if score(z,1) > -.5 && score(z,2) > 0.4
        sorted(z) = 2;
    end
    if score(z,1) > -.5 && score(z,2) < 0.4
        sorted(z) = 3;
    end
end

figure(8)
hold on
for z = 1:length(score)
    x = sorted(z);
plot(score(z,1),score(z,2),'.', 'color', colordiff(x,:))
end
xlabel('PC1')
ylabel('PC2')
PC1 = explained(1);
PC2 = explained(2);
var = PC1 + PC2;
title(['These 2 PCs capture ',num2str(var),'% of the variance'])

save('sorted_zWF_data.mat', 'sorted', 'zWF');