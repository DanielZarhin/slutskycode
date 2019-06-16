

%% Edited by Daniel Zarhin 16.6.19

%This script will extract calcium traces as calculated from CNMFE output "results" and display each neuron calcium transients rate in
%bins of # minutes

% at the end of the script you will find extra anlysis such as Raster plot,
% precentile calculation, pattern analysis


%% Create spars mat to table. deafult data is the "results.S" which is the estimation of action potentials calculated from the size of delta F

[nrn,time,amp] = find(results.S);
[~, idx] = sort(nrn);
Table = [time(idx) nrn(idx) amp(idx)];

clear nrn time amp idx results

alldata{1,1}='Time (s)';
alldata{1,2}=' Cell Name';
alldata{1,3}=' Value';

for i=2:(size(Table,1)+1);
        alldata{i,1} = (Table(i-1,1))/10; %convert frames to Sec (10Hz)
        alldata{i,2} = num2str(Table(i-1,2));
        alldata{i,3} = Table(i-1,3);
end

clear i Table

%% Run this part for total session analysis (recommended) - Every neuron will be represented with one value which is the mean activity of all the recording

number_of_sessions = 1;
time_of_record= max(cell2mat(alldata(2:size(alldata,1),1)));

Start_time_1 = 0 ; End_time_1 =max(cell2mat(alldata(2:size(alldata,1),1)));

% By looking at the raster plot, write the exact times of each session (for specific section only):
%Start_time_1 =500 ; End_time_1 =900;
time_of_record= End_time_1 - Start_time_1;

%calculate bins
for i=1:number_of_sessions;
    Bins(i,1) = eval(['Start_time_' num2str(i)]); Bins(i,2) = eval(['End_time_' num2str(i)]);
end
 

%% Run this part for 1 Second bin analysis

bins_size = 1 %sec
number_of_bins = ceil(max(cell2mat(alldata(2:size(alldata,1),1))));
% for seconds ceil(max(cell2mat(alldata(2:size(alldata,1),1))))
for i=1:number_of_bins;
    Bins(i,1) = (i-1)*bins_size; Bins(i,2) = i*bins_size;
end
time_of_record= bins_size;
number_of_sessions = size(Bins,1);

%% Run this part for 5 Seconds bin analysis

bins_size = 5%sec
number_of_bins = ceil(max(cell2mat(alldata(2:size(alldata,1),1))));
% for seconds ceil(max(cell2mat(alldata(2:size(alldata,1),1))))
for i=1:number_of_bins;
    Bins(i,1) = (i-1)*bins_size; Bins(i,2) = i*bins_size;
end
time_of_record= bins_size;
number_of_sessions = size(Bins,1);


%% Run this part for 60 Seconds bin analysis
bins_size = 60 %sec
number_of_bins = 15;
% for seconds ceil(max(cell2mat(alldata(2:size(alldata,1),1))))
for i=1:number_of_bins;
    Bins(i,1) = (i-1)*bins_size; Bins(i,2) = i*bins_size;
end
time_of_record= bins_size;
number_of_sessions = size(Bins,1);




%% Run this part for 180 Seconds bin analysis
bins_size = 180 %sec
number_of_bins = 5;
% for seconds ceil(max(cell2mat(alldata(2:size(alldata,1),1))))
for i=1:number_of_bins;
    Bins(i,1) = (i-1)*bins_size; Bins(i,2) = i*bins_size;
end
time_of_record= bins_size;
number_of_sessions = size(Bins,1);

%% Run this part for 300 Seconds bin analysis
bins_size = 300 %sec
number_of_bins = 3;
% for seconds ceil(max(cell2mat(alldata(2:size(alldata,1),1))))
for i=1:number_of_bins;
    Bins(i,1) = (i-1)*bins_size; Bins(i,2) = i*bins_size;
end
time_of_record= bins_size;
number_of_sessions = size(Bins,1);


%% Run this part for 0.1 Second bin analysis
bins_size = 0.1 %sec
number_of_bins = 9000;
% for seconds ceil(max(cell2mat(alldata(2:size(alldata,1),1))))
for i=1:number_of_bins;
    Bins(i,1) = (i-1)*bins_size; Bins(i,2) = i*bins_size;
end
time_of_record= bins_size;
number_of_sessions = size(Bins,1);




%% After chosing the binning, start calcium activity analysis:

clear i Start_time_1 Start_time_2 Start_time_3 Start_time_4 Start_time_5 End_time_1 End_time_2 End_time_3 End_time_4 End_time_5;


% Find the location of each neuron transient, output is "locations"
L=size(alldata,1);
b=2;
z=0;
c=1;
locations=zeros(L,2);
for a=b:L;
    if a+1>L;
    continue
    elseif strcmp(alldata(a,2),alldata(a+1,2))==1;
    continue
else e = a;z=z+1; locations(z,1)=b; locations(z,2)=a; b=a+1;
end
end

z=z+1; locations(z,1)=b; locations(z,2)=a; b=a+1;
locations = locations(any(locations,2),:);

clear a b c e L z 

% Calculated the mean activity in Hz, output is "DFF"

DFF=zeros(number_of_sessions,size(locations,1)); % every column is a different neuron, every raw stands for a different time bin
a=0;
for i=1:size(locations,1); %number of neuron I study
   for l=1:(number_of_sessions); % go through each bin to check something
       for k=locations(i,1):locations(i,2); %go through each time stamp of the neuron activity
           if cell2mat(alldata(k,1))> Bins(l,1) && cell2mat(alldata(k,1))< Bins(l,2);
               a=a+cell2mat(alldata(k,3));
           end
       end
       if a==0;
           DFF(l,i)=0; %0Hz
       else DFF(l,i)= a/time_of_record; % in Hz
       end
       a=0;
   end
end
clear i a k l;


% Calculated the mean number of transients , output is "TransientRate"

TransientsRate=zeros(number_of_sessions,size(locations,1)); % every column is a different neuron, every raw stands for a different time bin
a=0;
for i=1:size(locations,1); %number of neuron I study
   for l=1:(number_of_sessions); % go through each bin to check something
       for k=locations(i,1):locations(i,2); %go through each time stamp of the neuron activity
           if cell2mat(alldata(k,1))> Bins(l,1) && cell2mat(alldata(k,1))<  Bins(l,2);
               a=a+1;
           end
       end
       if a==0;
           TransientsRate(l,i)=0; %0Hz
       else TransientsRate(l,i)= a/time_of_record; % in Hz
       end
       a=0;
   end
end
clear i a k l;

%DFF=DFF*60;
%TransientsRate=TransientsRate*60;

clear i a k l text   ndata maximumtime  i  delete bins a  Start_time_1 Start_time_2 Start_time_3 Start_time_4 Start_time_5 End_time_1 End_time_2 End_time_3 End_time_4 End_time_5 a ;    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% END OF DFF CALCULATION

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create Raster plot + Synch vector 

for i= 1:length(locations);
    k=locations(i,1):locations(i,2);
    cellsofneuronsevents{i,1} = cell2mat(alldata(k,1));
    cellsofneuronsevents{i,3} = cell2mat(alldata(k,3));
    cellsofneuronsevents{i,2} = (ones((length( cellsofneuronsevents{i,1})),1)*i);
    
end


X=cat( 1, cellsofneuronsevents{:,1} )';
X=X';

Y=cat( 1, cellsofneuronsevents{:,2} )';
Y=Y';

Z=cat( 1, cellsofneuronsevents{:,3} )';
Z=Z';


% Synch activity
% cellsofneuronsevent contains the time of each neuron fired, neuron number, value of that firing 
size_of_bins =1; %size of the bins to find synchronous activity (in seconds)

Vec_Synch = zeros(round(round(Bins(end))/size_of_bins),1); % size of the vector

count = 0;
for i=1:length(Vec_Synch);
    for a=1:length(cellsofneuronsevents);
        temp = cellsofneuronsevents{a,1};
        if sum(find(temp>(size_of_bins*i - size_of_bins ) & temp<(size_of_bins*i)))> 0;
            count=count+1;
        end
    end
    Vec_Synch(i,1) = (count/length(cellsofneuronsevents))*100;
    Vec_Synch(i,3) = (count); %number of neurons not normelized;
    
    count = 0;
end

Vec_Synch(1:length(Vec_Synch),2) = (1:length(Vec_Synch))*size_of_bins;

%Raster

figure

[ax h1 h2]=plotyy(X,Y,Vec_Synch(:,2),Vec_Synch(:,1))
set(h1,'Marker','*','MarkerSize',2,'LineStyle', 'none','color','k')
set(h2,'LineWidth',1,'color','r')
ylabel(ax(1),'Raster Plot (Unit #)') % label left y-axis
ylabel(ax(2),'Sync. %') % label right y-axis
xlim(ax(2),[Bins(1,1) Bins(1,2)])
xlim(ax(1),[Bins(1,1) Bins(1,2)])
ylim(ax(1),[0 length(cellsofneuronsevents)])
ylim(ax(2),[0 100]);


% If you want to add lines:

%line([210 210], [0 500],'LineWidth',1,'LineStyle','-','color','r');
line([210 210], [0 500],'LineWidth',1,'LineStyle','-','color','r');
%line([270 270], [0 500],'LineWidth',1,'LineStyle','-','color','r');
line([225 225], [0 500],'LineWidth',1,'LineStyle','-','color','r');
%line([330 330], [0 500],'LineWidth',1,'LineStyle','-','color','r');

%line([390  390 ], [0 500],'LineWidth',1,'LineStyle','-','color','r');
line([420 420], [0 500],'LineWidth',1,'LineStyle','-','color','r');
%line([450 450], [0 500],'LineWidth',1,'LineStyle','-','color','r');
line([480 480], [0 500],'LineWidth',1,'LineStyle','-','color','r');
%line([510 510], [0 500],'LineWidth',1,'LineStyle','-','color','r');


%line([570 570], [0 500],'LineWidth',1,'LineStyle','-','color','r');
line([600 600], [0 500],'LineWidth',1,'LineStyle','-','color','r');
%line([630 630], [0 500],'LineWidth',1,'LineStyle','-','color','r');
line([660 660], [0 500],'LineWidth',1,'LineStyle','-','color','r');
%line([690 690], [0 500],'LineWidth',1,'LineStyle','-','color','r');



%line([750 750], [0 500],'LineWidth',1,'LineStyle','-','color','r');
line([780 780], [0 500],'LineWidth',1,'LineStyle','-','color','r');
%line([810 810], [0 500],'LineWidth',1,'LineStyle','-','color','r');
line([840 840], [0 500],'LineWidth',1,'LineStyle','-','color','r');
%line([870 870], [0 500],'LineWidth',1,'LineStyle','-','color','r');


%% Precentile calculation

% Precentile
% first value of 33% prencentile
%P33 = prctile(DFF,33)
sum(DFF<P33)

% first value of 66% prencentile
%P66 = prctile(DFF,66)
sum(P33<DFF & DFF<P66 )

% first value of 100% prencentile
%P100 = prctile(DFF,100)

sum(P66<DFF & DFF<P100 )







%% Pattern anlysis (network and single cell)

% Calculate peak of bursts
test = Vec_Synch(:,1);
[pks,locs,w]=findpeaks(test,'Annotate','extents','MinPeakHeight', 5);
peakInterval = (diff(locs));
peakWidth= (w);
peakAmplitude = (pks); %precent of neurons on the peaks
peakAmplitude_no_norm = Vec_Synch(locs,3); %number of neurons on the peaks


% Precentile calculation (how many cells in a range of MFR)
%a = (wake >0& wake <17.49);
%sum(a)/length(wake)



% Calculate fraction of spikes in network bursts (for every neuron check
% how many spikes in network bursts - for all the neurons)
% Check only the specific range

test = Vec_Synch(:,1);
[pks,locs,w]=findpeaks(test,'Annotate','extents','MinPeakHeight', 5);

minimum =Bins(1,1);
maximum=Bins(1,2);
Timeinburst = (sum(w)/(maximum-minimum)); % Normalized to precent time in bursts!!!!!
Numberofneurons =  size(locations,1);
locsTest=locs(locs >minimum& locs <maximum);
count = 0 ;
countevents=0;

for i= 1:size(cellsofneuronsevents,1);
    temp = cellsofneuronsevents{i,1};
    temp = temp(temp>minimum & temp< maximum); %find all events between time range
    
    
    
    for b=1:size(temp,1);
        for c=1:size(locsTest,1);
        if temp(b,1) > (locsTest(c,1)-1.5) & temp(b,1) < (locsTest(c,1)+1.5);
            count = count+1;
        end
        end
        if count >=1 ;
            countevents = countevents+1;
        end
        count=0;
    end
        spikesinbursts(i,1) = countevents; % number of spikes that neuron fired during network burst
        spikesinbursts(i,2) = size(temp,1); %number of total spikes that neuron fired
        spikesinbursts(i,3) = (countevents/size(temp,1));% /Timeinburst; add this only if you want to norm to time in burst
        countevents=0;
        temp=[];
end


% Calculate number of spikes per network burst
  
Allspikes =X;
Allspikes = Allspikes(Allspikes>minimum & Allspikes< maximum);

for i = 1:size(locsTest,1);
    a= sum(Allspikes> (locsTest(i,1) - 1) & Allspikes< (locsTest(i,1) + 1));
    Number_of_spikes_in_net_burst(i,1)=a; %/Numberofneurons; %add this if you want to normelized to the number of neurons
    a=[];
end
        



% caclulate the vent interval of every neuron


b=mean([A(1:end-1);A(2:end)]);
A=[2 4 6 8 10]';
B=diff(A); %differance of every 2 consecutive values
b=mean([A(1:end-1),A(2:end)],2); %mean of every 2 consecutive values



for i = 1:size(cellsofneuronsevents,1);
temp_times = cellsofneuronsevents{i,1};
temp_Spikes = cellsofneuronsevents{i,3};
Intervals_meanSplikes{i,1}= diff(temp_times);
Intervals_meanSplikes{i,2}= mean([temp_Spikes(1:end-1),temp_Spikes(2:end)],2);

temp_times = [];
temp_Spikes = [];

end

% what is the fraction of calcium transients in unit burst? number of intervals smaller
% then 0.5, divided by the total amount of calcium transients (length of intervals + 1) - this is the left column
% What is the mean spikes rate (Hz) of the burst? the mean spikes of calcium
% transients found to be bursts - this is the right column
% what is the fraction of calcium transients in unit burst? number of intervals smaller
% then 0.5, divided by the total amount of calcium transients (length of
% intervals + 1) - then sum of spikes in buest divide by total spikes -
% third column


Thresh = 0.1;
for  i = 1:size(Intervals_meanSplikes,1); 
    temp_interval = Intervals_meanSplikes{i,1};
    temp_spikes = Intervals_meanSplikes{i,2};
    count = 0;
    Sum_spikes = 0;
    for b=1:size(temp_interval,1);
        if temp_interval(b,1)<Thresh;
            count = count+1;
            Sum_spikes = Sum_spikes + temp_spikes(b,1);
        end
    end
    Calcium_transients_fraction(i,1) = count/(size(temp_interval,1)+1);
    Calcium_transients_fraction(i,2) = (Sum_spikes)/count;
    Calcium_transients_fraction(i,3) = mean(temp_interval);
   
    count=0;
    Sum_spikes=0;
end


idx    = isnan(Calcium_transients_fraction(:,2));
Calcium_transients_fraction(idx,2) = 0;

idx    = isnan(Calcium_transients_fraction(:,3));
Calcium_transients_fraction(idx,3) = 0;

%Calcium_transients_fraction = Calcium_transients_fraction(any(Calcium_transients_fraction,2),:);


plot(Calcium_transients_fraction(:,1),Calcium_transients_fraction(:,2),'.')

