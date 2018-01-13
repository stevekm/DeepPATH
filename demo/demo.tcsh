#!/bin/tcsh
#$ -pe openmpi 32
#$ -A TensorFlow
#$ -N rqsub_tile
#$ -cwd
#$ -S /bin/tcsh
#$ -q gpu0.q
#$ -l excl=true

setenv PYTHON_BIN python3.5
setenv CODE_DIR ../DeepPATH_code
setenv SVS_PATH Raw/TCGA-05-4249-01A-01-TS1.912c8d26-dc9f-4bae-bfcd-559cf234c921.svs
setenv OUTPUT_PATH output
# setenv CHECKPOINT_PATH /ifs/data/abl/deepomics/tsirigoslab/web_interface/example_data/Trained_NW/Lung/20x_3classes/
setenv CHECKPOINT_PATH checkpoint/20x_3classes

# step 0.1 - tile the svs slide images
# create temp directory to store the tiles
mkdir -p $OUTPUT_PATH/tmp_tiles
setenv Tiles_PATH $OUTPUT_PATH/tmp_tiles

# python /ifs/home/coudrn01/NN/github/DeepPATH_code/00_preprocessing/0b_tileLoop_deepzoom2.py  -s 512 e 0 -j 32 -B 25 -o `echo $Tiles_PATH` `echo $SVS_PATH`
$PYTHON_BIN $CODE_DIR/00_preprocessing/0b_tileLoop_deepzoom2.py  -s 512 -e 0 -j 32 -B 50 -o  $Tiles_PATH $SVS_PATH


# step 0.2 - sort/select jpg tiles (using option 10 and 100 for PercentTest option)
# create directory, then cd to it (script needs to be run from it)
mkdir -p $OUTPUT_PATH/jpg_selection
setenv jpg_PATH $OUTPUT_PATH/jpg_selection
cd $OUTPUT_PATH/jpg_selection

#python /ifs/home/coudrn01/NN/github/DeepPATH_code/00_preprocessing/0d_SortTiles.py --SourceFolder=`echo $Tiles_PATH` --Magnification=20  --MagDiffAllowed=1 --SortingOption=10 --PercentTest=100 --PercentValid=0 --PatientID=12 --nSplit 0
$PYTHON_BIN $CODE_DIR/00_preprocessing/0d_SortTiles.py --SourceFolder=$Tiles_PATH --Magnification=20  --MagDiffAllowed=1 --SortingOption=10 --PercentTest=100 --PercentValid=0 --PatientID=12 --nSplit 0


# step 0.3 - convert to TFRecord (only the second part for the test set, not for the training)
# create output directory, then run this script:
mkdir -p $OUTPUT_PATH/TFRecord
setenv TFRecord_PATH $OUTPUT_PATH/TFRecord

module load cuda/8.0
module load python/3.5.3

# python  /ifs/home/coudrn01/NN/github/DeepPATH_code/00_preprocessing/TFRecord_2or3_Classes/build_TF_test.py --directory=`echo $jpg_PATH`  --output_directory=`echo $TFRecord_PATH` --num_threads=1 --one_FT_per_Tile=False --ImageSet_basename='test'
$PYTHON_BIN  $CODE_DIR/00_preprocessing/TFRecord_2or3_Classes/build_TF_test.py --directory=$jpg_PATH  --output_directory=$TFRecord_PATH --num_threads=1 --one_FT_per_Tile=False --ImageSet_basename='test'

# step 2.0 - run the classification
mkdir -p $OUTPUT_PATH/Results
setenv Results_PATH $OUTPUT_PATH/Results

# python /ifs/home/coudrn01/NN/github/DeepPATH_code/02_testing/xClasses/nc_imagenet_eval.py --checkpoint_dir=`echo $CHECKPOINT_PATH` --eval_dir=`echo $Results_PATH` --data_dir=`echo $TFRecord_PATH`  --batch_size 30 --ImageSet_basename='test_' --run_once --ClassNumber 3 --mode='0_softmax'
$PYTHON_BIN $CODE_DIR/02_testing/xClasses/nc_imagenet_eval.py --checkpoint_dir=$CHECKPOINT_PATH --eval_dir=$Results_PATH --data_dir=$TFRecord_PATH  --batch_size 30 --ImageSet_basename='test_' --run_once --ClassNumber 3 --mode='0_softmax'


# step 3.0 - run the heatmap code only (0f_HeatMap_nClasses.py )
setenv stat_file $Results_PATH/out_filename_Stats.txt

# python /ifs/home/coudrn01/NN/github/DeepPATH_code/03_postprocessing/0f_HeatMap_nClasses.py  --image_file `echo $jpg_PATH` --tiles_overlap 0 --output_dir `echo $Results_PATH` --tiles_stats `echo $stat_file` --resample_factor 10 --slide_filter '' --filter_tile '' --Cmap 'CancerType' --tiles_size 512
$PYTHON_BIN $CODE_DIR/03_postprocessing/0f_HeatMap_nClasses.py  --image_file $jpg_PATH --tiles_overlap 0 --output_dir $Results_PATH --tiles_stats $stat_file --resample_factor 10 --slide_filter '' --filter_tile '' --Cmap 'CancerType' --tiles_size 512
