//
//  ViewController.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 02/05/22.
//

import UIKit
import SkeletonView
import Reachability
import DZNEmptyDataSet

class CharacterListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    lazy var characters:[MarvelCharacter]? = []
    var viewModel:CharacterListViewModel?
    private var shouldShowLoadingCell = false
    private var searchController = UISearchController()
    var reachabilityManager:Reachability?
    var listMode:ListMode = .normal
    private let refreshControl = UIRefreshControl()
    let refreshControlAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13),
                                                     .foregroundColor: UIColor.secondaryLabel]
    override func viewDidLoad() {
        super.viewDidLoad()
        reachabilityManager = try? Reachability(hostname: "www.google.com")
        addNewtworkNotification()
        setupUI()
        setupSearchBar()
        loadCharacters()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl.attributedTitle = NSAttributedString(string:"Pull to refresh", attributes: refreshControlAttributes)
        refreshControl.layoutIfNeeded()
        self.tableView.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshCharacterList(_:)), for: .valueChanged)
    }
    deinit{
        removeNewtworkNotification()
    }
    private func setupSearchBar(){
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    private func setupUI(){
        self.title = "Marvel Heroes"
        self.view.isSkeletonable = true
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.emptyDataSetSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.register(CharacterTableViewCell.nib, forCellReuseIdentifier: CharacterTableViewCell.identifier)
    }
    
    func loadCharacters(){
        if viewModel == nil{
            viewModel = CharacterListViewModel(apiService: MarvelCharacterAPIService(),delegate: self)
        }
        if viewModel?.currentCount == 0{
            tableView.animateSkeleton()
        }
        viewModel?.fetchCharacters()
    }

}
extension CharacterListViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (listMode == .normal) ? (viewModel?.totalCount ?? 0) : (viewModel?.currentCount ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacterTableViewCell.identifier, for: indexPath) as! CharacterTableViewCell
        //If cell is loading, show skeleton view for it, else show the contents
        if isLoadingCell(for: indexPath) {
            cell.setup(character: .none)
        } else {
            if let character = viewModel?.character(at: indexPath.row){
                cell.setup(character: character)
            }
        }
        cell.toggleBookmarkCallback = { [weak self](char) in
            if let char = char{
                self?.viewModel?.toggleBookmark(for: char)
                OperationQueue.main.addOperation {
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }else{
                if let character = self?.viewModel?.character(at: indexPath.row){
                    self?.viewModel?.toggleBookmark(for: character)
                    OperationQueue.main.addOperation {
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: CharacterDetailsViewController.identifier) as! CharacterDetailsViewController
        detailsVC.character = self.viewModel?.character(at: indexPath.row)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
}

extension CharacterListViewController:UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
          viewModel?.fetchCharacters()
        }
    }
    
}

extension CharacterListViewController:SkeletonTableViewDataSource{
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CharacterTableViewCell.identifier
    }
}
extension CharacterListViewController: CharacterListViewModelDelegate {
    func searchTextChanged() {
        self.tableView.reloadData()
    }
    
  func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
    guard let newIndexPathsToReload = newIndexPathsToReload else {
        OperationQueue.main.addOperation {
            self.view.hideSkeleton()
            self.tableView.hideSkeleton()
        }
      return
    }
    let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
    tableView.reloadRows(at: indexPathsToReload, with: .automatic)
  }
  
  func onFetchFailed(with reason: String) {
    print("Failed to fetch characters: \(reason)")
      view.hideSkeleton()
      tableView.hideSkeleton()
  }
}

private extension CharacterListViewController {
  func isLoadingCell(for indexPath: IndexPath) -> Bool {
      return indexPath.row >= viewModel?.currentCount ?? 0
  }
  
  func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
    let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
    let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
    return Array(indexPathsIntersection)
  }
}
extension CharacterListViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text?.trimmingCharacters(in: [" "]) ?? ""
        listMode = searchText == "" ? .normal : .search
        viewModel?.searchText = searchText
        viewModel?.getCharacters(for: listMode)
    }
    
}
extension CharacterListViewController{
    func addNewtworkNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: reachabilityManager)
        do {
            try reachabilityManager?.startNotifier()
            print("Reachability notifier started")
        } catch {
            print("Reachability notifier could not start")
        }
    }
    
    func removeNewtworkNotification() {
        reachabilityManager?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachabilityManager)
    }
    
    @objc func reachabilityChanged(_ notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .wifi, .cellular:
            print("Internet available")
            loadCharacters()
        case .none,.unavailable:
            print("Internet unavailable")
        }
    }
    
}
extension CharacterListViewController:DZNEmptyDataSetSource{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyString = (listMode == .search) ? "No results found!" : "No characters!"
        let attrString = NSAttributedString(string: emptyString, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18.0, weight: .bold),NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        return attrString
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyString = (listMode == .search) ? "No matching character found.Please try with some different search text." : "No characters data found.Please try again after some time!"
        let attrString = NSAttributedString(string: emptyString, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16.0, weight: .regular),NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        return attrString
    }
}
extension CharacterListViewController{
    @objc private func refreshCharacterList(_ sender: Any) {
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: refreshControlAttributes)
        refreshControl.layoutIfNeeded()
        viewModel?.refreshCharacterList {
            OperationQueue.main.addOperation {
              self.refreshControl.endRefreshing()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:self.refreshControlAttributes)
                    self.refreshControl.layoutIfNeeded()
                })
            }
        }
    }
}
