#!/bin/bash
# use: ./decode.sh file.wav file.txt 15

# author: Faris Abdullah Alasmary  2020

START=$(date +%s)
. ./cmd.sh
. ./path.sh


FILE=`pwd`/$1
FILE2=`pwd`/$2

datadir="$RANDOM"

echo "The random name is:"
echo $datadir

if [ $3 -gt 5 ]; then
  len=$3 # length of each segment in seconds
else
  len=10 # default gives lowest WER
fi

overlap=$(((len+6-1)/6))

mfccdir=mfcc
nnet3_affix=_cleaned
affix=1d
tree_affix=
nj=1 # MUST BE 1


mkdir -p data/$datadir
echo "ar000000 sox "$FILE" -r 16000 -t wav -e signed-integer - remix - |" > data/$datadir/wav.scp
sox --i -D $FILE|awk -v L="$len" -v O="$overlap" '{R=L-O; n=int(($0-O)/R); n+=($0-O)/R>n?1:0; for(i=1;i<=n;i++) printf("ar%06d ar%06d\n",i,i);}' > data/$datadir/spk2utt
cp data/$datadir/spk2utt data/$datadir/utt2spk
cat data/$datadir/utt2spk|awk '{print $1" bla bla"}' > data/$datadir/text
cat data/$datadir/utt2spk|awk '{print $1" ar000000"}' > data/$datadir/tmp1
sox --i -D $FILE|awk  -v L="$len" -v O="$overlap" '{R=L-O; n=int(($0-O)/R); for(i=0;i<n;i++) print i*R" "(i+1)*R+O; if(($0-O)/R>i) print i*R" "$0}' > data/$datadir/tmp2
paste -d' ' data/$datadir/tmp1 data/$datadir/tmp2 > data/$datadir/segments


utils/copy_data_dir.sh data/$datadir data/${datadir}_hires

steps/make_mfcc.sh --nj $nj --mfcc-config conf/mfcc_hires.conf \
                   --cmd "$train_cmd" data/${datadir}_hires

steps/compute_cmvn_stats.sh data/${datadir}_hires
utils/fix_data_dir.sh data/${datadir}_hires

steps/online/nnet2/extract_ivectors_online.sh --cmd "$train_cmd" --nj $nj \
      data/${datadir}_hires exp/nnet3${nnet3_affix}/extractor \
      exp/nnet3${nnet3_affix}/ivectors_${datadir}_hires || exit 1;

dir=exp/chain${nnet3_affix}/tdnn${affix:+_$affix}_sp
graph_dir=$dir/graph_tgsmall

# decode options
frames_per_chunk=150
steps/nnet3/decode.sh \
      --acwt 1.0 --post-decode-acwt 10.0 \
      --extra-left-context 0 --extra-right-context 0 \
      --extra-left-context-initial 0 \
      --extra-right-context-final 0 \
      --frames-per-chunk $frames_per_chunk \
      --nj $nj --cmd "$decode_cmd"  --num-threads 10 \
      --online-ivector-dir exp/nnet3${nnet3_affix}/ivectors_${datadir}_hires \
      $graph_dir data/${datadir}_hires $dir/decode_${datadir} || exit 1;

echo 'Running get_ctm_fast.sh...'
steps/get_ctm_fast.sh --frame-shift 0.03 data/train data/lang_test_tgsmall ${dir}/decode_${datadir} ${dir}/decode_${datadir}/ctm-out
echo 'get_ctm_fast.sh completed!!'
utils/ctm/resolve_ctm_overlaps.py data/${datadir}/segments ${dir}/decode_${datadir}/ctm-out/ctm ${dir}/decode_${datadir}/ctm.resolved

cp data/${datadir}/segments $FILE2.segments
cp ${dir}/decode_${datadir}/ctm.resolved $FILE2.ctm
cat ${dir}/decode_${datadir}/ctm.resolved | awk '{if($1!=t && s!=""){print s; s="";}s=s" "$5; t=$1;}END{if(s!="")print s}'|cut -d' ' -f2- > ${dir}/decode_${datadir}/output
cp  ${dir}/decode_${datadir}/output $FILE2


rm -rf data/$datadir
rm -rf data/${datadir}_hires
rm -rf exp/nnet3${nnet3_affix}/ivectors_${datadir}_hires
rm -rf ${dir}/decode_${datadir}

END=$(date +%s)
DIFF=$(( $END - $START ))
echo $DIFF seconds
