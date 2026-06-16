% % Classify MVEP stimuli in 6 classes
% % U vs D vs L vs R vs E vs Nonstim
%
% % REQUIRES BIOSIG TOOLBOX and LIBSVM toolbox
%
%
%run 'U:\ToolBoxes\biosig4octmat-2.93\biosig_installer.m'
clear
clc;
close all

%% Retreive data

%=====Data name/directory
% subjectname='damienmatAPI1'
subjectname='damien4'
load(subjectname)

% When using Simulink get data from scope
% clear datMVEP

%%%%
% For FlexEEG - replace teh following line with code that load data into
% dataMVEP (5 channles plus the trigger channel recorded during mVEP run)

% Get data from Scope into data array
for i=1:9
    datMVEP(:,i)=squeeze(ScopeData1.signals(1,i).values);
end
datMVEP(:,1:3)=[];

s=datMVEP;

%% Settings selection
% Paradigm settings

global fs
fs=250;                %I may need to change from 1000 to 250Hz
avover=5;               %average over how many trials
numStim=5;              %total stim (always 5)
numChannels=5;         %channels used
trig_ch=numChannels+1;  %select channel for triggering

PRE=-fs*0.2+1;          %pre triggger
PST=fs*1;               %post trigger

% Processing settings
numEachStimperRun=30;    % this is the number of each stim in a run
numTargsperRun=numEachStimperRun*numStim;
pi=9;
numBestChannels=1
%% Trigger data
% Find the triggers edges for each  stimulus and store in cell
clear trigno TRIG
for i=1:5
    temptrig=s(:,trig_ch);
    temptrig(temptrig~=i)=0;

    size(temptrig(temptrig==i))

        TRIG{i} = gettrigger(temptrig); % trigger at ascending edge
end

% sequence is 12 runs, each run iterating through stim 1:5 - the process
% below loops through all runs extracting info for all stimuli (target and non-target

% % Trial adjustment was used for latency in FlexEEG packets when using Simulink 
% % (not needed for NeuroPRECISE which has latency correction automated)   

% PRE=PRE+22-1;
% PST=PST+22-1;


for j=1:numStim
    % Trigger the data for the jth stimulus
    [X,sz] = trigg(s, TRIG{j}, PRE, PST );
    X3D = reshape(X,sz);

    numStimNonStim=sz(3);

    % Get array indexs for target and non-target stimuli
    st=1;
    ed=5:numTargsperRun:numStimNonStim;

    st=st+((j-1)*numStim);  %index depend on the jth stimulus
    ed=ed+((j-1)*5);

    S=[];
    for i=1:length(st)     %6 runswith 15 target stimus for each symbol
        S=[S,st(i):ed(i)];
    end
    notS=1:numStimNonStim; %length(TRIG{j});
    notS(S)=[];

    %Baseline correction
    clear mch
    for u=1:numChannels
        mch(u)=mean(mean(squeeze(X3D(u,1:round(fs/5),:))));
        X3D(u,:,:)=X3D(u,:,:)-mch(u);
    end

    % Target vs Non-target
    % extract data for target and non target stimuli and store in cell

    %   Target and Nontarget size no matching - random nontarget selection later
    targStim{j}=X3D(:,:,S);
    %   nonstim{j}=X3D(:,:,notS);

    %   Make Target and Nontarget size matching - replicate stim
    targStimRep{j}=repmat(X3D(:,:,S),[1,1,4]);
    nonTargStim{j}=X3D(:,:,notS);
end

% break

% Setup data splits - remember when using repeated target data to match
% size of non target data
trialsPerClass=size(targStim{1},3);
nonTargTrialsPerClass=size(targStimRep{1},3);

trainSize=1:trialsPerClass;
testSize=1:trialsPerClass;

%         testSize=trialsPerClass+1:trialsPerClass*2;

trainRepSize=1:nonTargTrialsPerClass;
testRepSize=1:nonTargTrialsPerClass;

%         testRepSize=nonTargTrialsPerClass+1:nonTargTrialsPerClass*2;

for j=1:numStim
    trainTargStim{j}=targStim{j}(:,:,trainSize);
    testTargStim{j} =targStim{j}(:,:,testSize);

    trainTargStimRep{j}=targStimRep{j}(:,:,trainRepSize);
    testTargStimRep{j} =targStimRep{j}(:,:,testRepSize);

    trainNonTargStim{j}=nonTargStim{j}(:,:,trainRepSize);
    testNonTargStim{j} =nonTargStim{j}(:,:,testRepSize);
end
% break

% setup for random subset of nonTarg stimuli
% rp=randperm(size(nonTargStim{j},3));
% use all nonTarg stimuli
rp=1:size(nonTargStim{j},3);

%% Optimise with LOO using 50% of Rep Data
% Choose the best classifer
% for part = 1:27  % possibly use later for feature selection
m.hyperparameter.c_value=5;  %only used for SVM

ctype=1;   % 1= LDA
%     if ctype=1  max in 5 class test ?????
%     if ctype=4  min in 5 class test

switch ctype
    case 1
        m.TYPE='LD2';
    case 2
        m.TYPE='LD3';
    case 3
        m.TYPE='LD4';
    case 4
        m.TYPE='SVM1r';
    case 5
        m.TYPE='SVM11';
    case 6
        m.TYPE='mda';
    case 7
        m.TYPE='gdbc';
    case 8
        m.TYPE='bayes';
    case 9
        m.type='com';
    otherwise
        return
end

% Find the best channels
for chan=1:numChannels
    %     chan=[ch,ch+1];

    %Get features  - 50% of target data with Rep
    [avTrainTrials1ch,Fstim,Fnonstim,Targ,NonTarg,avTarg,NonTarg360]=mvepfeaturesone(trainTargStimRep,trainNonTargStim,chan,rp,pi,avover);

    % Generate class labels for 2 classes
    %         trialsperclass=size(stim{1},3);
    trialsperclass=length(avTrainTrials1ch)/2;
    classlabel=[ones(1,trialsperclass),ones(1,trialsperclass)*2];

    numclasses=length(unique(classlabel));

    %% set up for leave-one-out (LOO) cross validation (CV)
    s1=numclasses*trialsperclass;
    trainlabel=classlabel(1:s1);

    trainlabel(1:trialsperclass:s1)=[]; %remove one sample from each
    testlabel=unique(classlabel);

    % LOO CV
    for loo=1:trialsperclass
        1+loo-1:trialsperclass:s1;

        tn=avTrainTrials1ch(:,1:s1)';
        test=tn(1+loo-1:trialsperclass:s1,:);  %choose test examplars
        tn(1+loo-1:trialsperclass:s1,:)=[];    % remove test examplars from train

        % Train classifier
        [TCo]=train_sc(tn,trainlabel',m);
        % Test classifier
        [R]=test_sc(TCo,test,m,testlabel);


        % store accuracy for fold
        ac(loo)=R.ACC;
    end
    LOOmeanac(ctype,chan)=mean(ac);
end

% Take the best 3 channels
[Y,I]=sort(LOOmeanac(ctype,:),'descend');
chan=I(1:numBestChannels);

%     YY(PP,:)=Y
%     II(PP,:)=I
% end

%Get features with 3 best channels again 50% training with REP
[avTrainTrials3ch,Fstim,Fnonstim,Targ,NonTarg,avTarg,NonTarg360]=mvepfeaturesone(trainTargStimRep,trainNonTargStim,chan,rp,pi,avover);

% Plot averaged signals
%figure(6)
hold off
col=['b';'r';'k';'m';'g';'c'];
channelNo=1
for j=1:5
    plot(mean(squeeze(Fstim{j}(channelNo,:,:)),2),col(j));
    M(j,:)=mean(squeeze(Fstim{j}(channelNo,:,:)));
    hold on
end
plot(mean(squeeze(Fnonstim{j}(channelNo,:,:)),2),col(6));
legend(['U';'D';'E';'R';'L';'N'])
%
figure(3)
plot(mean(M))
hold on
plot(mean(squeeze(Fnonstim{j}(channelNo,:,:)),2),col(6));
legend(['Targ','NonTarg'])


% Plot averaged signals
figure(2)
hold off
col=['b';'r';'k';'m';'g';'c'];
for j=1:5
    plot(mean(Targ{j}'),col(j));
    hold on
end
plot(mean(NonTarg{j}'),col(6));
legend(['U';'D';'E';'R';'L';'N'])

%% set up for leave-one-out (LOO) cross validation (CV)

trialsperclass=size(avTrainTrials3ch,2)/2;
classlabel=[ones(1,trialsperclass),ones(1,trialsperclass)*2];

numclasses=length(unique(classlabel));

s1=numclasses*trialsperclass;
trainlabel=classlabel(1:s1);

trainlabel(1:trialsperclass:s1)=[]; %remove one sample from each
testlabel=unique(classlabel);

indices = 1:27;

for loo=1:trialsperclass
    1+loo-1:trialsperclass:s1;

    tn=avTrainTrials3ch(:,1:s1)';
    test=tn(1+loo-1:trialsperclass:s1,:);  %choose test examplars
    tn(1+loo-1:trialsperclass:s1,:)=[];    % remove test examplars from train

    % Train classifier
    [TCo]=train_sc(tn,trainlabel',m);
    % Test classifier
    [R]=test_sc(TCo,test,m,testlabel);


    % store accuracy for fold
    ac(loo)=R.ACC;
end

trainLOOACC2Class=mean(ac);


%% Offline setup TrainTest Targ vs NonTarg
[TCo]=train_sc(avTrainTrials3ch',classlabel',m);
% Test classifier

% Get unseen data and test target vs non target
[avTestTrialsTvsNT]=mvepfeaturesone(testTargStimRep,testNonTargStim,chan,rp,pi,avover);

[RR]=test_sc(TCo,avTestTrialsTvsNT',m,classlabel);
outn=RR.output;
% trainTestACC=RR.ACC;
testACC2class=RR.ACC;


% % %% Train and Test 5 Class (offline framework)
% %
% % for datType=1:2  %1=Train 2=Test
% %
% %     if datType==1
% %         [aa,bb,cc,dd,ee,avTarg,NonTarg360]=mvepfeaturesone(trainTargStim,trainNonTargStim,chan,rp,pi,avover);
% %     elseif datType==2
% %         [aa,bb,cc,dd,ee,avTarg,NonTarg360]=mvepfeaturesone(testTargStim,testNonTargStim,chan,rp,pi,avover);
% %     end
% %
% %     cl=zeros(1,5);
% %     idx=0;
% %     clear ViewStimulus
% %     for j=1:5   % for all targets
% %         notJ=1:5;
% %         notJ(j)=[];
% %
% %         sz=size(avTarg{j},2);
% %
% %         for i=1:sz    % for each trial structure targs and individual non-targs
% %             idx=idx+1;
% %             avTarg5{j}=avTarg{j}(:,i);
% %             for h=1:length(notJ)
% %                 avTarg5{notJ(h)}=NonTarg360{notJ(h)}(:,i);
% %             end
% %
% %             for on=1:5              % classify stim
% %                 [RRn]=test_sc(TCo,avTarg5{on}',m,1);
% %                 [cl(on)] = RRn.output(1);
% %             end
% %
% %             if ctype<4
% %                 [k,ViewStimulus(idx)]=max(cl);  %% this is sent to game to specify stimulus/target user wished to selected
% %             else
% %                 [k,ViewStimulus(idx)]=min(cl);  %% this is sent to game to specify stimulus/target user wished to selected
% %             end
% %
% %             %             (RRn.output(1)>0)+2*(RRn.output(1)<0)
% %         end
% %
% %         for h=1:length(notJ)
% %             NonTarg360{notJ(h)}(:,1:sz)=[];
% %         end
% %
% %     end
% %
% %     classLabel=[ones(1,sz),ones(1,sz)*2,ones(1,sz)*3,ones(1,sz)*4,ones(1,sz)*5];
% %
% %     if datType==1
% %         trainACC5class=length(find((ViewStimulus==classLabel)==1))/length(classLabel);
% %     elseif datType==2
% %         testACC5class=length(find((ViewStimulus==classLabel)==1))/length(classLabel);
% %     end
% % end
% % plot(ViewStimulus); hold on; plot(classLabel,'g');
% %
% % % 4 Results
% % % LOO Train Targ vs NonTarg ; Train 5 class test, Test Targ vs Non Targ,
% % % Test 5 class
% %
% % allACC=[trainLOOACC2Class, trainACC5class, testACC2class, testACC5class]*100


%% Save parameters for online
PM.chan=chan;
PM.leave=1:27  %leave;
PM.TCo=TCo;
PM.ctype=ctype;
PM.fs=fs;
PM.m=m;

% To be saved automatically to new name of subject
%save('subname','PM')

chan=PM.chan;
leave=PM.leave;
TCo=PM.TCo;


% m.TYPE='LD2';
% m.TYPE='SVM1r';
m.hyperparameter.c_value=5;

%% ONLINE
% fs=125;  % sampling frequency
% numChannels = 16;  %channels uwsed
% chan = [6 7 11]
pi = 9;
overall = [];

% pop=length(MVEP16.time);

pop=length(datMVEP);

numFeatures=length(chan)*pi;

featureRange=pi:pi+8;

trig_ch=numChannels +1;

sendudpindex=1;
idx=1;
s=[];
sa=zeros(size(datMVEP));
trigno=[];
% clear ViewStimulusRecord

% ViewStimulusRecord=zeros(1,60);

% PRE=-fs*0.2+1;
% PST=fs*1;



numTrials=5;
totTrigs=numTrials*5;

Hd=filterone;


pp=0
tic
%outerloop cycle of signals as if from EEG (this is time consuming as done sample by sample as in online mode
fss=125
for times= 500:fss:pop % speed up by searching every second (fs samples)
    %     times

    %finding the signal from each channel Signal
    %     for ja=1:17
    % %         s(:,ja)=squeeze(MVEP16.signals(1,ja).values(times,:));
    %
    %         %get all for testing
    %         %         sall(:,ja)=squeeze(MVEP16.signals(1,ja).values(:,:));
    %         %         plot(sall(:,17))
    %     end

    %     s=datMVEP(times,:);


    %sa collects samples as they are sent
    sa(idx:idx+fss,:)=datMVEP(times-fss:times,:);

    idx=idx+fss;

    sun=length(sa);

    TRIG=cell(1,5);
    overall=0;
    %     temptrig=[];

    %     tic
    %find triggers
    for i=1:5
        temptrig=sa(1:idx,trig_ch);
        temptrig(temptrig~=i)=0;
        TRIG{i} = gettrigger(temptrig); % trigger at ascending edge
        overall=overall+length(TRIG{i});
    end

    if overall >= totTrigs

        pp=pp+1
        % fill out the last trial - at least one second
        %         for ii=1:fs
        %             for ja=1:numChannels
        %                 %                 sa(idx+ii,ja)=squeeze(MVEP16.signals(1,ja).values(times+ii));
        %                 sa(idx+ii,ja)=datMVEP(times+ii,ja);
        %             end
        %         end

        %         sa(idx+1:idx+fs,:)=datMVEP(times+1:times+fs,:);


        %% Trigger
        for j=1:5
            %         overall
            % Trigger the data for the jth stimulus

            %             tic
            [X,sz] = trigg(sa(1:idx+fs+1000,:), TRIG{j}, PRE, PST );
            X3D = reshape(X,sz);

            notS=1:length(TRIG{j});

            %Baseline correction  - NO baseline correction online
            %             mch=zeros(1,numChannels);
            %             for u=1:numChannels
            %                 %              'buthere'
            %                 %average the basline period
            %                 mch(u)=mean(mean(squeeze(X3D(u,1:round(fs/5),:))));
            %                 %              'nothere'
            %                 X3D(u,:,:)=X3D(u,:,:)-mch(u);
            %             end

            % extract data for target and non target stimuli and store in cell
            Allstim=X3D(:,:,notS);

            %     end
            %     catch
            %       disp('Loop1')
            %     end
            %% Preprocess and Extract Features
            %     clear Fstim Fnonstim TwentyHz TwentyHzNon Targ NonTarg

            %     try
            %     AllFstim=cell(1,5);
            %     AllTwentyHz=cell(1,5);
            %     AllTarg=cell(1,5);
            %     for j=1:5
            %Filter required channels only

            %             Allstimtemp = Allstim

            size(Allstim)

            AllFstim=filter(Hd,Allstim(chan,:,:));
            sz=size(AllFstim);
            AllTwentyHz=zeros(sz(1),(1.2*fs)/(fs/20),sz(3));

            for k=1:avover
                % downsample at 20Hz
                AllTwentyHz(:,:,k)=resample((AllFstim(:,:,k))',20,fs)';

                % take feature points covering MVEP and concatenate feature vector
                AllTarg(:,k)=reshape(AllTwentyHz(:,featureRange,k)',numFeatures,1);
            end
            %     end
            %     catch
            %          a=lasterror
            %       disp('Loop2',a.message)
            %
            %     end


            %% Averaging features over trials
            %     try
            [mt,nt]=size(AllTarg);

            avs=1:avover:nt;
            ave=avover:avover:nt;

            trialsperclass=nt/avover;
            %     for j=1:5
            for i=1:nt/avover
                OnlineavTarg(:,i)=mean(AllTarg(:,avs(i):ave(i)),2);
                %                                 avNonTarg{j}(:,i)=mean(NonTarg{j}(:,avs(i):ave(i)),2);
            end

            %             leaves out the noisy features
            OnlineavTarg1{j}=OnlineavTarg;

            %             OnlineavTarg1{j}=mean(AllTarg,2);
            %             toc
            %     for j=1:5
            %             OnlineavTarg1{j}(leave,:)=[];
        end

        %         tic
        cl=zeros(1,5);
        for on=1:5
            [RRn]=test_sc(TCo,OnlineavTarg1{on}',m,1);
            [cl(on)] = RRn.output(1);
        end
        if ctype<4
            [k,ViewStimulusRecord(sendudpindex)]=max(cl);  %% this is sent to game to specify stimulus/target user wished to selected
        else
            [k,ViewStimulusRecord(sendudpindex)]=min(cl);  %% this is sent to game to specify stimulus/target user wished to selected
        end

        %reseting values for next loop
        overall=0;
        sa(1:idx,:)=[];
        sun=0;
        idx=1;
        sendudpindex=sendudpindex+1;

        %         break
        %         endC=cputime-C;
    end
end
toc

%% Do checks
% onlineclass=[1,1,1,2,2,2,3,3,3,4,4,4,5,5,5];
onlineclass=[1,2,3,4,5];
% onlineclass=repmat(onlineclass,1,6);
onlineclass=repmat(onlineclass,1,18);
% ViewStimulusRecord2=ViewStimulusRecord;
% ViewStimulusRecord2(ViewStimulusRecord2==0)=[];
ViewStimulusRecord;
% onlineACC=length(find((ViewStimulusRecord==onlineclass)==1))/length(ViewStimulusRecord);

trainACC5class=length(find(ViewStimulusRecord(1:end/2)==...
    onlineclass(1:length(ViewStimulusRecord)/2)==1))/(length(ViewStimulusRecord)/2);
testACC5class=length(find(ViewStimulusRecord(end/2+1:end)==...
    onlineclass(length(ViewStimulusRecord)/2+1:length(ViewStimulusRecord))==1))/(length(ViewStimulusRecord)/2);

trainACC5classNosplit=(trainACC5class+testACC5class)/2;



%figure(3)
hold off
%plot(ViewStimulusRecord)
hold on; %plot(onlineclass,'r')

%% Offline Results to report
%====Train
%     trainLOOACC2Class %2 class Leave-one-out CV accuracy LOO Targ vs NonTarg
%     trainACC5class    %5 class validation on training data
%====Test
%     testACC2class     %2 class Test data Targ vs Non Targ
%     testACC5class     %5 class test

% Only relevent when splits
% allACC=[trainLOOACC2Class, trainACC5class, testACC2class, testACC5class]*100;

% No split
allACC=[trainLOOACC2Class,trainACC5classNosplit]*100;


PM.allACC=allACC

% save(subjectname, 'datMVEP', 'PM')

