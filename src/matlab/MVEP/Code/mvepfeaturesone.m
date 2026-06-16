function [avtrials,Fstim,Fnonstim,Targ,NonTarg,avTarg,avNonTarg360]=mvepfeaturesone(stim,nonstim,chan,rp,pi,avover);
%% Function to extract mvep features

global fs

pe=8;

% avTarg=[];
% avNonTarg360=[];
% 
% stim=trainTargStimRep
% nonstim=trainNonTargStim

%Copyright 2013 Damien Coyle, d.coyle@ieee.org>

Hd=filterone;
featureRange=pi:pi+pe;

for j=1:5
    %Filter required channels only
    Fstim{j}=filter(Hd,stim{j}(chan,:,:));
    Fnonstim{j}=filter(Hd,nonstim{j}(chan,:,:));
    %     Filter required channels only
    %     Fstim{j}=stim{j}(chan,:,:);
    %     Fnonstim{j}=nonstim{j}(chan,:,:);
    
    noTr=size(stim{j},3);
    
%  twentyP=ceil(250*0.05);
 
twentyP=20;
    
    
    for s=1:noTr
        % dwonsample at 20Hz
        TwentyHz{j}(:,:,s)=resample(squeeze(Fstim{j}(:,:,s))',twentyP,fs)';
        TwentyHzNon{j}(:,:,s)=resample(squeeze(Fnonstim{j}(:,:,rp(s)))',twentyP,fs)';
        
        % take feature points covering MVEP and concatenate feature vector
        Targ{j}(:,s)=squeeze(reshape(TwentyHz{j}(:,featureRange,s)',(pe+1)*length(chan),1));
        NonTarg{j}(:,s)=squeeze(reshape(TwentyHzNon{j}(:,featureRange,s)',(pe+1)*length(chan),1));
    end
    
    for s=1:size(nonstim{j},3)
        % dwonsample at 20Hz
        %         TwentyHz{j}(:,:,s)=resample(squeeze(Fstim{j}(:,:,s))',20,fs)';
        TwentyHzNon360{j}(:,:,s)=resample(squeeze(Fnonstim{j}(:,:,s))',twentyP,fs)';
        
        % take feature points covering MVEP and concatenate feature vector
        %         Targ{j}(:,s)=squeeze(reshape(TwentyHz{j}(:,pi:pi+8,s)',pi*length(chan),1));
        NonTarg360{j}(:,s)=squeeze(reshape(TwentyHzNon360{j}(:,featureRange,s)',(pe+1)*length(chan),1));
    end
    
    %      AllSym=[AllSym,Targ{j}];
end

% % Plot averaged signals
% figure(6)
% col=['b';'r';'k';'m';'g';'c'];
% channelNo=1
% for j=1:5
%     plot(mean(squeeze(Fstim{j}(channelNo,:,:)),2),col(j));
%     hold on
% end
% plot(mean(squeeze(Fnonstim{j}(channelNo,:,:)),2),col(6));
% legend(['U';'D';'E';'R';'L';'N'])


% Plot averaged signals
% figure(1)
% col=['b';'r';'k';'m';'g';'c'];
% for j=1:5
%     plot(mean(Targ{j}'),col(j));
%     hold on
% end
% plot(mean(NonTarg{j}'),col(6));
% legend(['U';'D';'E';'R';'L';'N'])

%% Averaging features over trials
[mt,nt]=size(Targ{j});

% avover=5;  % Number of trial to average over
avs=1:avover:nt;
ave=avover:avover:nt;

trialsperclass=nt/avover;
for j=1:5
    for i=1:nt/avover
        avTarg{j}(:,i)=mean(Targ{j}(:,avs(i):ave(i)),2);
        avNonTarg{j}(:,i)=mean(NonTarg{j}(:,avs(i):ave(i)),2);
    end
end

[mt,nt]=size(NonTarg360{j});

% avover=5;  % Number of trial to average over
avs=1:avover:nt;
ave=avover:avover:nt;

trialsperclass=nt/avover;
for j=1:5
    for i=1:nt/avover
        %         avTarg{j}(:,i)=mean(Targ{j}(:,avs(i):ave(i)),2);
        avNonTarg360{j}(:,i)=mean(NonTarg360{j}(:,avs(i):ave(i)),2);
    end
end


%% Combine class data
AllavTarg=[];
AllavNonTarg=[];
for j=1:5
    AllavTarg=[AllavTarg,avTarg{j}];
    AllavNonTarg=[AllavNonTarg,avNonTarg{j}];
end

%% Use all Nontarg
avtrials=[AllavTarg,AllavNonTarg];