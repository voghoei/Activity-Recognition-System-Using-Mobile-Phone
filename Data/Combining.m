function D = Combining()
%get the files in the desired folder
address = uigetdir;
folder_name = strsplit(address,'\');
[m,n] = size(folder_name);
folder_name = char(folder_name(1,n));
filename = dir (strcat(folder_name,'\*.csv'));



%repeat for all the files
for i=1:length(filename)
  
D = dlmread(strcat(folder_name,'\',filename(i).name),',',1,0);
str = strsplit (filename(i).name,'-');
tmp = strsplit(char(str(1,3)),'.');
str(1,3)=tmp(1,1);
name = char(str(1,1));
act = strcat(char(str(1,2)));

if(i==1)
    % initialize all the combined matrices in the first round
    [m,n] = size(D);
    
    k = {'Class' 'AvgX' 'AvgY' 'AvgZ' 'AvgTX1' ' AvgTX2' 'AvgTY1' 'AvgTY2' 'AvgTZ1' 'AvgTZ2' 'StdX' 'StdY' 'StdZ' 'StdTX1' 'StdTX2' 'StdTY1' 'StdTY2' 'StdTZ1' 'StdTZ2' 'AbsDiffX' 'AbsDiffY' 'AbsDiffZ' 'AbsDiffTX1' 'AbsDiffTX2' 'AbsDiffTY1' 'AbsDiffTY2' 'AbsDiffTZ1' 'AbsDiffTZ2' 'AvgResultantXYZ' 'AvgResultantTXYZ'};
    
    Abbas = k;
    Navid = k;
    EveryThing = k;
    
    Walking = k;
    Driving = k;
    Out = k;
    In = k;
    
end;

D = num2cell(D);
switch name
    case 'Abbas'
        Abbas = vertcat(Abbas,D);
        EveryThing = cat (1,EveryThing,D);
    case 'Navid'
        Navid = cat (1,Navid,D);
        EveryThing = cat (1,EveryThing,D);    
end

    switch act
        case 'Walking'
            Walking = vertcat (Walking,D);           
           
        case 'Driving'
            Driving = vertcat (Driving,D);             
            
        case 'In'
            In = vertcat (In,D); 
                      
        case 'Out'
            Out = vertcat (Out,D); 
                                  
    end;    

end;

   folderName = strcat('result',folder_name);
   mkdir(folderName);    
   
 fid = fopen(strcat(folderName,'\','Abbas.csv'), 'w') ;
 fprintf(fid, '%s,', Abbas{1,1:end-1}) ;
 fprintf(fid, '%s\n', Abbas{1,end}) ;
 fclose(fid) ;    
 dlmwrite(strcat(folderName,'\','Abbas.csv'),Abbas(2:end,:), '-append');
    
 fid = fopen(strcat(folderName,'\','EveryThing.csv'), 'w') ;
 fprintf(fid, '%s,', EveryThing{1,1:end-1}) ;
 fprintf(fid, '%s\n', EveryThing{1,end}) ;
 fclose(fid) ;       
 dlmwrite(strcat(folderName,'\','EveryThing.csv'),EveryThing(2:end,:), '-append');
    
 fid = fopen(strcat(folderName,'\','Navid.csv'), 'w') ;
 fprintf(fid, '%s,', Navid{1,1:end-1}) ;
 fprintf(fid, '%s\n', Navid{1,end}) ;
 fclose(fid) ;       
 dlmwrite(strcat(folderName,'\','Navid.csv'),Navid(2:end,:), '-append');
    
 fid = fopen(strcat(folderName,'\','Walking.csv'), 'w') ;
 fprintf(fid, '%s,', Walking{1,1:end-1}) ;
 fprintf(fid, '%s\n', Walking{1,end}) ;
 fclose(fid) ;       
 dlmwrite(strcat(folderName,'\','Walking.csv'),Walking(2:end,:), '-append');
    
 fid = fopen(strcat(folderName,'\','Driving.csv'), 'w') ;
 fprintf(fid, '%s,', Driving{1,1:end-1}) ;
 fprintf(fid, '%s\n', Driving{1,end}) ;
 fclose(fid) ;      
 dlmwrite(strcat(folderName,'\','Driving.csv'),Driving(2:end,:), '-append');
    
 fid = fopen(strcat(folderName,'\','In.csv'), 'w') ;
 fprintf(fid, '%s,', In{1,1:end-1}) ;
 fprintf(fid, '%s\n', In{1,end}) ;
 fclose(fid) ;       
 dlmwrite(strcat(folderName,'\','In.csv'),In(2:end,:), '-append');
    
 fid = fopen(strcat(folderName,'\','Out.csv'), 'w') ;
 fprintf(fid, '%s,', Out{1,1:end-1}) ;
 fprintf(fid, '%s\n', Out{1,end}) ;
 fclose(fid) ;     
 dlmwrite(strcat(folderName,'\','Out.csv'),Out(2:end,:), '-append');
   