# kaldi-ruby-api
An example of using this repo is available in [English ASR website repo](https://github.com/farisalasmary/asr_website/).

## How to Use?
This repo is prepared to work on Docker with a pretrained Kaldi model on Librispeech dataset. You can modify the `Dockerfile` as well as the `my_decoder.sh` file to fit your model.
First of all, you need to clone this project:
```bash
mkdir test_asr && cd test_asr
git clone https://github.com/farisalasmary/kaldi-ruby-api.git
```
Then, you need to build an image using the `Dockerfile` available in the repo.

```bash
cd kaldi-ruby-api && docker build -t kaldi_eng_asr . && cd .. &&
```

After that, you run a container and mount a folder, e.g., `files_for_transcription` in the host on the folder `/opt/kaldi/egs/librispeech/s5/audio_upload` inside the container:
```bash
docker run -ti -v `pwd`/files_for_transcription:/opt/kaldi/egs/librispeech/s5/audio_upload -p 9999:9999 --name kaldi_ruby_api kaldi_eng_asr:latest
```

Finally, put the file that you want to transcribe inside the folder `files_for_transcription` (or whatever you named it) and send an HTTP GET request to the API with the name of the file that you put it inside the folder:
```bash
curl http://localhost:9999/api/file_path/YOUR_FILE_NAME.EXTENSION
```
For example, we take the file `SVD_Eigenfaces_CUT.mp4` from the `testing_data` folder and put it inside the folder `files_for_transcription` then send the following request:
```bash
curl http://localhost:9999/api/file_path/SVD_Eigenfaces_CUT.mp4
```
The result will be in JSON format.

**NOTE**: supported extensions are available in `config.rb` file. Currently, there is the following extensions:
```ruby
ALLOWED_EXTENSIONS = ['wav', 'mp3', 'ogg', 'mp4', 'flv']
```
