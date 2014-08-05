function csv_cell_combin = niak_combine_csv_cell(file_master,file_slave,opt)
% Search and Combine matching cell table's rows from two distingt csv files ( One master files and one slave)
%
% SYNTAX:
% CSV_CELL_COMBINE = NIAK_COMBINE_CSV_CELL(FILE_MASTER,FILE_SLAVE,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% FILE_MASTER     
%	(string) the name of the csv file (usually ends in .csv) that is used as reference
% 
% FILE_SLAVE     
%	(string) the name of the csv file (usually ends in .csv) that is used as combiner
% 
% OPT
%   (structure, optional) with the following fields:
%
%   HEADER
%       (boolean, default true) the first rows are the table's headers.
%
%   COMBINE_MASTER_COLOMN
%       (number, default '1') choose wich colomn to use as reference for combininng with salve.
%
%   COMBINE_SLAVE_COLOMN
%       (number, default '1') choose wich colomn to use as reference for combininng with master.
%
% _________________________________________________________________________
% OUTPUTS:
%
% CSV_CELL_COMBINE
%   (cell of strings) CSV_CELL{i,j} is a string corresponding to the ith row
%   and jth column of the Master csv file combined with the corresponding ith row
%   and jth column of the Slave csv file .
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_WRITE_CSV_CELL
% NIAK_READ_CSV_CELL
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec,
% Centre de recherche de l'institut de gériatrie de Montréal, 
% Department of Computer Science and Operations Research
% University of Montreal, Québec, Canada, 2013
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : table, CSV

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
% 
%file_master='/home/yassinebha/Dropbox/twins_study/twins_data/behavioral_data_yassine/Data_combine/subj_select_dom.csv';
%file_slave='/home/yassinebha/Dropbox/twins_study/twins_data/behavioral_data_yassine/Data_combine/subj_select.csv';
if ~exist(file_master,'file')
    error(cat(2,'Could not find any file matching the description ',file_master));
end
if ~exist(file_slave,'file')
    error(cat(2,'Could not find any file matching the description ',file_slave));
end

%% Set default options
list_fields   = {'header' , 'combine_master_colomn' , 'combine_slave_colomn' };
list_defaults = { true    , 1                       , 1                      };
if nargin == 2
    opt = struct();
end
opt = psom_struct_defaults(opt,list_fields,list_defaults);

%% read csv files
csv_master   = niak_read_csv_cell( file_master );
csv_slave = niak_read_csv_cell( file_slave );

% Loop over ID's and concatenate master with slave
csv_cell_combin = cell(size(csv_master,1),size(csv_slave,2)+size(csv_master,2));
n_shift = 0;
for n_cell_master = 2:size(csv_master(1:end,opt.combine_master_colomn),1)
    n_rep = 0;
    for n_cell_slave = 2:size(csv_slave(1:end,opt.combine_slave_colomn),1)
        subj_match = strfind(csv_master{n_cell_master,opt.combine_master_colomn},char(csv_slave{n_cell_slave,opt.combine_slave_colomn}));
        if ~isempty(subj_match)
           n_rep = n_rep + 1;
           if n_rep > 1 
              n_shift = n_shift + 1;
              csv_cell_combin(n_cell_master + n_shift,:) = [ csv_master(n_cell_master,:)  csv_slave(n_cell_slave,:) ];
           else
              csv_cell_combin(n_cell_master + n_shift,:) = [ csv_master(n_cell_master,:)  csv_slave(n_cell_slave,:) ];
           end
        end
    end
    if n_rep == 0
    csv_cell_combin(n_cell_master + n_shift ,:) = [ csv_master(n_cell_master,:) cell(size(csv_slave(n_cell_slave,:)))  ];
    end
end
csv_cell_combin(cellfun(@isempty,csv_cell_combin))='NaN';

% add tables headers
csv_cell_combin(1,:) = [ csv_master(1,:)  csv_slave(1,:) ];