%% this script is for twins analysys, it loads a csv table of twins database, 
%% then it keep only two twins subjects and eliminate the rest. it is based on
%% family ID, if a familt ID number is found twice, then the subject are kept 
%% otherwise the subject is eliminated. 
clear
%read raw twins_pedigre
path_pedigre = '/media/database3/twins_study/fir_heritability/';
csv_cell     = niak_read_csv_cell ([ path_pedigre 'twins_pedigre.csv' ]);

% select colomn of interest (here is the familly ID)
sxx=csv_cell(:,3);
ind_currLine=0;
% Create numeric array
for ij = 2:length(sxx)
  ss(ij) = str2double(sxx{ij}); 
end

% Create comparison
for ij = 2:length(sxx)
  % get current value
  tempVal = str2double(sxx(ij));
  % make list of all other values but current

  tempList=[];
  if ij ==2
    tempList = ss(ij+1:end);
  elseif ij ==length(ss)
    tempList = ss(2:ij-1) ;
  else % case current value is not first or last
    tempList = [ss(2:ij-1) ss(ij+1:end)];
  end % if ij ==1
  % convert string to double
 
  % find repeated value
  flag_double = any(tempVal==tempList);

  % repeated values are copied somewhere
  if flag_double
    ind_currLine = ind_currLine+1;
    repStruct (ind_currLine,:) = csv_cell(ij,:);
  end % if flag_double
end % for ij
repStruct_cell          = cell(length(repStruct)+1, size(repStruct)(2));
repStruct_cell(1,:)     = csv_cell(1,:);
repStruct_cell(2:end,:) = repStruct;

% wright csv file
niak_write_csv_cell ( [path_pedigre 'twins_pedigre_clean.csv'] , repStruct_cell );

%test of conformity of result
xx=repStruct(:,3);
for ii=1:size(xx,1)-2
  if xx{ii}==xx{ii+2};
     ii
  end
end
