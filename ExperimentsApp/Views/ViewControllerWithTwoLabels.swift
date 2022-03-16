import UIKit

final class ViewControllerWithTwoLabels: UIViewController {
    let label1 = UILabel()
    let stackView = UIStackView()
    let label2 = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.addSubview(label1)
        view.addSubview(stackView)
        stackView.addArrangedSubview(label2)
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        label1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        label1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: label1.topAnchor, constant: 50).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
        label1.text = "The longest text. The longest text. The longest text"
        label1.numberOfLines = 0
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        label2.text = "Just text Just text Just text"
        label2.numberOfLines = 0
    }
}
