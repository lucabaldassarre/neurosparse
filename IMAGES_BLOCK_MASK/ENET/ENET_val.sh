echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.8G,vf=7.8G
#$ -l h_rt=96:00:00
#$ -S /bin/bash
#$ -N ENETval
#$ -j y
#$ -cwd
#$ -t 1-2400
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "ENET_val $SGE_TASK_ID"