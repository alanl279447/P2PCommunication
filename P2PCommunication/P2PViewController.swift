


import UIKit

class P2PViewController: UIViewController {

    @IBOutlet weak var connectionsLabel: UILabel!

    let P2PService = P2PServiceManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension P2PViewController : P2PServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: P2PServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    
}
