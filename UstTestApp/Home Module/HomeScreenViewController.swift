import UIKit
import Network

class HomeScreenViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let viewModel = HomeScreenViewModel()
    var services: [NetService] = []
    var netServiceBrowser: NetServiceBrowser!
    let coreDataHelper = CoreDataHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AirPlay Devices"
        self.navigationItem.setHidesBackButton(true, animated: true)
        tableView.register(UINib(nibName: "HomeScreenCell", bundle: nil), forCellReuseIdentifier: "HomeScreenCell")
        // Start browsing for services
        netServiceBrowser = NetServiceBrowser()
        netServiceBrowser.delegate = self
        netServiceBrowser.searchForServices(ofType: "_airplay._tcp.", inDomain: "")
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        viewModel.fetchAllDevices()
    }
}

extension HomeScreenViewController : NetServiceDelegate, NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        service.resolve(withTimeout: 5.0)
        services.append(service)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let index = services.firstIndex(of: service) {
            services.remove(at: index)
            viewModel.devices.remove(at: index)
            tableView.reloadData()
        }
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let addresses = sender.addresses, !addresses.isEmpty else {
            return
        }
        
        if let ip = viewModel.getIP(from: addresses) {
            viewModel.isReachable(ip: ip) { reachable in
                let device = AirPlayDevice(name: sender.name, ipAddress: ip, isReachable: reachable)
                print(sender.name)
                DispatchQueue.main.async {
                    let predicate = NSPredicate(format: "name == %@", sender.name)
                    let entityExists = self.coreDataHelper.entityExists(entityName: "Device", with: predicate)
                    let deviceNew = AirPlayDevice(name: sender.name, ipAddress: ip, isReachable: false)
                    if !entityExists {
                        self.coreDataHelper.saveNewAirPlayDevice(device: deviceNew)
                        self.viewModel.devices.append(device)
                    }else {
                        self.coreDataHelper.deleteAirPlayDevice(device: deviceNew)
                        self.coreDataHelper.saveNewAirPlayDevice(device: device)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension HomeScreenViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.devices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenCell", for: indexPath) as! HomeScreenCell
        let device = viewModel.devices[indexPath.row]
        cell.nameLbl.text = device.name
        cell.ipAddress.text = device.ipAddress
        cell.reachable.text = device.isReachable ? "Reachable" : "Not Reachable"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}


