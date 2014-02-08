FILES=/Users/antkohan/Desktop/testInfo/output/*
outfile=output.csv

rm $outfile

for file in $FILES
do
    more $file | perl processFileData.pl $outfile
done