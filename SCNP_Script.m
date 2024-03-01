inpath = 'Z:\Chenghang\OPN4SCN\';
SCNP = SCN_processor(inpath);
%%
outpath_nonret = [inpath '20240227_Non_retinal_input_investigation\Experiment_1\Nonretinal\'];
outpath_ret = [inpath '20240227_Non_retinal_input_investigation\Experiment_1\Retinal\'];
SCNP.Projected_image_check(1,outpath_nonret);
SCNP.Projected_image_check(2,outpath_ret);
%%