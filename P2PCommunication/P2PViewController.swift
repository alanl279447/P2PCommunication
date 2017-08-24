


import UIKit

class P2PViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var TextEntered: UITextField!
    @IBOutlet weak var ReceivedLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var groupList = [String]()
    
   
    
    let P2PService = P2PServiceManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "groupcell")
        
        P2PService.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        TextEntered.delegate = self
        self.connectionsLabel.numberOfLines = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func SendData(_ sender: UIButton) {
        let textValue = self.TextEntered.text
        NSLog("%@", "Text entered:  \(textValue!)")
        P2PService.sendData(DataName: textValue!)
    }
    
    func received(data : String) {
      //self.ReceivedLabel.text = data
        groupList.append(data)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        
    {
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        print("test log")
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "groupcell", for: indexPath as IndexPath) as UITableViewCell
        
        cell.textLabel?.text = self.groupList[indexPath.row]
        return cell
    }
    
}

extension P2PViewController : P2PServiceManagerDelegate {
    func updateReceivingProgress(manager: P2PServiceManager, notification: NSDictionary) {
        
    }
    
    func connectedDevicesChanged(manager: P2PServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            if (connectedDevices.count > 0) {
             self.connectionsLabel.text = "Connections: \(connectedDevices[0])"
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
        
    }
    
    func didFinishReceivingResource(manager: P2PServiceManager, resourcename: String, localUrl: URL) {
        
    }
    
}
