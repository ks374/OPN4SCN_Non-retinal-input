classdef SCN_processor
    %For project non-retinal input in the SCN. 
    
    properties
        Base_folder char; %= 'Z:\Chenghang\OPN4SCN\';
        Experiment_folders cell;
        Experiment_name = {
            'P8_Het_A','P8_Het_B','P8_Het_C',...
            'P8_KO_A','P8_KO_B','P8_KO_C',...
            'P60_Het_A','P60_Het_B','P60_Het_C',...
            'P60_KO_A','P60_KO_B','P60_KO_C'
            }
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

        function Projected_image_check(obj,matname,outpath)
            %Render retinal and non-retinal in the first 10 slices 
            %Z-projected imagesfor all samples. 
            %matname 1 for non-retinal and 2 for retinal. 
            for i = 1:12
                disp(i);
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
                Image_G = Image_G(:,:,1:10);
                Image_R = Image_R(:,:,1:10);
                Image_G = max(Image_G,[],3);
                Image_R = max(Image_R,[],3);
                Image_B = zeros(size(Image_G,1),size(Image_G,2),size(Image_G,3),'uint8');
                Image_combine = cat(3,Image_R,Image_G,Image_B);
                imwrite(Image_combine,[outpath obj.Experiment_name{i} '.tif']);
            end
        end
    end
end

