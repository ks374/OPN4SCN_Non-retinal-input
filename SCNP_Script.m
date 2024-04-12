inpath = 'Z:\Chenghang\OPN4SCN\';
SCNP = SCN_processor(inpath);
SCNP = SCNP.get_all_neuropil_area();
%%
outpath_nonret = [inpath '20240227_Non_retinal_input_investigation\Experiment_1\Nonretinal\'];
outpath_ret = [inpath '20240227_Non_retinal_input_investigation\Experiment_1\Retinal\'];
SCNP.Projected_image_check(1,outpath_nonret);
SCNP.Projected_image_check(2,outpath_ret);
%%
outpath = 'Z:\Chenghang\OPN4SCN\20240227_Non_retinal_input_investigation\Experiment_2\';
SCNP.get_all_non_ret_den(outpath);
SCNP.get_all_VGLuT2_den(outpath);
%%
clc;
outfile = [inpath '20240227_Non_retinal_input_investigation\Experiment_2b2\Data.csv'];
SCNP.batch_experiment2b_2(1,2,outfile);
%%
clc;
outfile = [inpath '20240227_Non_retinal_input_investigation\Experiment_2b2\Data.csv'];
SCNP.experiment2b2_batch(10,1,2,outfile);
%%
clear;clc
%Experiment 2b4; 
inpath = 'Z:\Chenghang\OPN4SCN\';
SCNP = SCN_processor(inpath);
SCNP = SCNP.get_all_neuropil_area();
outfile = [inpath '20240227_Non_retinal_input_investigation\Experiment_2b4\Data_nonret.csv'];
SCNP.batch_experiment2b_2(0,1,outfile);
%
SCNP.experiment2b2_batch(10,0,1,outfile);
%
outfile = [inpath '20240227_Non_retinal_input_investigation\Experiment_2b4\Data_ret.csv'];
SCNP.experiment2b2_batch(10,1,2,outfile);
%%
%Exerperiment 2c1: VGluT2 quantification
clc;
inpath = 'Z:\Chenghang\OPN4SCN\';
SCNP = SCN_processor(inpath);
outpath = 'Z:\Chenghang\OPN4SCN\20240227_Non_retinal_input_investigation\Experiment_2c\';
outfile = [outpath 'Data_VGLuT2_Volume.csv'];
SCNP.batch_experiment_2c(2,outfile,'V');
outfile = [outpath 'Data_VGLuT2_SD.csv'];
SCNP.batch_experiment_2c(2,outfile,'S');
outfile = [outpath 'Data_Homer_Volume.csv'];
SCNP.batch_experiment_2c(0,outfile,'V');
outfile = [outpath 'Data_Homer_SD.csv'];
SCNP.batch_experiment_2c(0,outfile,'S');
outfile = [outpath 'Data_Bassoon_Volume.csv'];
SCNP.batch_experiment_2c(1,outfile,'V');
outfile = [outpath 'Data_Bassoon_SD.csv'];
SCNP.batch_experiment_2c(1,outfile,'S');