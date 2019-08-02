function D = CombineAct()
%get the files in the desired folder
address = uigetdir;
folder_name = strsplit(address,'\');
[m,n] = size(folder_name);
folder_name = char(folder_name(1,n));
filename = dir (strcat(address,'\*.csv'));



%repeat for all the files
for i=1:length(filename)
  
D = dlmread(strcat(folder_name,'\',filename(i).name),',',1,0);


if(i==1)
    % initialize all the combined matrices in the first round
    [m,n] = size(D);    
    k = {'Class' 'AvgX' 'AvgY' 'AvgZ' 'AvgTX1' ' AvgTX2' 'AvgTY1' 'AvgTY2' 'AvgTZ1' 'AvgTZ2' 'StdX' 'StdY' 'StdZ' 'StdTX1' 'StdTX2' 'StdTY1' 'StdTY2' 'StdTZ1' 'StdTZ2' 'AbsDiffX' 'AbsDiffY' 'AbsDiffZ' 'AbsDiffTX1' 'AbsDiffTX2' 'AbsDiffTY1' 'AbsDiffTY2' 'AbsDiffTZ1' 'AbsDiffTZ2' 'AvgResultantXYZ' 'AvgResultantTXYZ'};
    EveryThing = k;    
    
end;

D = num2cell(D);
      
EveryThing = cat (1,EveryThing,D);

end;
folderName = strcat('result',folder_name);
mkdir(folderName);       
     
 fid = fopen(strcat(folderName,'\','EveryThing.csv'), 'w') ;
 fprintf(fid, '%s,', EveryThing{1,1:end-1}) ;
 fprintf(fid, '%s\n', EveryThing{1,end}) ;
 fclose(fid) ;       
 dlmwrite(strcat(folderName,'\','EveryThing.csv'),EveryThing(2:end,:), '-append');
 