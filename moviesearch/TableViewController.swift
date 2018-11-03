//
//  TableViewController.swift
//  moviesearch
//
//  Created by Ilya Kalinin on 02/11/2018.
//  Copyright © 2018 Ilya Kalinin. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    var results = [Movie]()
    var cachedImageData = [URL : Data]()
    var triggerSearchTimer = Timer()
    var isFetchingMoreResults = false
    var page = 1
    var total = 1
    var selection: IndexPath?
    
    let resultsLimit = 20
    let cellIdentifier = "cellIdentifier"
    
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        setupSearchController()
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController:  nil)
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        navigationItem.titleView = searchController.searchBar
        
        definesPresentationContext = true
    }
    
    @objc func triggerFetch() {
        self.tableView.backgroundView = nil
        
        if let text = searchController.searchBar.text, text.count > 0 {
            searchMovies(with: text)
        } else {
            results = [Movie]()
            page = 1
            tableView.reloadData()
        }
    }
    
    func searchMovies(with query: String) {        
        SearchService.search(query: query) { [weak self] (movies, total, error) in
            self?.total = total
            if (error == nil) {
                self?.updateTableView(with: movies)
            }
        }
        
    }
    
    func updateTableView(with results : [Movie]?) {
        if let results = results, results.count > 0 {
            self.results = results
            DispatchQueue.main.async { [weak self] () -> Void in
                self?.tableView.reloadData()
                self?.page = 1
                self?.cachedImageData = [URL : Data]()
            }
        } else {
            DispatchQueue.main.async { [weak self] () -> Void in
                self?.tableView.backgroundView = UINib(nibName: "NotFoundView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
                self?.results = [Movie]()
                self?.page = 1
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TableViewCell.self), for: indexPath) as! TableViewCell
        let movie = results[indexPath.row]

        cell.titleLabel.text = movie.title
        cell.descriptionLabel.text = movie.description
        cell.imageView?.image = nil

        if let url = movie.posterURL() {
            if let data = cachedImageData[url] {
                cell.imageView?.image = UIImage(data: data)
            } else {
                cell.imageView?.tag = url.hashValue
                let downloadImageRequest = URLRequest(url: url)
                URLSession.shared.dataTask(with: downloadImageRequest, completionHandler: { [weak self] (data, urlResponse, error) in
                    if error == nil, let data = data {
                        DispatchQueue.main.async {
                            self?.cachedImageData[url] = data
                            if cell.imageView?.tag == url.hashValue {
                                cell.imageView?.image = UIImage(data: data)
                                cell.setNeedsLayout()
                            }
                        }
                    }
                }).resume()
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.item == results.count - Int(resultsLimit/2) && !isFetchingMoreResults && total <= page) {
            isFetchingMoreResults = true
            
            if let text = searchController.searchBar.text, text.count > 0 {
                SearchService.search(query: text, page: self.page + 1) { [weak self] (results, total, error) in
                    if (error == nil) {
                        if let searchResults = results {
                            self?.page += 1
                            self?.results.append(contentsOf: searchResults)
                            DispatchQueue.main.async {
                                self?.tableView.reloadData()
                            }
                        }
                    }
                    self?.isFetchingMoreResults = false
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selection = indexPath
        return selection
    }
    
    // MARK: - Search
    
    func updateSearchResults(for searchController: UISearchController) {
        triggerSearchTimer.invalidate()
        triggerSearchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(triggerFetch), userInfo: nil, repeats: false)
    }
    
    // MARK: - Scroll
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (searchController.searchBar.isFirstResponder) {
            searchController.searchBar.resignFirstResponder()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailViewController" {
            if let vc = segue.destination as? ViewController {
                guard let selection = selection else {
                    return
                }
                
                let movie = results[selection.row]
                var image: UIImage?
                
                if let url = movie.posterURL(), let data = cachedImageData[url] {
                    image = UIImage(data: data)
                }
                
                vc.movie = movie
                vc.poster = image
            }
        }
    }
}
