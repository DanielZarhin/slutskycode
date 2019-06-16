
%% Edited by Daniel Zarhin 02.06.19

% This script creates image of the spatial foot prints location of neurons
% from the CNMFE "results" file


%% Create XY matrixe that contains all the neurons locations

 d1 = results.options.d1;
 d2 = results.options.d2;
 T = size(results.A,2);

 a = permute(reshape(full(results.A),d1,d2,T),[3 1 2]);


spatial_foot_print = zeros(size(a,2),size(a,3));


for i = 1:size(a,1);
    
    
    
    temp = squeeze(a(i,:,:));
    
    temp = temp/max(temp(:));
    
    temp(temp<0.7) = 0;
    
    [x(i,1),y(i,1)]=find(temp==1,1);
    
    spatial_foot_print= spatial_foot_print+temp;
   
    temp=[];
    
end
  
%% Creat spatial density map. X and Y vectors contain the center point of each neuron

figure;
imshow(spatial_foot_print), grid off, 
set(gcf,'Color','w');
 colormap bone;
 
hold on; %% to show specific neurons

number_to_show = 25; % number of neurons to show

for i = 1:number_to_show;
x0 = round(y(i));
y0 = round(x(i));
%plot([x0-gSiz, x0+gSiz, x0+gSiz, x0-gSiz, x0-gSiz], ...
    %[y0-gSiz, y0-gSiz, y0+gSiz, y0+gSiz, y0-gSiz], 'g');
    plot([x0],[y0], 'O','linewidth',2,'color', 'B');
    hold on;
end


%% ADD traces
    
add=0; %"space" between each trace
for i=1:number_to_show;
    edited(i,:) = results.C(i,:)+add;
    add=add+50;
end


endtime = ((size(edited,2)/10)/60); %time vector in minutes
figure; 
for i = 1:size(edited,1);
plot(linspace(1,endtime,size(edited,2)),edited(i,:),'linewidth',2,'color','B');
hold on
end


obj = scalebar;
obj.Position = [1, -50];
obj.YLen = [];             
obj.YUnit = [];
obj.XLen = 1; %length of scale bar 1 min probably


ylim([-50 (add-1)])
xlim([1 15])
box off
axis off ; 
set(gcf,'Color','w');

    
    
    
%% interesting stuff - Create denoised image by substracting the mean intensity

figure;
meanIntensity = mean(spatial_foot_print(:));
spatial_foot_print_binary = spatial_foot_print > meanIntensity;
imshow(spatial_foot_print_binary);



figure;

imshow(spatial_foot_print)
[L,W,D] = size(spatial_foot_print);
for i = 1:L
  for j = 1:W
      for k = 1:D
          if spatial_foot_print(i,j,k) == 0
              spatial_foot_print(i,j,k) = 255;
          end
      end
  end
end
figure(2)
image(spatial_foot_print);colormap bone;
set(gcf,'Color','w'); box off;set(gca,'visible','off');

