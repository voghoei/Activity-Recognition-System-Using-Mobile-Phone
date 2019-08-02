
function R = Project()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open a dialogbox to get the input info 
% of each person
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter bin#:','Enter level:','Enter nbcol:' };
dlg_title = 'Input';
num_lines = 1;
%answer = inputdlg(prompt,dlg_title,num_lines);

bin = 50; %bin
lev = 2; %level
nbcol = 16; %nbcol

folderName = strcat('ProcessedData-nbcol-',num2str(nbcol),'-lev-',num2str(lev),'-bin-',num2str(bin));
mkdir(folderName);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read a CSV file and put it in filename 
% D is the matrix that stores everything
% R is the result matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filename = uigetfile;
filename = dir ('TrainModel_Clean\All\*.csv');
for i=1:length(filename)
  
D = dlmread(strcat('TrainModel_Clean\All\',filename(i).name),',',1,0);
%D = csvread(strcat('Data\',filename(i).name)); 
str = strsplit (filename(i).name,'-');
%str(1,3)=tmp(1,1);
name = char(str(1,1));
actCVS = strsplit (char(str(1,2)),'.');
act = strcat(char(actCVS(1,1)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating wavelet transforms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fx = D(:,2);     % Data Channel X
Fy = D(:,3);     % Data Channel Y
Fz = D(:,4);     % Data Channel Z
 

%lev   = 5;       % Perform the discrete wavelet transform (DWT) at level 5 using mother wave.
wname = 'haar';   % haar db sym coif bior rbio meyr dmey gaus mexh morl cgau shan fbsp cmor
%nbcol = 64;

[cx,lx] = wavedec(Fx,lev,wname); 
[cy,ly] = wavedec(Fy,lev,wname); 
[cz,lz] = wavedec(Fz,lev,wname); %returns the decomposition structure, given the low- and high-pass decomposition filters you specify.   

 len = length(Fx);

%Expand discrete wavelet coefficients for plot.

cfdx = zeros(lev,len);

cfdy = zeros(lev,len);

cfdz = zeros(lev,len);

for k = 1:lev

    dx = detcoef(cx,lx,k);

    dy = detcoef(cy,ly,k);

    dz = detcoef(cz,lz,k);

    dx = dx(:)';

    dy = dy(:)';

    dz = dz(:)';

    dx = dx(ones(1,2^k),:);

    dy= dy(ones(1,2^k),:);

    dz = dz(ones(1,2^k),:);

    cfdx(k,:) = wkeep1(dx(:)',len);

    cfdy(k,:) = wkeep1(dy(:)',len);

    cfdz(k,:) = wkeep1(dz(:)',len);

end

 

cfdx =  cfdx(:);

cfdy =  cfdy(:);

cfdz =  cfdz(:);

Ix = find(abs(cfdx)<sqrt(eps));

Iy = find(abs(cfdy)<sqrt(eps));

Iz = find(abs(cfdz)<sqrt(eps));

cfdx(Ix) = zeros(size(Ix));

cfdy(Iy) = zeros(size(Iy));

cfdz(Iz) = zeros(size(Iz));

cfdx    = reshape(cfdx,lev,len);

cfdy    = reshape(cfdy,lev,len);

cfdz    = reshape(cfdz,lev,len);

cfdx = wcodemat(cfdx,nbcol,'row');

cfdy = wcodemat(cfdy,nbcol,'row');

cfdz = wcodemat(cfdz,nbcol,'row');

cfdtx = cfdx';

cfdty = cfdy';

cfdtz = cfdz';

%cfdtall = horzcat(D(:,2),D(:,3),D(:,4), cfdtx, cfdty, cfdtz, D(:,4));
cfdtall = horzcat(D(:,2),D(:,3),D(:,4), cfdtx, cfdty, cfdtz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill R array: 
% R[rows in D / bin, 18 + 3*3*lev]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[rows,cols] = size(D);
R = zeros(floor(rows/bin), 12+3*3*lev);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating averages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[m,n] = size(cfdtall);
dim = 1;
while dim <= n
   pos = 1 + dim;
   R(:,pos) = average(cfdtall, bin, dim);
   dim = dim + 1;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating standard deviations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dim = 1;
while dim <= n
   pos = 1 + n + dim ;
   R(:,pos) = standardDeviation(cfdtall, bin, dim);
   dim = dim + 1;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating mean absolute differences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dim = 1;
while dim <= n
   pos = 1 + 2 * n + dim ;
   R(:,pos) = meanAbsDiff(cfdtall, bin, dim);
   dim = dim + 1;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating average resultant
% accelerations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos = 1 + 3 * n + 1;
R(:,pos) = averageResultantAcc(cfdtall, bin, 3);
pos = 1 + 3 * n + 2;
R(:,pos) = averageResultantAcc(cfdtall, bin, n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Saving the result
% Please save it as a CSV file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R(:,1)= classGenerate(act);   % Class

csvwrite(strcat(folderName,'\',filename(i).name),R);

end;

function avgRA = averageResultantAcc(D, bin, dim)
[m,n] = size(D);
i = 1;
index = 1;
summation = 0;
sqrtSum = 0;
while(i+bin-1<=m)
    
    for j=i:i+bin-1
        if (dim == 3) % For X, Y, Z
            for counter = 1:dim
             summation =  summation + D(j,counter)^6;
            end;
            sqrtSum =  sqrtSum + sqrt(summation); 
        else
            for counter = 4:dim % For wavelet tranforms of X, Y, Z
              summation =  summation + D(j,counter)^6;
            end;
            sqrtSum =  sqrtSum + sqrt(summation); 
        end;
    end;
    avgRA(index,1) = sqrtSum/bin;
    i = i + bin;
    index = index + 1;
    
end;

function meanDiff = meanAbsDiff(D, bin, dim)
[m,n] = size(D);
i = 1;
index = 1;
while(i+bin-1<=m)
    meanDiff(index,1) = mad (D(i:i+bin-1, dim));
    i = i + bin;
    index = index + 1;
end;


function stdev = standardDeviation(D, bin, dim)
[m,n] = size(D);
i = 1;
index = 1;
while(i+bin-1<=m)
    stdev(index,1) = std (D(i:i+bin-1, dim));
    i = i + bin;
    index = index + 1;
end;


function avg = average(D, bin, dim)
[m,n] = size(D);
i = 1;
index = 1;
while(i+bin-1<=m)
    avg(index,1) = max (D(i:i+bin-1, dim));
    i = i + bin;
    index = index + 1;
end;

function classId = classGenerate(str)
    switch str
        case 'Walking'
            classId = 1;
            
        case 'Driving'
            classId = 2;
            
        case 'In'
            classId = 3;  
            
        case 'Out'
            classId = 4;
            
    end;
