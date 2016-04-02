echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=1.9G,tmem=1.9G
#$ -l h_rt=24:00:00
#$ -S /bin/bash
#$ -N TVtest
#$ -j y
#$ -cwd
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "TV_time_test"