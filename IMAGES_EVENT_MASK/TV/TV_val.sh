echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.8G,tmem=7.8G
#$ -l h_rt=96:00:00
#$ -S /bin/bash
#$ -N TVvalE
#$ -j y
#$ -cwd
#$ -t 1-210
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "TV_val $SGE_TASK_ID"