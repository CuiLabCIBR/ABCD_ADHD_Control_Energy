#!/bin/bash
#SBATCH -p q_fat_c,q_cn,q_fat
#SBATCH --ntasks=1 # Run a single serial task
#SBATCH --cpus-per-task=1
#SBATCH -e job.%j.log # Standard error
#SBATCH --job-name=EnergyCal

# Define the base directory paths for output and log files
BASE_DIR="/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy/scripts/Energy_Calculation/"
OUT_DIR="$BASE_DIR/out"
LOG_DIR="$BASE_DIR/log"

# Create the output and log directories if they don't exist
echo "Checking directories..."
for DIR in "$OUT_DIR" "$LOG_DIR"; do
  if [ ! -d "$DIR" ]; then
    echo "Creating directory: $DIR"
    mkdir -p "$DIR" || { echo "Error creating directory $DIR"; exit 1; }
  else
    echo "Directory exists: $DIR"
  fi
done

# Get the number of subjects from the CSV file (excluding header)
CSV_FILE="/ibmgpfs/cuizaixu_lab/yanghang/projects/abcd_adhd_control_energy/data/sub_info/sub_test_info.csv"
NUM_SUBJECTS=$(tail -n +2 "$CSV_FILE" | wc -l)

echo "Total number of subjects: $NUM_SUBJECTS"

for subj in $(seq 1 $NUM_SUBJECTS)
do
  OUT_PATH="$OUT_DIR/NullNetworks_${subj}.out"
  LOG_PATH="$LOG_DIR/NullNetworks_${subj}.log"
  sbatch -o "$OUT_PATH" -e "$LOG_PATH" "$BASE_DIR/NullNetworks.sh" "$subj"
done
