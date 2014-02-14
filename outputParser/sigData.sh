FILES=/home/tony/Documents/Work/testInfo/sigs/*.sigs

outfileClass=sigClassOut.csv
outFileMethod=sigMethOut.csv
outFileAttr=sigAttrOut.csv
outSHAs=outSHAs.csv

rm $outfileClass $outFileMethod $outFileAttr $outSHAs

for file in $FILES
do
    more $file | perl processSignatures.pl $outfileClass $outFileMethod $outFileAttr $outSHAs
done