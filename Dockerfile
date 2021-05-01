FROM kaldiasr/kaldi:latest
COPY .  /opt/kaldi/egs/librispeech/s5
WORKDIR /opt/kaldi/egs/librispeech/s5
RUN mkdir /opt/kaldi/egs/librispeech/s5/tmp_output
RUN chmod 777 download_models.sh && chmod 777 run_api_server.sh
RUN /opt/kaldi/egs/librispeech/s5/download_models.sh
RUN apt update && apt install -y ruby-full ffmpeg && gem install zappa && gem install sinatra
ENTRYPOINT ["/bin/bash", "/opt/kaldi/egs/librispeech/s5/run_api_server.sh"]