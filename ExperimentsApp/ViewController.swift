import UIKit

class ViewController: UIViewController {

    let tableView = TableView()
    
    var texts: [String] = []
    let count = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

protocol TableViewDelegate: AnyObject {
    func updateCell(cell: TableViewCell, index: Int)
    func numberOfElements() -> Int
}

class TableView: UIScrollView {
    
    weak var _delegate: TableViewDelegate?
    
    let height: CGFloat = 100
    private var numberOfElements: Int = 0
    
    private let numberOfScreens = 2
    private var cellClass: TableViewCell.Type!
    private var identifier: String!
    private var cells: [TableViewCell] = []
    private var addedCells = false
    
    func register(_ cellClass: TableViewCell.Type, forCellReuseIdentifier identifier: String) {
        self.cellClass = cellClass
        self.identifier = identifier
    }
    
    func reloadData() {
        guard let numberOfElements = _delegate?.numberOfElements() else {
            return
        }
        if addedCells {
            return
        }
        self.numberOfElements = numberOfElements
        
        addedCells = true
        let contentHeight = CGFloat(numberOfElements) * height
        contentSize = CGSize(width: frame.width, height: contentHeight)
        
        let tableHeight = frame.height
        let numberOfCellsInOneScreen = Int(tableHeight / height) + 2
        
        for i in 0..<(numberOfScreens * numberOfCellsInOneScreen) {
            let cell = cellClass.init(reuseIdentifier: identifier)
            _delegate?.updateCell(cell: cell, index: i)
            let originY = CGFloat(i) * height
            cell.frame = CGRect(x: 0, y: originY, width: frame.width, height: height)
            addSubview(cell)
            cells.append(cell)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadData()
    }
    
    func cellAt(index: Int) -> TableViewCell? {
        if cells.isEmpty {
            return nil
        }
        let firstCellIndex = Int(cells[0].frame.minY / height)
        if index + firstCellIndex > cells.count || index + firstCellIndex < 0 {
            return nil
        }
        return cells[index - firstCellIndex]
    }
    
    override var contentOffset: CGPoint {
        didSet {
            if cells.count < 2 || contentOffset.y < 0 || contentOffset.y >= CGFloat(numberOfElements) * height {
                return
            }
            
            let contentOffSet: CGFloat = contentOffset.y + 92
            let cellOffSet: CGFloat = calculateCellsOffSet()
            if abs(contentOffSet - cellOffSet) < height {
                return
            }
            
            if contentOffSet > cellOffSet {
                let contentHeight = CGFloat(numberOfElements) * height
                let lastCellY = cells[cells.count - 1].frame.maxY
                if contentHeight == lastCellY {
                    return
                }
                
                let firstCell = cells[0]
                firstCell.prepareForReuse()
                cells.removeFirst()
                
                let updatedIndex = Int(lastCellY / height)
                _delegate?.updateCell(cell: firstCell, index: updatedIndex)
                
                firstCell.frame = CGRect(x: 0, y: lastCellY, width: frame.width, height: height)
                cells.append(firstCell)
            }
            else {
                let firstCellY = cells[0].frame.minY
                if firstCellY == 0 {
                    return
                }
                
                let lastCell = cells[cells.count - 1]
                lastCell.prepareForReuse()
                cells.removeLast()
                
                let updatedIndex = Int((firstCellY - height) / height)
                _delegate?.updateCell(cell: lastCell, index: updatedIndex)
                
                lastCell.frame = CGRect(x: 0, y: firstCellY - height, width: frame.width, height: height)
                cells.insert(lastCell, at: 0)
            }
        }
    }
    
    private func calculateCellsOffSet() -> CGFloat {
        let firstCell = cells[0]
        let lastCell = cells[cells.count - 1]
        return (firstCell.frame.minY + lastCell.frame.maxY) / 2
    }
}

class TableViewCell: UIView {
    required init(reuseIdentifier: String) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse() {
        
    }
}
