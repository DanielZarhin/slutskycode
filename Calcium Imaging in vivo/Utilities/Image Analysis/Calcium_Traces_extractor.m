
%% Edited by Daniel Zarhin 02.06.2019

% This script extract calcium traces from CNMFE "results" file
% This script also work with the "Scalebar" function
% Only thing need to edit is the number of neurons to show:

%% 
Num2show = 50; % number of cell traces to show



add=0; %"space" between each trace
for i=1:Num2show;
    edited(i,:) = results.C(i,:)+add;
    add=add+50;
end


endtime = ((size(edited,2)/10)/60); %time vector in minutes

for i = 1:size(edited,1);
plot(linspace(1,endtime,size(edited,2)),edited(i,:),'linewidth',1,'color','b');
hold on
end

obj = scalebar;
obj.Position = [1, -50];
obj.YLen = [];             
obj.YUnit = [];
obj.XLen = 1; %length of scale bar


ylim([-50 add])
xlim([1 15])
box off
axis off ; 
set(gcf,'Color','w');

