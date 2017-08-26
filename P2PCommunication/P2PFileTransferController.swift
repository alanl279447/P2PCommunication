
import UIKit

class P2PFileTransferController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var TextEntered: UITextField!
    @IBOutlet weak var ReceivedLabel: UILabel!
    @IBOutlet weak var tblFiles: UITableView!
    var groupList = [String]()
    var arrFiles = [String?]()
    let P2PService = P2PServiceManager()
    var documentsDirectory: String = ""
    var selectedFile: String = ""
    var selectedRow: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        copySampleFilesToDocDirIfNeeded()
        arrFiles = getAllDocDirFiles()!
        self.tblFiles.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        P2PService.delegate = self
        tblFiles.delegate = self
        tblFiles.dataSource = self
        tblFiles.reloadData()
    }
    
    func SendResouces(filename: String) {
     NSLog("%@", "SendResouces called \(filename)")
     P2PService.sendResourceAtURL(filepath: filename)
     }
    
    func received(data : String) {
        //self.ReceivedLabel.text = data
        //groupList.append(data)
        self.tblFiles.reloadData()
    }
    
    
    private func copySampleFilesToDocDirIfNeeded() {
        let _ : Array = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        documentsDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!

        //documentsDirectory = (paths[0])
        let file1Path : String = documentsDirectory + "/sample_file1.txt"
        let file2Path : String = documentsDirectory + "/sample_file2.txt"
        let fileManager : FileManager = FileManager.default

        
        if !fileManager.fileExists(atPath: file1Path) || !fileManager.fileExists(atPath: file2Path) {
            
            do {
                try fileManager.copyItem(atPath: Bundle.main.path(forResource: "sample_file1", ofType: "txt")!, toPath: file1Path)
                try fileManager.copyItem(atPath: Bundle.main.path(forResource: "sample_file2", ofType: "txt")!, toPath: file2Path)
            } catch let error as NSError  {// Handle the error
                print("Couldn't copy file to final location! Error:\(error.localizedDescription)")
            }
            
        }
    }
    
    public func getAllDocDirFiles() -> [String]? {
        let _: NSError? = nil
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: documentsDirectory)
            if contents == nil {
                return (nil)
            }
            else {
                let filenames = contents as [String]
                return (filenames)
            }
        } catch let error as NSError  {// Handle the error
            print("Couldn't copy file to final location! Error:\(error.localizedDescription)")
        }
        return nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if (arrFiles[indexPath.row] != nil) {
            cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "CellIdentifier")
                cell?.accessoryType = .disclosureIndicator
            }
            cell?.textLabel?.text = arrFiles[indexPath.row]
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "newFileCellIdentifier")
            _ = arrFiles[indexPath.row]
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (arrFiles[indexPath.row] != nil) {
            return 60.0
        }
        else {
            return 80.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile: String = arrFiles[indexPath.row] ?? ""
        let confirmSending = UIActionSheet(title: selectedFile, delegate: self, cancelButtonTitle: "", destructiveButtonTitle: "", otherButtonTitles: "")
        confirmSending.addButton(withTitle: "sendFile")
        confirmSending.cancelButtonIndex = confirmSending.addButton(withTitle: "Cancel")
        confirmSending.show(in: view)
        self.selectedFile = arrFiles[indexPath.row] ?? ""
        selectedRow = indexPath.row
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        // Move to a background thread to do some long running work
        //DispatchQueue.global(qos: .userInitiated).async {
         //   self.P2PService.sendResourceAtURL(filepath: self.selectedFile)
            // Bounce back to the main thread to update the UI
        //}
        self.P2PService.sendResourceAtURL(filepath: self.selectedFile)
    }
    
    
    func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [String : Any]?, context: UnsafeMutableRawPointer?) {
        let sendingMessage: String = "\(selectedFile) - Sending %.f%%"
        arrFiles[selectedRow] = sendingMessage
        self.tblFiles.reloadData()
    }
    
}


extension P2PFileTransferController : P2PServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: P2PServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            
            self.connectionsLabel.lineBreakMode = .byWordWrapping
            self.connectionsLabel.numberOfLines = 0
            
            if (connectedDevices.count > 0) {
             self.connectionsLabel.text = "Connections: \n\(connectedDevices[0])"
            }
        }
    }
    
    func dataReceived(manager: P2PServiceManager, inputString: String) {
        OperationQueue.main.addOperation {
            NSLog("%@", "input received is: \(inputString)")
            self.received(data: inputString)
        }
    }
    
    
    func didStartReceivingResource(manager: P2PServiceManager, notification: NSDictionary) {
        arrFiles.append(notification.description)
        self.tblFiles.reloadData()
    }
    
    func updateReceivingProgress(manager: P2PServiceManager, notification: NSDictionary) {
        _ = notification.value(forKey: "Progress")
        _ = arrFiles[(arrFiles.count - 1)]
        self.tblFiles.reloadData()
    }
    
    func didFinishReceivingResource(manager: P2PServiceManager, resourcename: String, localUrl: URL) {
        let localURL: URL = localUrl
        let resourceName = resourcename + "2"
        let destinationPath: URL = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(resourceName)
        let fileManager = FileManager.default
        try? fileManager.copyItem(at: localURL, to: destinationPath)
        
        arrFiles.removeAll()
        arrFiles = getAllDocDirFiles()!
        
        DispatchQueue.main.async {
            self.tblFiles.reloadData()
        }
    }
    
    //func connectedDevicesChanged(manager : P2PServiceManager, connectedDevices: [String])
    //func dataReceived(manager: P2PServiceManager, inputString: String)
    //func didStartReceivingResource(manager : P2PServiceManager, notification: NSDictionary)
    //func updateReceivingProgress(manager : P2PServiceManager, notification: NSDictionary)
    //func didFinishReceivingResource(manager : P2PServiceManager, notification: NSDictionary)
}
