function VennDiagram(CellToIndexMap,Sess1ID,Sess2ID,Sess3ID)
    if nargin <= 2
        error('Cell to index map and at least two session IDs are required.');
    elseif nargin == 3
        %% Edited by Daniel Zarhin 16.06.19
        % This function create Venn diagram (2 or 3 circle) by calling the function "Venn",
        % and getting the input of "cell_to_index_map" (output of the
        % longitudinal registraction "Cell_Reg" function
        
        % example:
        %  VennDiagram(cell_registered_struct.cell_to_index_map,1,2);
        
        %% Draw a 2 circle Venn diagram
        
        % Calculate venn diagram group sizes and overlap
        i1 = length(find(CellToIndexMap(:,Sess1ID)>0));
        i2 = length(find(CellToIndexMap(:,Sess2ID)>0));
        i12 = length(find(CellToIndexMap(:,Sess1ID)>0 & CellToIndexMap(:,Sess2ID)>0));
        
        % Display venn diagram and its parameters
        % for names: 
        %names = {'Awake ','Isoflurane ',' '};
        % Venn explained - venn([size of A size of B], size AB)
        
          figure('Renderer', 'painters', 'Position', [10 10 400 250])
        [H,S]=venn([i1 i2],i12,'FaceColor',{'b','w'});
        
        set(gca,'Color','none','XColor','none','YColor','none');
        set(gcf,'Color','w');
        
        movement = [3 0 1]; %move each number to a specific location. defult is [0 0 0]
        for i = 1:length(S.ZoneCentroid) 
        text(S.ZoneCentroid(i,1)-movement(i), S.ZoneCentroid(i,2), num2str(S.ZonePop(i)),'FontSize',13); 
        end 
       
        % enable next part for names
       %for i = 1:length(S.ZoneCentroid) 
        %text(S.ZoneCentroid(i,1)-4, S.ZoneCentroid(i,2)+5, [cell2mat(names(i))],'FontSize',10); 
        %end

        
        
        %pbaspect([2 1 1])
        fprintf('%% venn([i1 i2],i12)\nvenn([%d %d],[%d])\n',i1,i2,i12);
        fprintf('i1 Only (i1 - i12) = %d\n',i1 - i12);
        fprintf('i2 Only (i2 - i12) = %d\n',i2 - i12);
        fprintf('i1 & i2 (i12) = %d\n',i12);
    elseif nargin == 4
        %% Draw a 3 circle Venn diagram
        
        % Calculate venn diagram group sizes and overlap
        i1 = length(find(CellToIndexMap(:,Sess1ID)>0));
        i2 = length(find(CellToIndexMap(:,Sess2ID)>0));
        i3 = length(find(CellToIndexMap(:,Sess3ID)>0));
        i12 = length(find(CellToIndexMap(:,Sess1ID)>0 & CellToIndexMap(:,Sess2ID)>0));
        i13 = length(find(CellToIndexMap(:,Sess1ID)>0 & CellToIndexMap(:,Sess3ID)>0));
        i23 = length(find(CellToIndexMap(:,Sess2ID)>0 & CellToIndexMap(:,Sess3ID)>0));
        i123 = length(find(CellToIndexMap(:,Sess1ID)>0 & CellToIndexMap(:,Sess2ID)>0 & CellToIndexMap(:,Sess3ID)>0));
        
        % Display venn diagram and its parameters
       % venn([i1 i2 i3],[i12 i13 i23 i123])
       % set(gca,'Color','none','XColor','none','YColor','none');
       % set(gcf,'Color','w');
       % fprintf('%% venn([i1 i2 i3],[i12 i13 i23 i123])\nvenn([%d %d %d],[%d %d %d %d])\n',i1,i2,i3,i12,i13,i23,i123);
       % fprintf('i1 Only (i1 - i12 - i13 + i123) = %d\n',i1 - i12 - i13 + i123);
       % fprintf('i2 Only (i2 - i12 - i23 + i123) = %d\n',i2 - i12 - i23 + i123);
       % fprintf('i3 Only (i3 - i13 - i23 + i123) = %d\n',i3 - i13 - i23 + i123);
       % fprintf('i1 & i2 Intersect without i3 (i12 - i123) = %d\n',i12 - i123);
       % fprintf('i2 & i3 Intersect without i1 (i23 - i123) = %d\n',i23 - i123);
       % fprintf('i1 & i3 Intersect without i2 (i13 - i123) = %d\n',i13 - i123);
        %fprintf('i1 & i2 & i3 (i123) = %d\n',i123);
        
           figure('Renderer', 'painters', 'Position', [10 10 400 250])
        [H,S]=venn([i1 i2 i3],[i12 i13 i23 i123],'FaceColor',{'r','g','b'});
        
        set(gca,'Color','none','XColor','none','YColor','none');
        set(gcf,'Color','w');
        
        movement = [2 0 0 1 3 0 0]; %move each number to a specific location. defult is [0 0 0]
        for i = 1:length(S.ZoneCentroid) 
        text(S.ZoneCentroid(i,1)-movement(i), S.ZoneCentroid(i,2), num2str(S.ZonePop(i)),'FontSize',13); 
        end 
        
        
    end
end