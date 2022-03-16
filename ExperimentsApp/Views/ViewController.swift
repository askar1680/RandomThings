import UIKit

class ViewController: UIViewController {

    let tableView = TableView()
    
    var texts: [String] = []
    let count = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EADispatchSemaphore.test()
        for i in 0...count {
            texts.append("text #\(i)")
        }
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: "FeedTableViewCell")
        tableView._delegate = self
    }
}

extension ViewController: TableViewDelegate {
    func updateCell(cell: TableViewCell, index: Int) {
        guard let feedCell = cell as? FeedTableViewCell else {
            return
        }
        feedCell.set(title: texts[index])
    }
    
    func numberOfElements() -> Int {
        return texts.count
    }
}

class FeedTableViewCell: TableViewCell {
    
    private let titleLabel = UILabel()
    private let separatorView = UIView()
    
    func set(title: String) {
        titleLabel.text = title
    }
    
    required init(reuseIdentifier: String) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])
        
        addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        titleLabel.text = "Just text"
        
        separatorView.backgroundColor = .gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
