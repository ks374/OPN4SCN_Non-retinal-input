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
vectors = SCNP.batch_experiment2b_1(1,2);
values = SCNP.get_vectors_length(vectors);
disp(values);
%%
clc;
outfile = [inpath '20240227_Non_retinal_input_investigation\Experiment_2b2\Rand.csv'];
SCNP.experiment2b2_batch(10,1,2,outfile);