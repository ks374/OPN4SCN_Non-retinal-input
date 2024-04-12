classdef SCN_processor
    %For project non-retinal input in the SCN. 
    
    properties
        Base_folder char; %= 'Z:\Chenghang\OPN4SCN\';
        Experiment_folders cell;
        Experiment_name = {
            'P8_Het_A','P8_Het_B','P8_Het_C',...
            'P8_KO_A','P8_KO_B','P8_KO_C',...
            'P60_Het_A','P60_Het_B','P60_Het_C',...
            'P60_KO_A','P60_KO_B','P60_KO_C'}
        Write_name = {
            'He_P8_A','He_P8_B','He_P8_C',...
            'KO_P8_A','KO_P8_B','KO_P8_C',...
            'He_60_A','He_60_B','He_60_C',...
            'KO_60_A','KO_60_B','KO_60_C'}
        Neuropil_area double;
    end
    
    methods
        function obj = SCN_processor(Inpath)
            obj.Base_folder = Inpath;
            obj.Experiment_folders = {
            [obj.Base_folder '6202_P8_Het_A\'],...
            [obj.Base_folder '6241_P8_Het_B\'],[obj.Base_folder '6301_P8_Het_C\'],...
            [obj.Base_folder '6271_P8_KO_A\'],[obj.Base_folder '6281_P8_KO_B\'],...
            [obj.Base_folder '711_P8_KO_C\'],[obj.Base_folder '7181_P60_Het_A\'],...
            [obj.Base_folder '802_1_P60_Het_B\'],[obj.Base_folder '802_1_P60_Het_C\'],...
            [obj.Base_folder '8181_P60_KO_A\'],[obj.Base_folder '8261_P60_KO_B\'],...
            [obj.Base_folder '8262_P60_KO_C\']
            };
            obj.Neuropil_area = zeros(12,1);
        end

        function [Height,Width,num_images] = get_stack_info(obj,i)
            inpath = [obj.Experiment_folders{i} 'analysis\Result\1_soma\'];
            files = dir([inpath '*.tif']);
            infos = imfinfo([inpath files(1).name]);
            num_images = numel(files);
            Height = infos.Height;
            Width = infos.Width;
        end
        function image_stack = image_render(obj,i,stats)
            [Height,Width,num_images] = obj.get_stack_info(i);
            image_stack = zeros(Height,Width,num_images,'uint8');
            for k = 1:numel(stats)
                PixelList = stats(k).PixelList;
                PixelValues = stats(k).PixelValues;
                for j = 1:size(PixelList,1)
                    x = PixelList(j,2);
                    y = PixelList(j,1);
                    z = PixelList(j,3);
                    image_stack(x,y,z) = PixelValues(j);
                end
            end
        end
        function image_stack = get_neuropil_images(obj,i)
            [Height,Width,num_images] = obj.get_stack_info(i);
            exp_folder = obj.Experiment_folders{i};
            exp_folder = [exp_folder 'analysis\Result\1_soma\'];
            files = dir([exp_folder '*.tif']);
            image_stack = zeros(Height,Width,num_images);
            parfor j =1:numel(files)
                image_stack(:,:,j) = imread([files(j).folder '\' files(j).name]);
            end
        end
        function image_stack = get_BD_images(obj,i)
            [Height,Width,num_images] = obj.get_stack_info(i);
            exp_folder = obj.Experiment_folders{i};
            exp_folder = [exp_folder 'analysis\Result\0_BD\'];
            files = dir([exp_folder '*.tif']);
            image_stack = zeros(Height,Width,num_images);
            parfor j =1:numel(files)
                image_stack(:,:,j) = imread([files(j).folder '\' files(j).name]);
            end
        end
        function Volume = get_neuropil_area(obj,i)
            image_stack = obj.get_neuropil_images(i);
            Volume =numel(find(image_stack(:)));
            Volume = Volume * 0.0155*0.0155*0.07;
        end
        function obj = get_all_neuropil_area(obj)
            for i = 1:12
                obj.Neuropil_area(i) = obj.get_neuropil_area(i);
            end
        end
        function line = get_writing_list_parameters(obj,i,IsRet,IsBassoon,addition_string)
            Name = obj.Write_name{i};
            No_Sample = Name(1:5);
            Genotype = Name(1:2);
            Age = Name(4:5);
            Sample = Name(7);
            if IsRet == 1
                Source = 'Retina';
            elseif IsRet == 0
                Source = 'Nonret';
            end
            if IsBassoon == 0
                PType = 'Homer';
            elseif IsBassoon == 1
                PType = 'Bassoon';
            elseif IsBassoon == 2
                PType = 'VGluT2';
            end
            line = [string(Name),string(No_Sample),string(Genotype),...
                string(Age),string(Sample),string(Source),string(PType)];
            if nargin > 4
                line = cat(2,line,addition_string);
            end
        end
        function line = get_writing_list_headline(obj,append_colume_name)
            Headline = ["Name","No_Sample","Genotype",...
                    "Age","Sample","Source","ProteinType"];
            if nargin > 1
                line = cat(2,Headline,append_colume_name);
            end
        end

%Experiment 2a--------------------------------------------------------------
        function Projected_image_check(obj,matname,outpath)
            %Render retinal and non-retinal in the first 10 slices 
            %Z-projected imagesfor all samples. 
            %matname 1 for non-retinal and 2 for retinal. 
            for i = 1:12
                disp(i);
                [~,~,num_images] = obj.get_stack_info(i);
                target_path = [obj.Experiment_folders{i} 'analysis\Result\'];
                Gfile = [target_path '5_V_Syn\G_paired_3.mat'];
                Rfile = [target_path '5_V_Syn\R_paired_3.mat'];
                load(Gfile,"statsGwater_ssss","statsGwater_sssn");
                load(Rfile,"statsRwater_ssss","statsRwater_sssn");
                if matname == 1
                    statsG = statsGwater_sssn;
                    statsR = statsRwater_sssn;
                elseif matname == 2
                    statsG = statsGwater_ssss;
                    statsR = statsRwater_ssss;
                end
                Image_G = obj.image_render(i,statsG);
                Image_R = obj.image_render(i,statsR);
                Image_G = Image_G(:,:,1:num_images);
                Image_R = Image_R(:,:,1:num_images);
                Image_G = max(Image_G,[],3);
                Image_R = max(Image_R,[],3);
                Image_B = zeros(size(Image_G,1),size(Image_G,2),size(Image_G,3),'uint8');
                Image_combine = cat(3,Image_R,Image_G,Image_B);
                imwrite(Image_combine,[outpath obj.Experiment_name{i} '.tif']);
            end
        end
        function den = get_nonret_density(obj,i,IsBassoon)
            %IsBassoon or Homer123
            stats = obj.get_stats(o,0,IsBassoon);
            Total_volume = obj.Neuropil_area(i);
            den = numel(stats) / Total_volume;
        end
        function den = get_ret_density(obj,i,IsBassoon)
            %IsBassoon or Homer123
            stats = obj.get_stats(i,1,IsBassoon);
            Total_volume = obj.get_neuropil_area(i);
            den = numel(stats) / Total_volume;
        end
        function get_all_non_ret_den(obj,outpath)
            Headline = ["Name","Type","Channel","Density"];
            writematrix(Headline,[outpath 'data.csv'],"WriteMode","append");
            for i = 1:12
                den_B = obj.get_nonret_density(i,1);
                den_H = obj.get_nonret_density(i,0);
                name = obj.Experiment_name{i};
                line_temp = [string(name) "Nonret" "Bassoon" string(num2str(den_B))];
                writematrix(line_temp,[outpath 'data.csv'],"WriteMode","append");
                line_temp = [name "Nonret" "Homer" num2str(den_H)];
                writematrix(line_temp,[outpath 'data.csv'],"WriteMode","append");

                den_B = obj.get_ret_density(i,1);
                den_H = obj.get_ret_density(i,0);
                name = obj.Experiment_name{i};
                line_temp = [string(name) "Ret" "Bassoon" string(num2str(den_B))];
                writematrix(line_temp,[outpath 'data.csv'],"WriteMode","append");
                line_temp = [string(name) "Ret" "Homer" string(num2str(den_H))];
                writematrix(line_temp,[outpath 'data.csv'],"WriteMode","append");
            end
        end
        function get_all_VGLuT2_den(obj,outpath)
            Headline = ["Name","Type","Channel","Density"];
            writematrix(Headline,[outpath 'data_Vglut2.csv'],"WriteMode","append");
            for i = 1:12
                den_V = obj.get_ret_density(i,2);
                name = obj.Experiment_name{i};
                line_temp = [string(name) "Ret" "VGluT2" string(num2str(den_V))];
                writematrix(line_temp,[outpath 'data_Vglut2.csv'],"WriteMode","append");
            end
        end
%Experiment 2b2-----------------------------------------------------------
function center_point = find_center(obj,i)
    Image_stack = obj.get_BD_images(i);
    [y,x,z] = ind2sub(size(Image_stack),find(Image_stack));
    center_point = mean([x,y,z]);
end
function stats = get_stats(obj,i,Is_ret,IsBassoon)
    if Is_ret == 0
        target_path = [obj.Experiment_folders{i} 'analysis\Result\5_V_Syn\'];
        if IsBassoon == 1
            mat_file = [target_path 'G_paired_3.mat'];
            load(mat_file,"statsGwater_sssn");
            stats = statsGwater_sssn; 
        elseif IsBassoon == 0
            mat_file = [target_path 'R_paired_3.mat'];
            load(mat_file,"statsRwater_sssn");
            stats = statsRwater_sssn; 
        end
    elseif Is_ret == 1
        target_path = [obj.Experiment_folders{i} 'analysis\Result\5_V_Syn\'];
        if IsBassoon == 1
            mat_file = [target_path 'G_paired_3.mat'];
            load(mat_file,"statsGwater_ssss");
            stats = statsGwater_ssss; 
        elseif IsBassoon == 0
            mat_file = [target_path 'R_paired_3.mat'];
            load(mat_file,"statsRwater_ssss");
            stats = statsRwater_ssss; 
        elseif IsBassoon == 2
            target_path = [obj.Experiment_folders{i} 'analysis\Result\3_Vglut2\'];
            mat_file = [target_path 'V_paired.mat'];
            load(mat_file,"statsVwater_ss");
            stats = statsVwater_ss; 
        end
    end
end
function WC_list = get_WeightedCentroids(obj,i,Is_ret,IsBassoon)
    stats = obj.get_stats(i,Is_ret,IsBassoon);
    WC_list = [];
    for j = 1:numel(stats)
        WC_list = cat(1,WC_list,stats(j).WeightedCentroid);
    end
end
function Vector = vector_calc(~,point,points)
    Dist_matrix = points-point;
    Vector = sum(Dist_matrix);
end
function Vector = get_Vector_from_stats(obj,i,center_point,Is_ret,IsBassoon)
    %center_point = [x,y,z];
    WC_list = obj.get_WeightedCentroids(i,Is_ret,IsBassoon);
    Vector = obj.vector_calc(center_point,WC_list);
    Vector = Vector./size(WC_list,1);
end
function vector = vector_normalize(~,vector_in,voxel)
    if size(vector_in,2) == 3
        vector = vector_in.*voxel;
    else
        vector = vector_in(:,1:2).*voxel(1:2);
    end
end
function values = get_vectors_length(~,vectors)
    if size(vectors,2) == 3
        vectors = vectors(:,1:2);
    end
    values = zeros(size(vectors,1),1);
    for i = 1:size(vectors,1)
        values(i) = sqrt(vectors(i,:) * vectors(i,:)');
    end
end
    
function batch_experiment2b_2(obj,Is_ret,IsBassoon,outfile)
    line = obj.get_writing_list_headline(["DataType","x","y","length"]);
    writematrix(line,outfile);
    for i = 1:12
        center_point = obj.find_center(i);
        vector = obj.get_Vector_from_stats(i,center_point,Is_ret,IsBassoon);
        vector = obj.vector_normalize(vector,[0.0155,0.0155,0.07]);
        line = obj.get_writing_list_parameters(i,Is_ret,IsBassoon,"Orig");
        line = cat(2,line,string(vector(1)));
        line = cat(2,line,string(vector(2)));
        line = cat(2,line,string(obj.get_vectors_length(vector)));
        writematrix(line,outfile,'WriteMode','append');
    end
end
%Experiment 2b2 ---------------------Rand data generation
function WC_list = WC_generate_from_image_stack(~,image_stack,num_stats)
    [y,x,z] = ind2sub(size(image_stack),find(image_stack));
    WC_list = datasample([x,y,z],num_stats,'Replace',false);
end
function WC_list = generate_randomization_once(obj,i,Is_ret,IsBassoon)
    stats = obj.get_stats(i,Is_ret,IsBassoon);
    num_stats = numel(stats);
    image_stack = obj.get_neuropil_images(i);
    WC_list = obj.WC_generate_from_image_stack(image_stack,num_stats);
end
function experiment2b2_batch(obj,resample_size,Is_ret,IsBassoon,outfile)
    %line = obj.get_writing_list_headline(["DataType","x","y","length"]);
    %Note: X and Y here represents vector pointing to canvas right and up,
    %while FIJI points to right and down. 
    %writematrix(line,outfile);
    for i =1:12
        center_point = obj.find_center(i);
        for j = 1:resample_size   
            WC_list = obj.generate_randomization_once(i,Is_ret,IsBassoon);
            Vector = obj.vector_calc(center_point,WC_list);
            Vector = Vector./size(WC_list,1);
            Vector = obj.vector_normalize(Vector,[0.0155,0.0155,0.07]);
            line = obj.get_writing_list_parameters(i,Is_ret,IsBassoon,"Rand");
            line = cat(2,line,string(Vector(1)));
            line = cat(2,line,string(Vector(2)));
            line = cat(2,line,string(obj.get_vectors_length(Vector)));
            writematrix(line,outfile,'WriteMode','append');
        end
    end
end
    end
end

