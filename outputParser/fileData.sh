FILES=/home/tony/Documents/Work/testInfo/output/*
outfile=outFileData.csv

rm $outfile

for file in $FILES
do
    more $file | perl processFileData.pl $outfile
done