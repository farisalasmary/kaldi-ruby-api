#!/bin/bash

echo "Current path: $PWD"
if [ ! -f 0013_librispeech_v1_chain.tar.gz ]; then
    echo "Downloading 0013_librispeech_v1_lm.tar.gz"
    wget http://kaldi-asr.org/models/13/0013_librispeech_v1_chain.tar.gz
fi


if [ ! -f 0013_librispeech_v1_extractor.tar.gz ]; then
    echo "Downloading 0013_librispeech_v1_extractor.tar.gz"
    wget http://kaldi-asr.org/models/13/0013_librispeech_v1_extractor.tar.gz
fi


if [ ! -f 0013_librispeech_v1_lm.tar.gz ]; then
    echo "Downloading 0013_librispeech_v1_lm.tar.gz"
    wget http://kaldi-asr.org/models/13/0013_librispeech_v1_lm.tar.gz
fi

tar -xvzf 0013_librispeech_v1_chain.tar.gz
tar -xvzf 0013_librispeech_v1_extractor.tar.gz
tar -xvzf 0013_librispeech_v1_lm.tar.gz
export dir=exp/chain_cleaned/tdnn_1d_sp && \
export graph_dir=$dir/graph_tgsmall && \
utils/mkgraph.sh --self-loop-scale 1.0 --remove-oov data/lang_test_tgsmall $dir $graph_dir &&  \
echo 'export train_cmd="run.pl --mem 2G"' > cmd.sh && \
echo 'export decode_cmd="run.pl --mem 4G"' >> cmd.sh && \
echo 'export mkgraph_cmd="run.pl --mem 8G"' >> cmd.sh

echo 'Models were successfully installed!!'