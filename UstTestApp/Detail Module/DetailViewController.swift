
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var carrierLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var viewModel = DetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail Screen"
        viewModel.fetchIPAddressDetails { result in
            switch result {
            case .success(let DetailModel):
                DispatchQueue.main.async {
                    self.updateUI(with: DetailModel)
                }
            case .failure(let error):
                print("Error fetching IP address details: \(error.localizedDescription)")
            }
        }
    }
    
    func updateUI(with details: DetailModel) {
        ipAddressLabel.text = details.ipAddress
        countryLabel.text = "Country: \(details.country)"
        cityLabel.text = "City: \(details.city)"
        organizationLabel.text = "Organization: \(details.organization)"
        carrierLabel.text = "Carrier: \(details.carrier)"
    }
}
