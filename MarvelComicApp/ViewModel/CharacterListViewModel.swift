//
//  CharacterListViewModel.swift
//  MarvelComicApp
//
//  Created by Vishal Sonawane on 03/05/22.
//

import Foundation

protocol CharacterListViewModelDelegate: AnyObject {
  func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
  func onFetchFailed(with reason: String)
  func searchTextChanged()
}
class CharacterListViewModel{
    private weak var delegate: CharacterListViewModelDelegate?
    private var apiService:APIService
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    private var characters: [MarvelCharacter] = []
    var searchText = ""
    
    var totalCount: Int {
      return total
    }
    var currentCount: Int {
      return characters.count
    }
    
    func character(at index: Int) -> MarvelCharacter {
      return characters[index]
    }
    init(apiService:APIService,delegate:CharacterListViewModelDelegate){
        self.apiService = apiService
        self.delegate = delegate
    }
    func fetchCharacters() {
        //If internet is not available, fetch records from the local database and then use them
        guard Utilities.internetConnectionAvailable() else {
            let savedCharacters = RealmDatabaseManager.shared.fetchAllMarvelCharacters()
            self.characters = Array(savedCharacters)
            if !savedCharacters.isEmpty{
                self.delegate?.onFetchCompleted(with: .none)
            }else{
                self.delegate?.onFetchFailed(with: "No internet connection")
            }
            return
        }
        
        //Early return if fetch is already in progress
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        
        self.apiService.fetchMarvelCharaters(params: ["limit":"30","offset":"\(self.currentPage)","apikey":Keys.API_PUBLIC_KEY]) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.delegate?.onFetchFailed(with: error.localizedDescription)
                }
            case .success(let response):
                DispatchQueue.main.async {
                    self.currentPage += 1
                    self.isFetchInProgress = false
                    self.total = response?.data?.total ?? 0
                    print("currentPage: \(self.currentPage) | total: \(self.total) | page: \(response?.data?.offset ?? 0)")
                    if let chars = response?.data?.results{
                        self.characters.append(contentsOf: chars)
                        do{
                            try RealmDatabaseManager.shared.saveObjects(objects: self.characters)
                        }catch{
                            print("Failed to save the characters. Reason :\(error.localizedDescription)")
                        }
                    }
                    //Based on the page, reload data via delegate
                    if response?.data?.offset ?? 0 > 1 {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: response?.data?.results ?? [])
                        self.delegate?.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self.delegate?.onFetchCompleted(with: .none)
                    }
                }
            }
        }
    }
    
    private func calculateIndexPathsToReload(from newCharacters: [MarvelCharacter]) -> [IndexPath] {
      let startIndex = characters.count - newCharacters.count
      let endIndex = startIndex + newCharacters.count
      return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    func toggleBookmark(for character:MarvelCharacter){
        RealmDatabaseManager.shared.writeCallback {
            character.isBookmarked.toggle()
        }
    }
    func getCharacters(for listMode:ListMode){
        if listMode == .search && !self.searchText.isEmpty{
            self.characters = self.characters.filter{$0.name?.lowercased().contains(searchText.lowercased()) == true}
        }else{
            self.characters = Array(RealmDatabaseManager.shared.fetchAllMarvelCharacters())
        }
        delegate?.searchTextChanged()
    }
    //This will fetch first page data
    func refreshCharacterList(completion:@escaping()->()){
        self.apiService.fetchMarvelCharaters(params: ["limit":"30","offset":"0","apikey":Keys.API_PUBLIC_KEY]) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.delegate?.onFetchFailed(with: error.localizedDescription)
                }
            case .success(let response):
                DispatchQueue.main.async {
                    if let chars = response?.data?.results{
                        self.characters.append(contentsOf: chars)
                        do{
                            try RealmDatabaseManager.shared.saveObjects(objects: self.characters)
                        }catch{
                            print("Failed to save the characters. Reason :\(error.localizedDescription)")
                        }
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                completion()
            }
            
        }
    }
  }
