//
//  ItemAttachmentCell.swift
//  APSoft
//
//  Created by Yesid Melo on 3/14/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit

class ItemAttachmentCell: UICollectionViewCell {
    
    @IBOutlet weak var ImageViewToShow: UIImageView!
    
    var itemComponente: Attachment!{
        didSet{
            if iHaveAURL(){
                loadImageFromURL()
                setImageInImageView()
                return 
            }
            if iHaveImageStringBase64(){
                convertStringToImage()
                setImageInImageView()
                return
            }
            selectImageToShowByTypeAttachment()
            setImageInImageView()
        }
    }
    
    private func iHaveAURL()->Bool{
        return itemComponente.URL != nil
    }
    
    private func loadImageFromURL(){
        if isTypeAttachmentValidToLoadURL() { return }
        itemComponente.imageAsociate = loadImage(itemComponente.URL)
        setImageInImageView()
    }
    private func isTypeAttachmentValidToLoadURL() -> Bool {
        return (Constants.AttachmentType.IMAGE.getId() == itemComponente.AttachmentTypeId) ||
        ((Constants.AttachmentType.TEXT.getId() == itemComponente.AttachmentTypeId))
    }
    
    private func loadImage(_ nameDocument : String) -> UIImage?{
        do{
            let url = documentsURL().appendingPathComponent(nameDocument)
            let imageData = try Data(contentsOf: url)
            return UIImage(data: imageData)
        }catch{
            print("error : \(error)")
        }
        return nil
    }
    
    private func documentsURL() ->  URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func setImageInImageView(){
        ImageViewToShow.image = itemComponente.imageAsociate
    }
    
    private func iHaveImageStringBase64() -> Bool {
        return itemComponente.PhotoImage != nil 
    }
    
    private func convertStringToImage() {
        itemComponente.imageAsociate = itemComponente.PhotoImage!.base64ToImage()
    }
    
    private func selectImageToShowByTypeAttachment(){
        switch itemComponente.AttachmentTypeId {
            case Constants.AttachmentType.IMAGE.getId(),
                 Constants.AttachmentType.TEXT.getId() : return
            
        case Constants.AttachmentType.AUDIO.getId():
            itemComponente.imageAsociate = UIImage(named: "icMicrophone")
            return
        case Constants.AttachmentType.ADD.getId():
            itemComponente.imageAsociate = UIImage(named: "icAddGreen")
            return 
        default : 
            return
        }
    }
    
    
    
}
