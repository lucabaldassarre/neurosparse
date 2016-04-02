echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.9G,tmem=7.9G
#$ -l h_rt=120:00:00
#$ -S /bin/bash
#$ -N TVtest05
#$ -j y
#$ -cwd
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "test_p_05"