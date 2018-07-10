#!/bin/sh

#BSUB -J jgfs_pgrb2_spec_gempak_00
#BSUB -o /gpfs/dell2/ptmp/Boi.Vuong/output/gfs_pgrb2_spec_gempak_00.o%J
#BSUB -e /gpfs/dell2/ptmp/Boi.Vuong/output/gfs_pgrb2_spec_gempak_00.o%J
#BSUB -q debug
#BSUB -n 2                      # number of tasks
#BSUB -R span[ptile=2]          # 2 task per node
#BSUB -cwd /gpfs/dell2/ptmp/Boi.Vuong/output
#BSUB -W 00:30
#BSUB -P GFS-T2O
#BSUB -R affinity[core(1):distribute=balance]

export KMP_AFFINITY=disabled

export PDY=`date -u +%Y%m%d`
export PDY=20180710

export PDY1=`expr $PDY - 1`

# export cyc=06
export cyc=00
export cycle=t${cyc}z

set -xa
export PS4='$SECONDS + '
date

####################################
##  Load the GRIB Utilities module
#####################################

module load EnvVars/1.0.2
module load ips/18.0.1.163
module load CFP/2.0.1
module load impi/18.0.1
module load lsf/10.1
module load prod_util/1.1.0
module load grib_util/1.0.6
module load prod_envir/1.0.2
#
#  This is a test GEMPAK version 7.3.0 on DELL
#
module use  /gpfs/dell2/emc/modeling/noscrub/Boi.Vuong/modulefiles

###########################################
# Now set up GEMPAK/NTRANS environment
###########################################
module load gempak/7.3.0

module list

############################################
# GFS_PGRB2_SPEC_GEMPAK PRODUCT GENERATION
############################################

export LAUNCH_MODE=MPI

###############################################
# Set MP variables
###############################################
export OMP_NUM_THREADS=1
export MP_LABELIO=yes
export MP_PULSE=0
export MP_DEBUG_NOTIMEOUT=yes

##############################################
# Define COM, PCOM, COMIN  directories
##############################################

# set envir=prod or para to test with data in prod or para
 export envir=para
# export envir=prod

export SENDCOM=YES
export KEEPDATA=YES
export job=gfs_pgrb2_spec_gempak_${cyc}
export pid=${pid:-$$}
export jobid=${job}.${pid}

# Set FAKE DBNET for testing
export SENDDBN=YES
export DBNROOT=/gpfs/hps/nco/ops/nwprod/prod_util.v1.0.24/fakedbn

export DATAROOT=/gpfs/dell2/ptmp/Boi.Vuong/output
export NWROOT=/gpfs/dell2/emc/modeling/noscrub/Boi.Vuong/git
export COMROOT2=/gpfs/dell2/ptmp/Boi.Vuong/com

mkdir -m 775 -p ${COMROOT2} ${COMROOT2}/logs ${COMROOT2}/logs/jlogfiles 
export jlogfile=${COMROOT2}/logs/jlogfiles/jlogfile.${jobid}

#############################################################
# Specify versions
#############################################################
export gfs_ver=v15.0.0

##########################################################
# obtain unique process id (pid) and make temp directory
#########################################################
export DATA=${DATA:-${DATAROOT}/${jobid}}
mkdir -p $DATA
cd $DATA

################################
# Set up the HOME directory
################################
export HOMEgfs=${HOMEgfs:-${NWROOT}/gfs.${gfs_ver}}
export EXECgfs=${EXECgfs:-$HOMEgfs/exec}
export PARMgfs=${PARMgfs:-$HOMEgfs/parm}
export FIXgfs=${FIXgfs:-$HOMEgfs/gempak/fix}
export USHgfs=${USHgfs:-$HOMEgfs/gempak/ush}
export SRCgfs=${SRCgfs:-$HOMEgfs/scripts}

###################################
# Specify NET and RUN Name and model
####################################
export NET=gfs

##############################################
# Define COM directories
##############################################
if [ $envir = "prod" ] ; then
#  This setting is for testing with GFS (production)
  export COMIN=/gpfs/hps/nco/ops/com/gfs/prod/gfs.${PDY}         ### NCO PROD
else
#  export COMIN=/gpfs/dell2/ptmp/emc.glopara/ROTDIRS/prfv3rt1/${NET}.${PDY}/${cyc} ### EMC PARA Realtime
#  export COMIN=/gpfs/hps3/ptmp/emc.glopara/ROTDIRS/prfv3rt1/${NET}.${PDY}/${cyc} ### EMC PARA Realtimea on CRAY
  export COMIN=/gpfs/dell2/emc/modeling/noscrub/Boi.Vuong/git/${NET}.${PDY}/${cyc} ### Boi PARA
fi

export COMOUT=${COMROOT2}/${NET}/${envir}/${NET}.${PDY}/${cyc}/nawips

if [ $SENDCOM = YES ] ; then
  mkdir -m 775 -p $COMOUT
fi

#################################################################
# Execute the script for the regular grib
#################################################################
export DATA_HOLD=$DATA
export DATA=$DATA_HOLD/SPECIAL
mkdir -p $DATA
cd $DATA

#############################################
# run the GFS job
#############################################
sh $HOMEgfs/jobs/JGFS_PGRB2_SPEC_GEMPAK
