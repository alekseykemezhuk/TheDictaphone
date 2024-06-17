import UIKit
import AVFoundation

class Manager {
    
    static let shared = Manager()
    
    private init() {}
    
    //MARK: - Properties
    
    var recordSession: AVAudioSession!

    //MARK: - flow methods
    
    func getRecorderProperties() -> (URL, [String : Int]) {
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        let recordingName = getDirectoryUrl().appendingPathComponent("Recording_\(format.string(from: Date())).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        return (recordingName, settings)
    }
    
    func getDirectoryUrl() -> URL {
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func microphonePermission() {
        
        recordSession = AVAudioSession.sharedInstance()
        
        do {
            try recordSession.setCategory(.playAndRecord, mode: .default)
            try recordSession.setActive(true)
            recordSession.requestRecordPermission() { allowed in
                
                if allowed {
                    print("Access granted")
                } else {
                    print("Access denied")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func accessDeniedAlert() -> UIAlertController {
        
        let alert = UIAlertController(title: "Microphone permission denied", message: "To record, change permission status in iPhone settings", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(alertAction)
        return alert
    }
    
}
