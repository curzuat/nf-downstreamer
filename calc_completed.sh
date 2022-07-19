ls -l downstreamer_output/step1/ | cut -f2 -d: | cut -f2 -d" " | tail -n+2 > step1_completed.txt
ls -l downstreamer_output/summary_statistics/binary_matrix/ | cut -f2 -d: | cut -f2 -d" " | tail -n+2 > converttxt_completed.txt
comm -23 converttxt_completed.txt step1_completed.txt > pending_step1.txt