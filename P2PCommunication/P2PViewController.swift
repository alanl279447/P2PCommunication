


import UIKit

class P2PViewController: UIViewController {

    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var TextEntered: UITextField!
    @IBOutlet weak var ReceivedLabel: UILabel!
    
    let P2PService = P2PServiceManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        P2PService.delegate = self
    }
    
    @IBAction func SendData(_ sender: UIButton) {
        let textValue = self.TextEntered.text
        NSLog("%@", "Text entered:  \(textValue!)")
        P2PService.sendData(DataName: textValue!)
    }
    
    func received(data : String) {
      self.ReceivedLabel.text = data
    }
    
}

extension P2PViewController : P2PServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: P2PServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func dataReceived(manager: P2PServiceManager, inputString: String) {
        OperationQueue.main.addOperation {
            NSLog("%@", "input received is: \(inputString)")
            self.received(data: inputString)
        }
    }
    
}
