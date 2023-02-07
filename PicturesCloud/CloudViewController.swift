//
//  CloudViewController.swift
//  PicturesCloud
//
//  Created by haoshuai on 2022/5/23.
//

import UIKit
import IGListKit
import IGListDiffKit
import RxSwift
import ObjectMapper
// 云册照片
class CloudViewController: GridViewController {
    
    @IBOutlet weak var _collectionView: UICollectionView!
    
    override func collectionView() -> UICollectionView {
        return _collectionView;
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return CloudSectionController(selected: self.selectedData, delegate: self)
    }
    
    override func reloadDataSource() -> [GridListItem] {
//        let list = photoManager.requestDataSource(selectTypeIndex)
//        guard let fr = list.first else {
//            return []
//        }
//        let item = GridListItem(identifier: fr.identifier, dataSouce: list)
//        return [item]
//        let list = photoManager.requestDataSource(selectTypeIndex)
//        guard let fr = list.first else {
//            return []
//        }
//        let item = GridListItem(identifier: fr.identifier, dataSouce: list)
        
        Client.shared.api.requestNormal(.getPhotos(PhotoOptions()), callbackQueue: nil, progress: nil) { result in
            switch result {
            case let .success(reponse):
                guard reponse.statusCode == 200, let jsonStr = String.init(data: reponse.data, encoding: .utf8) else {
                    return
                }
                debugPrint(jsonStr)
                guard let photos = Mapper<Photo>().mapArray(JSONString: jsonStr) else {
                    return
                }
                let uid = photos.first!.UID!
                let list = photos.map { item in
                    return GridItem.init(identifier: item.UID!, mediaType: .image, mediaSubtypes: .photoDepthEffect, pixelWidth: item.Width, pixelHeight: item.Height, creationDate: nil, location: nil, duration: 0, isFavorite: false, isHidden: false, isInCloud: true, imageURL: item.previewURL, asset: nil)
                }
                let data = GridListItem(identifier: uid, dataSouce: list)
                self.dataSource = [data]
//                self.dataSource = self.reloadDataSource()
                DispatchQueue.main.async {
                    self.adapter.performUpdates(animated: true, completion: nil)
                }
                
            case let .failure(error):
                break
                
            }
        }

        return []
    }
    
    @IBAction func onSegmentControl(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        self.selectTypeIndex = index
        self.dataSource = self.reloadDataSource()
        self.adapter.performUpdates(animated: true, completion: nil)
    }
    
    

//    func loadDataSource() {
////        Client.shared.api.rx.request(.getPhotos(PhotoOptions()))
//        Client.shared.api.requestNormal(.getPhotos(PhotoOptions()), callbackQueue: nil, progress: nil) { result in
//            switch result {
//
//            }
//        }
//    }

}

