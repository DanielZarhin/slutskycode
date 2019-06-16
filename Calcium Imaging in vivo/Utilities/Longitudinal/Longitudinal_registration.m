


%% Edited by Daniel Zarhin 16.6.19
% This script needs the following: DFF from session 1 (call it "DFF1"), DFF from session 2 (call it "DFF2"),
% and the file "cell_registered_struct" (output of the longitudinal
% registraction "Cell_Reg" function)

%% 
cell_to_index_map = cell_registered_struct.cell_to_index_map;
zerosout = cell_to_index_map(all(cell_to_index_map,2),:);

% create vector that contains the data of same neurons: session 1 on the
% left, session 2 on the right

%delete rows that dont make sense:
zerosounew=zerosout;
zerosounew(find(zerosout(:,2)> size(DFF2,2)),:)=[];
zerosounew(find(zerosounew(:,1)> size(DFF1,2)),:)=[];



for i = 1: size(zerosounew,1);
    if zerosounew(i,1)> size(DFF1,2);
        continue;
    else
    Registerd_neurons(i,1)= DFF1(1,zerosounew(i,1));
    end
    
    if zerosounew(i,2)> size(DFF2,2);
        continue;
    else
    Registerd_neurons(i,2)= DFF2(1,zerosounew(i,2));
     Registerd_neurons(i,3)=Registerd_neurons(i,2)/Registerd_neurons(i,1);
    end
    
    
end




plot(Registerd_neurons(:,1),Registerd_neurons(:,2),'.')
xlim([0 100])
ylim([0 100])


MeanDFF=Registerd_neurons(:,1);
SecMeanDFF=Registerd_neurons(:,2);
high_th = 1.25;
low_th = 0.75;
high_values_indices = find(Registerd_neurons(:,3) > high_th);
low_values_indices = find(Registerd_neurons(:,3) < low_th);

high_values = MeanDFF(high_values_indices);
high_SecMeanDFF = SecMeanDFF(high_values_indices);
low_values = MeanDFF(low_values_indices);
low_SecMeanDFF = SecMeanDFF(low_values_indices);

outOfLinear = (length(high_values) + length(low_values))/length((Registerd_neurons(:,3)));
high_precent = 100*length(high_values)/length((Registerd_neurons(:,3)));
low_precent =  100*length(low_values)/length((Registerd_neurons(:,3)));
inLinearPrecentage = 100*(1 - outOfLinear);






figure('Renderer', 'painters', 'Position', [500 500 300 300])
hold on,
pointsize = 20;
scatter( MeanDFF,SecMeanDFF, pointsize, 'green');
firstScatterString = sprintf('%% %.3f', inLinearPrecentage);
scatter(high_values,high_SecMeanDFF, pointsize, 'red');
secondScatterString = sprintf('%% %.3f', high_precent);
scatter(low_values, low_SecMeanDFF,pointsize, 'blue');
thirdScatterString = sprintf('%% %.3f', low_precent);
hold on,
plot(linspace(1,150)',linspace(1,150)','color','k','LineStyle',':');


title('Exploration Vs Isoflurane');
legend(firstScatterString,secondScatterString,thirdScatterString);
set(gcf,'color','w'); 
xlabel('Exploration (mCaR/Min)');
ylabel('Isoflurane(mCaR/Min)');
ylim([0 150])
xlim([0 150])



size(data,1)


x=[1:(size(data,1))/2];
y= [((size(data,1))/2)+1:size(data,1)]



for i =1:size(Registerd_neurons,1);
    
Registerd_neurons(i,3)=Registerd_neurons(i,2)/Registerd_neurons(i,1);
end

% Session specific analysis

% This script needs the following: DFF from session 1, DFF from session 2,
% and the file "cell_registered_struct"
% it will delete the common neurons so the analysis will be of the session
% specific only 

DFF1_Specific = DFF1;
DFF1_Specific(zerosounew(:,1)') = 0;
DFF1_Specific = DFF1_Specific(DFF1_Specific ~= 0);

DFF2_Specific = DFF2;
DFF2_Specific(zerosounew(:,2)') = 0;
DFF2_Specific = DFF2_Specific(DFF2_Specific ~= 0);






%% just added

%Reg_full =[Registerd_neurons;Registerd_neurons2];
a=  Reg_full(:,1) %[Registerd_neurons(:,1);
b=  Reg_full(:,2)  %[Registerd_neurons(:,2);
figure('Renderer', 'painters', 'Position', [500 500 300 300])

scatter(a,b,5,'*','r')

hold on,
plot(linspace(0,2.5)',linspace(0,2.5)','color','k','LineStyle',':','LineWidth',2);

title('Exploration 1 Vs Exploration 2');
set(gcf,'color','w'); 
xlabel('Exploration 1 mCaR(Hz)');
ylabel('Exploration 2 mCaR(Hz)');
ylim([0 2.5])
xlim([0 2.5])





