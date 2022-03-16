import UIKit

protocol ViewInput: AnyObject {
    func set(clubs: [Club])
}

final class SearchViewController: UIViewController {

    private var presenter: Presenter?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private var clubs: [Club] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = PresenterImpl()
        presenter?._view = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "id")
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.search(text: searchController.searchBar.text)
    }
}

extension SearchViewController: ViewInput {
    func set(clubs: [Club]) {
        self.clubs = clubs
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "id")
        cell.textLabel?.text = clubs[indexPath.row].title
        return cell
    }
}

protocol Presenter {
    var _view: ViewInput? { get set }
    func search(text: String?)
}

final class PresenterImpl: Presenter {
    
    weak var view: ViewInput?
    
    var _view: ViewInput? {
        get { return view }
        set { view = newValue }
    }
    
    private var searchWorkItem: DispatchWorkItem?
    private var requestWorkItem: DispatchWorkItem?
    private let clubs: [Club] = [
        Club(title: "Manchester United"),
        Club(title: "Manchester City"),
        Club(title: "Arsenal"),
        Club(title: "Barselona"),
        Club(title: "Real Madrid"),
        Club(title: "Chelsea"),
        Club(title: "Atletico Madrid"),
        Club(title: "Bayern"),
        Club(title: "Dortmund Borussia"),
    ]
    
    func search(text: String?) {
        print("search \(text ?? "")")
        searchWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.makeRequestWith(text: text)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.4, execute: workItem)
        searchWorkItem = workItem
    }
    
    private func makeRequestWith(text: String?) {
        guard let text = text, !text.isEmpty else {
            DispatchQueue.main.async {
                self.view?.set(clubs: [])
            }
            return
        }
        
        requestWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let this = self else {
                return
            }
            let filteredClubs = this.clubs.filter { $0.title.lowercased().contains(text.lowercased()) }
            DispatchQueue.main.async {
                this.view?.set(clubs: filteredClubs)
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5, execute: workItem)
        requestWorkItem = workItem
    }
}

struct Club {
    var title: String
}
