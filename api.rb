
require 'sinatra'

require_relative 'engine_wrapper'
require_relative 'config'

get '/api/file_path/:filename' do
    content_type :json
    
    filename = params['filename']
    
    input_file = "#{Config::INPUTS_FOLDER}/#{filename}"
    output_file = "#{filename}.txt"
    
    speech_engine_wrapper = SpeechEngine.new
    
    puts "Converting to WAV..."
    converted_wav_input_file = input_file.split('.')[0] + ".wav"
    is_valid, extension, was_executed = speech_engine_wrapper.convert_to_wav(input_file, converted_wav_input_file)
    puts "CONVERSION IS DONE!!!"
    
    if not is_valid
        response = {
                      'status_code' => 400,
                      'message' => "The files of type \"#{extension}\" are not supported!"
                   }
    
        return response.to_json
    end
    
    output_file = "#{Config::OUTPUTS_FOLDER}/#{output_file}"
    
    ctm_file = "#{output_file}.ctm"
    segments_file = "#{output_file}.segments"

    puts "Transcribing..."
    text, segmentations, was_executed = speech_engine_wrapper.wav_to_text(converted_wav_input_file, output_file)
    puts "Transcription is DONE!!!"
    
    response = {
                    'status_code' => 200,
                    'data' => text,
                    'audio_file' => filename.split('.')[0] + ".wav",
                    'segments' => segmentations
               }
    
    if ['mp4', 'flv'].include? extension
        response['video_file'] = filename
        if extension == 'flv'
            converted_mp4_input_file = input_file.split('.')[0] + ".mp4"
            speech_engine_wrapper.convert_flv_to_mp4(input_file, output_file)
            response['video_file'] = filename.split('.')[0] + ".mp4" 
        end
    end
    
    return response.to_json
end