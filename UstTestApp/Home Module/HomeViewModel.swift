import Foundation
import Network

class HomeScreenViewModel {
    
    let coreDataHelper = CoreDataHelper()
    var devices: [AirPlayDevice] = []
    
    var reloadData: (() -> Void)?
    
    init() {
        fetchAllDevices()
    }
    
    func fetchAllDevices() {
        if let devices = coreDataHelper.fetchAirPlayDevices() {
            self.devices = devices
            reloadData?()
        }
    }
    func getIP(from addresses: [Data]) -> String? {
        for address in addresses {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let success = address.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Bool in
                let sockaddr = pointer.bindMemory(to: sockaddr.self).baseAddress!
                return getnameinfo(sockaddr, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0
            }
            if success, let ip = String(validatingUTF8: hostname) {
                return ip
            }
        }
        return nil
    }
    
    func isReachable(ip: String, completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        monitor.pathUpdateHandler = { path in
            completion(path.status == .satisfied)
            monitor.cancel()
        }
        monitor.start(queue: queue)
    }
}
