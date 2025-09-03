import UIKit
import Combine

class CartDetailViewController: UIViewController {
    
    private let viewModel: CartDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: CartDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let qtyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let stepper = UIStepper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Cart Detail"
        
        qtyLabel.textAlignment = .center
        qtyLabel.font = UIFont.systemFont(ofSize: 32)
        qtyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.minimumValue = 1
        stepper.setIncrementImage(UIImage(systemName: "plus")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        stepper.setDecrementImage(UIImage(systemName: "minus")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        stepper.addTarget(self, action: #selector(didChangeStepper), for: .valueChanged)
        
        view.addSubview(qtyLabel)
        view.addSubview(stepper)
        
        NSLayoutConstraint.activate([
            qtyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qtyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stepper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepper.topAnchor.constraint(equalTo: qtyLabel.bottomAnchor, constant: 20)
        ])
        
        viewModel.item.$quantity
            .receive(on: RunLoop.main)
            .sink { [weak self] qty in
                self?.qtyLabel.text = "Qty: \(qty)"
                self?.stepper.value = Double(qty)
            }.store(in: &cancellables)
    }
    
    @objc func didChangeStepper() {
        let qty = Int(stepper.value)
        viewModel.updateQuantity(qty)
    }
}
