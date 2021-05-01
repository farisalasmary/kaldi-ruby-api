require_relative 'config'

class SpeechEngine
    # this function is called in RSPEC to be stubbed
    def set_command(cmd)
        return cmd
    end
    
    def read_file(filename)
        return File.readlines(filename).each { |line| line.strip!}
    end
    
    def test_wrapper_rspec(asd)
        command = set_command('Hello World!!')
        
        return "the command value is '#{command}'"
    end
    
    def get_segments(ctm_file, segments_file)
        ctm_file_contents = read_file(ctm_file)
        segments = read_file(segments_file)

        segments_dict = {}
        segments.each do |line|
            segment_id, _, segment_start, segment_end = line.split(' ')
            segments_dict[segment_id] = {
                                            'segment_start' => segment_start.to_f,
                                            'segment_end' => segment_end.to_f
                                        }
        end

        # extract segments and their timing
        segmentations = []
        ctm_file_contents.each do |line|
            segment_id, _, word_start, duration, word = line.split(' ')
            segment_start = segments_dict[segment_id]['segment_start']
            start_time = segment_start.to_f + word_start.to_f # the word is measuered with respect
                                                              # to the segment start so, we have to add
                                                              # the word start to the segment start to get
                                                              # the start of the word from the beginning 
                                                              # of the audio file
            duration = duration.to_f
            end_time = start_time + duration
            if word == "I'M"
                word = "I'm"
            elsif word != 'I'
                word.downcase! # lower case in-place
            end

            segmentations += [
                                    {
                                        'start' => start_time, 
                                        'end' => end_time,
                                        'duration' => duration,
                                        'word' => word
                                    }
                             ]
        end
        return segmentations
    end 

    def wav_to_text(input_file, output_file)
        command = set_command("./my_decoder.sh #{input_file} #{output_file} 15")
        was_executed = system(command)
        
        lines = read_file(output_file)
        
        ctm_file = "#{output_file}.ctm"
        segments_file = "#{output_file}.segments"
        segmentations = get_segments(ctm_file, segments_file)
        
        return lines.join(' '), segmentations, was_executed
    end
    
    def allowed_extensions(filename)
        extension = filename.split('.')[-1]
        extension = extension.downcase
        is_valid = Config::ALLOWED_EXTENSIONS.include? extension
        return is_valid, extension
    end
    
    def convert_to_wav(input_file, output_file)
        is_valid, extension = allowed_extensions(input_file)
        was_executed = false
        if is_valid
            command = set_command("ffmpeg -y -i #{input_file} -acodec pcm_s16le -ac 1 -ar 16000 #{output_file} > /dev/null 2>&1")
            was_executed = system(command)
        end
        return is_valid, extension, was_executed
    end
    
    def convert_flv_to_mp4(input_file, output_file)
        is_valid, extension = allowed_extensions(input_file)
        was_executed = false
        if is_valid and extension == 'flv'
            command = set_command("ffmpeg -i #{input_file} -pass 1 -vcodec libx264 -preset slower -b 512k -bt 512k -threads 0 -s 640x360 -aspect 16:9 -acodec libmp3lame -ar 44100 -ab 32  -f flv -y #{output_file} > /dev/null 2>&1")
            was_executed = system(command)
        end
        return is_valid, extension, was_executed
    end
    
end

if __FILE__ == $0
    input_file = 'audio_upload/kaldi_english_test_CUT.wav'
    output_file = 'kaldi_english_test_CUT.txt'

    output_file = "#{Config::OUTPUTS_FOLDER}/#{output_file}"

    text = wav_to_text(input_file, output_file)
    
    ctm_file = "#{output_file}.ctm"
    segments_file = "#{output_file}.segments"
    segmentations = get_segments(ctm_file, segments_file)
end

