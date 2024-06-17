import UIKit
import AVFoundation
import NotificationCenter

class MainViewController: UIViewController {
    
    //MARK: - @IBOutlets
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recTimeLabel: UILabel!
    @IBOutlet weak var recordingsTableView: UITableView!
    
    //MARK: - Properties
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var timer = Timer()
    var recordings = [URL]()
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closingApplicationHandle()
        showRecordings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        permissionHandle()
    }
    
    //MARK: - @IBAction
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
        }
       
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording()
        }

}

    //MARK: - Flow methods
    
    private func closingApplicationHandle() {
        
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            if self.audioRecorder != nil {
                self.finishRecording()
            }
        }
    }
    
    private func permissionHandle() {
        
        Manager.shared.microphonePermission()
        
        if AVAudioSession.sharedInstance().recordPermission == .denied {
            
            recordButton.isEnabled = false
            present(Manager.shared.accessDeniedAlert(), animated: true)
        }
    }
    
    private func startRecording() {
        
        setupRecorder()
        startTimer()
        audioRecorder.record()
    }
    
    private func finishRecording() {
        
        recTimeLabel.text = "00:00"
        timer.invalidate()
        audioRecorder.stop()
        audioRecorder = nil
        showRecordings()
        recordingsTableView.reloadData()
        
    }
    
    func showRecordings() {
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: Manager.shared.getDirectoryUrl(), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            recordings = urls.filter({ (name: URL) -> Bool in
                return name.pathExtension == "m4a"
            }).sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setupRecorder() {
        
        do {
            audioRecorder = try AVAudioRecorder(url: Manager.shared.getRecorderProperties().0, settings: Manager.shared.getRecorderProperties().1)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func startTimer() {

        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateAudioMeter),
            userInfo: nil,
            repeats: true)
    }
    
    @objc func updateAudioMeter() {
        
        if let recorder = audioRecorder {
            if recorder.isRecording {
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let timeString = String(format: "%02d:%02d", min, sec)
                recTimeLabel.text = timeString
                recorder.updateMeters()
            }
        }
    }
    
}

