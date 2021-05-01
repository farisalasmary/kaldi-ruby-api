require 'rspec'

@root_folder = '/volume/rails'

$LOAD_PATH << "#{@root_folder}/ruby_api"
require 'engine_wrapper'
#require 'engine_wrapper'

RSpec.describe SpeechEngine do
    before do
        @root_folder = '/volume/rails'
    end
        
    describe 'wav_to_text' do
        it 'should return correct segmentations and transcription of the executed bash script' do
            # allow(subject).to receive(:allowed_extensions).and_return([true, 'mp3']) # stubbing
            input_file = "#{@root_folder}/ruby_api/testing_data/kaldi_english_test_CUT_TESTING.wav"
            output_file = "#{@root_folder}/ruby_api/testing_data/kaldi_english_test_CUT_TESTING.txt"
            
            allow(subject).to receive(:system).and_return(true) # stubbing
            text, segmentations, was_executed = subject.wav_to_text(input_file, output_file)
            
            expected_segmentations = [
                    {"start"=>0.06, "end"=>0.21, "duration"=>0.15, "word"=>"there's"},
                    {"start"=>0.21, "end"=>0.32999999999999996, "duration"=>0.12, "word"=>"no"},
                    {"start"=>0.33, "end"=>0.72, "duration"=>0.39, "word"=>"reporting"},
                    {"start"=>0.72, "end"=>0.78, "duration"=>0.06, "word"=>"the"},
                    {"start"=>0.78, "end"=>1.05, "duration"=>0.27, "word"=>"wash"},
                    {"start"=>1.05, "end"=>1.1400000000000001, "duration"=>0.09, "word"=>"and"},
                    {"start"=>1.14, "end"=>1.6199999999999999, "duration"=>0.48, "word"=>"imposed"},
                    {"start"=>1.62, "end"=>1.7100000000000002, "duration"=>0.09, "word"=>"the"},
                    {"start"=>1.71, "end"=>2.2199999999999998, "duration"=>0.51, "word"=>"headline"},
                    {"start"=>2.22, "end"=>2.6700000000000004, "duration"=>0.45, "word"=>"whitehouse"},
                    {"start"=>2.67, "end"=>2.85, "duration"=>0.18, "word"=>"was"},
                    {"start"=>2.85, "end"=>3.12, "duration"=>0.27, "word"=>"worn"},
                    {"start"=>3.12, "end"=>3.72, "duration"=>0.6, "word"=>"giuliano"},
                    {"start"=>3.72, "end"=>3.87, "duration"=>0.15, "word"=>"was"},
                    {"start"=>3.87, "end"=>4.23, "duration"=>0.36, "word"=>"target"},
                    {"start"=>4.23, "end"=>4.29, "duration"=>0.06, "word"=>"of"},
                    {"start"=>4.29, "end"=>4.62, "duration"=>0.33, "word"=>"russian"},
                    {"start"=>4.62, "end"=>4.71, "duration"=>0.09, "word"=>"and"},
                    {"start"=>4.71, "end"=>4.95, "duration"=>0.24, "word"=>"told"}
                ]
            
            expected_text = "THERE'S NO REPORTING THE WASH AND IMPOSED THE HEADLINE WHITEHOUSE WAS WORN GIULIANO WAS TARGET OF RUSSIAN AND TOLD"
            
            expect(text).to eq expected_text
            expect(segmentations).to eq expected_segmentations
            expect(was_executed).to be true 
        end
    end
    describe 'allowed_extensions' do
        it 'should return is_valid = false and the extension of the provided file in lower case' do
            is_valid, extension = subject.allowed_extensions("filename.JPG")
            expect(is_valid).to be false
            expect(extension).to eq 'jpg'
        end
        
        it 'should return is_valid = false and the extension "wav"' do
            is_valid, extension = subject.allowed_extensions("filename.wav")
            expect(is_valid).to be true
            expect(extension).to eq 'wav'
        end
        
        it 'should return is_valid = true and the extension "wav"' do
            is_valid, extension = subject.allowed_extensions("filename.wav")
            expect(is_valid).to be true
            expect(extension).to eq 'wav'
        end
        
        it 'should return is_valid = true and the extension "ogg"' do
            is_valid, extension = subject.allowed_extensions("filename.OGG")
            expect(is_valid).to be true
            expect(extension).to eq 'ogg'
        end 
        
        it 'should return is_valid = true and the extension "mp3"' do
            is_valid, extension = subject.allowed_extensions("filename.mp3")
            expect(is_valid).to be true
            expect(extension).to eq 'mp3'
        end
                
        it 'should return is_valid = true and the extension "mp4"' do
            is_valid, extension = subject.allowed_extensions("filename.mp4")
            expect(is_valid).to be true
            expect(extension).to eq 'mp4'
        end
                
        it 'should return is_valid = true and the extension "flv"' do
            is_valid, extension = subject.allowed_extensions("filename.flv")
            expect(is_valid).to be true
            expect(extension).to eq 'flv'
        end
    end
    
    
    describe 'convert_flv_to_mp4' do
        it 'should return was_executed = true if the system executes the ffmpeg command with no errors' do
            # allow(subject).to receive(:set_command).and_return("Stubbing worked!!!!")
            allow(subject).to receive(:allowed_extensions).and_return([true, 'flv']) # stubbing
            #allow(subject).to receive(:system).and_return(true) # stubbing
            input_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.flv"
            output_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.mp4"
            
            is_valid, extension, was_executed = subject.convert_flv_to_mp4(input_file, output_file)
            
            expect(is_valid).to be true
            expect(extension).to eq('flv')
            expect(was_executed).to be true 
        end
        
        it 'should return was_executed = false if the system is NOT provided with a FLV file' do
            # allow(subject).to receive(:set_command).and_return("Stubbing worked!!!!")
            allow(subject).to receive(:allowed_extensions).and_return([true, 'mp4']) # stubbing
            #allow(subject).to receive(:system).and_return(true) # stubbing
            input_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.flv"
            output_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.mp4"
            
            is_valid, extension, was_executed = subject.convert_flv_to_mp4(input_file, output_file)
            
            expect(was_executed).to be false
        end
    end
    
    describe 'convert_to_wav' do
        it 'should return was_executed = true if the system executes the ffmpeg command with no errors while converting mp3 to wav' do
            # allow(subject).to receive(:set_command).and_return("Stubbing worked!!!!")
            allow(subject).to receive(:allowed_extensions).and_return([true, 'mp3']) # stubbing
            input_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.mp3"
            output_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.wav"
            
            is_valid, extension, was_executed = subject.convert_to_wav(input_file, output_file)
            
            expect(is_valid).to be true
            expect(extension).to eq('mp3')
            expect(was_executed).to be true 
        end
        
        it 'should return was_executed = true if the system executes the ffmpeg command with no errors while converting mp4 to wav' do
            # allow(subject).to receive(:set_command).and_return("Stubbing worked!!!!")
            allow(subject).to receive(:allowed_extensions).and_return([true, 'mp4']) # stubbing
            input_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.mp4"
            output_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.wav"
            
            is_valid, extension, was_executed = subject.convert_to_wav(input_file, output_file)
            
            expect(is_valid).to be true
            expect(extension).to eq('mp4')
            expect(was_executed).to be true
            
        end
        
        it 'should return was_executed = true if the system executes the ffmpeg command with no errors while converting flv to wav' do
            # allow(subject).to receive(:set_command).and_return("Stubbing worked!!!!")
            allow(subject).to receive(:allowed_extensions).and_return([true, 'flv']) # stubbing
            input_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.flv"
            output_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.wav"
            
            is_valid, extension, was_executed = subject.convert_to_wav(input_file, output_file)
            
            expect(is_valid).to be true
            expect(extension).to eq('flv')
            expect(was_executed).to be true
        end

        it 'should return was_executed = true if the system executes the ffmpeg command with no errors while converting ogg to wav' do
            # allow(subject).to receive(:set_command).and_return("Stubbing worked!!!!")
            allow(subject).to receive(:allowed_extensions).and_return([true, 'ogg']) # stubbing
            input_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.ogg"
            output_file = "#{@root_folder}/ruby_api/testing_data/SVD_Eigenfaces_CUT.wav"
            
            is_valid, extension, was_executed = subject.convert_to_wav(input_file, output_file)
            
            expect(is_valid).to be true
            expect(extension).to eq('ogg')
            expect(was_executed).to be true
        end
    end
    

end
