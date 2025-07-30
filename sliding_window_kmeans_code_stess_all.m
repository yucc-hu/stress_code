
% load('seed_time series.mat');
 load('stress6.mat');
  seed_ts=datanew_s;
  seed_name=roi_names;
  clear data roi_names
%  load('target_time series.mat.mat');
  load('stress20.mat');   
  tar_ts=datanew_s;
  clear data
%---------------------------------------------------------------------------
% set order parameter
total_time_series = 248; 
NAC_order = 1;
dCA_order = 4;


% set sliding window  parameter
window_length = 40;
movement_step= 1;

window_number= (total_time_series-window_length)/movement_step+1;

for n = 1:length(seed_ts)
    for i=1:window_number    
        initial_point = 1+(i-1)*movement_step;
        end_point = (i-1)*movement_step+window_length;
            for j = 1:20
                 corr_NAC{1,n}(i,j)=corr(seed_ts{1,n}(NAC_order,initial_point:end_point)',tar_ts{1,n}(j,initial_point:end_point)','type','pearson');
                 corr_dCA{1,n}(i,j)=corr(seed_ts{1,n}(dCA_order,initial_point:end_point)',tar_ts{1,n}(j,initial_point:end_point)','type','pearson');
            end
    end
end
% % computing for static fc as comparison
% for i=1:71
%     NAC_avg(i,:)=corr_NAC{1,i};
%     dCA_avg(i,:)=corr_dCA{1,i};
% end
% 
% NAC_avg_g=mean(NAC_avg);
% dCA_avg_g=mean(dCA_avg);
% -----------------------------------------------------------------------
% compute k-means 
% combine dCA NAC in subject level
% combine all subject data into one group
counter=1;

for i=1:length(corr_NAC)
    for j=1:window_number
        data(counter,:)=[corr_NAC{1,i}(j,:),corr_dCA{1,i}(j,:)];
      % data(counter,:)=[corr_NAC_l{1,i}(j,:),corr_dCA_l{1,i}(j,:),corr_NAC_r{1,i}(j,:),corr_dCA_r{1,i}(j,:)];
       counter=counter+1;
    end
end
% 
% idx_v1=kmeans(data,10,'Display','final','MaxIter',500,'Replicates',1000);


% -------------------------------------------------------------------------------------
%test for best parameter set 

cluster_number_set=3;
clust = zeros(size(data,1),cluster_number_set);

for i=1:cluster_number_set
clust(:,i) = kmeans(data,i,'Display','final','MaxIter',500,'Replicates',5000);
end
% test for cluster quality
eva1=evalclusters(data,clust,'CalinskiHarabasz');
eva2=evalclusters(data,clust,'silhouette');
% % plot cluster quality
% yyaxis right
% plot(eva1.CriterionValues)
% yyaxis left
% plot(eva2.CriterionValues)
% 
% plotyy([1:15],eva1.CriterionValues,[1:15],eva2.CriterionValues)

% get fc state according to their labels
cluster_number=2;
clt=clust(:,cluster_number)';
for i=1:cluster_number
    l{i}=find(clt(:)==i);
end

for i=1:cluster_number
final{i}= mean(data(l{i},:))';
end
% check if inte segre is reversed
    
%normalize
z_n = 1/2*log((1+data)./(1-data));


z_inte = z_n(l{1},:);
z_segre = z_n(l{2},:);
 
 inte_fc = data(l{1},:);
 segre_fc = data(l{2},:);
% inte_fc = data(l{2},:);
% segre_fc = data(l{1},:);
save('result.mat')
