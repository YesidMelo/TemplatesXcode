//
//  ComponentAttachment.swift
//  APSoft
//
//  Created by Yesid Melo on 3/14/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit


class ComponentAttachment: UIView {
    
    enum AttachedFileToPickUp{
        static func allElements() -> [AttachedFileToPickUp]{
            return [
                .Camara,
                .Gallery,
                .Audio,
                .Text
            ]
        }
        
        case Camara
        case Gallery
        case Audio
        case Text
        
        func alertElement() -> AttachmentAlert.ElementAlert{
            switch self {
                case .Camara:
                    return AttachmentAlert.ElementAlert.Camara
                case .Gallery:
                    return AttachmentAlert.ElementAlert.Gallery
                case .Audio:
                    return AttachmentAlert.ElementAlert.Audio
                case .Text:
                    return AttachmentAlert.ElementAlert.Text
            }
        }
    }
    
    @IBOutlet var ContentView: ComponentAttachment!
    @IBOutlet weak var CollectionView: UICollectionView!
    private let SIZE_CELL_COLLECTION = CGFloat(80)
    
    private var configView : ConfigView!
            var dataSource : [Attachment]! = [Attachment]() {
        didSet{
            CollectionView.reloadData()
        }
    } 
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        preloadView()        
    }
    
    private func preloadView(){
        registerXib()
        registerCell()
        addViewInParent()
    }
    
    private func registerXib(){
        Bundle.main.loadNibNamed("ComponentAttachment", owner: self, options: nil)
    }
    
    private func registerCell(){
        let nib = UINib(nibName: Constants.Cells.ITEM_ATTACHMENT_CELL, bundle: nil)
        CollectionView.register(nib, forCellWithReuseIdentifier: Constants.Cells.ITEM_ATTACHMENT_CELL)
    }
    
    private func addViewInParent(){
        ContentView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.addSubview(ContentView)
        
    }
    
    
    func setConfigView (_ config :  ConfigView){
        self.configView = config
        setFirstPosition(config)
        
        if let collection = CollectionView{
            dataSource = config.dataSource
            collection.reloadData()
        }
    }
    
    private func setFirstPosition(_ config : ConfigView){
        if !configView.enableCellMore{ return }
        
        let att = Attachment()
        att.AttachmentTypeId = Constants.AttachmentType.ADD.getId()
        config.dataSource.append(att)
    }
    
    func createAttachment(){
        showAlert()
    }
    
    private func showAlert(){
        _ = AttachmentAlert(generateConfigAlert())
        
    }
    
    private func generateConfigAlert() -> AttachmentAlert.ConfigView{
        let configAlert = AttachmentAlert.ConfigView()
        configAlert.viewController = self.viewController()
        configAlert.attachmentAlertDelegate = self
        configAlert.ElementsAlert = generateElementsAlert()
        return configAlert
    }
    
    private func generateElementsAlert() -> [AttachmentAlert.ElementAlert]{
        var list = [AttachmentAlert.ElementAlert]()
        for attachedFileToPickUp in configView.attachedFileToPickUp{
            list.append(attachedFileToPickUp.alertElement())
        }
        return list
    }
    
    func getListAttachment() ->[Attachment]{
        if !configView.enableCellMore {
            return dataSource
        }
        dataSource.reverse()
        dataSource.remove(at: 0)
        dataSource.reverse()
        return dataSource
        
    }
    
    class ConfigView{
        var dataSource : [Attachment]! = [Attachment]()
        var updateView : (()->Void)!
        var enableCellMore : Bool! = false
        var attachedFileToPickUp : [AttachedFileToPickUp]! = [AttachedFileToPickUp.Camara,AttachedFileToPickUp.Gallery,AttachedFileToPickUp.Audio]
    }
    
}

extension ComponentAttachment : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cells.ITEM_ATTACHMENT_CELL, for: indexPath) as! ItemAttachmentCell
        cell.itemComponente = dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !iCanListenSelectionCell() { return } 
        if !isCellAdd(dataSource[indexPath.item]){ return }
        showAlert()
    }
    
    private func iCanListenSelectionCell() -> Bool{
        return configView.enableCellMore && dataSource.count > 0
    }
    
    private func isCellAdd(_ attachment : Attachment) -> Bool {
        return attachment.AttachmentTypeId == Constants.AttachmentType.ADD.getId()
    }
   
    
}

extension ComponentAttachment : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: SIZE_CELL_COLLECTION, height: SIZE_CELL_COLLECTION)
    }
}

extension ComponentAttachment : AttachmentAlertDelegate {
    func attachmentSelected(_ attachment: Attachment) {
        dataSource.insert(attachment , at: 0)
        CollectionView.reloadData()
        if let fun = configView.updateView{
            fun()
        }
    }
    
    
}
