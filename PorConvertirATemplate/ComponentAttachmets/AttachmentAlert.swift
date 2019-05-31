//
//  AttachmentAlert.swift
//  APSoft
//
//  Created by Yesid Melo on 3/21/19.
//  Copyright © 2019 Exsis. All rights reserved.
//

import UIKit


protocol AttachmentAlertDelegate{
    func attachmentSelected(_ attachment:Attachment)
}

class AttachmentAlert: UIView {
    
    enum ElementAlert{
        static func allElements() -> [ElementAlert]{
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
    }
    
    @IBOutlet var ContentView: UIView!
    @IBOutlet weak var ImageViewBlur: UIImageView!
    
    @IBOutlet weak var ImageViewCamera: UIImageView!
    @IBOutlet weak var ImageViewGallery: UIImageView!
    @IBOutlet weak var TapRecord: ViewTapRecord!
    @IBOutlet weak var ImageViewText: UIImageView!
    
    @IBOutlet weak var LabelCamera: UILabel!
    @IBOutlet weak var LabelGallery: UILabel!
    @IBOutlet weak var LabelRecord: UILabel!
    @IBOutlet weak var LabelText: UILabel!
    
    
    @IBOutlet weak var ConstraintWidthCamera: NSLayoutConstraint!
    @IBOutlet weak var ConstraintWidthGallery: NSLayoutConstraint!
    @IBOutlet weak var ConstraintWithTapRecord: NSLayoutConstraint!
    @IBOutlet weak var ConstraintWidthText: NSLayoutConstraint!
    
    private var defaultWidthCamara : CGFloat!
    private var defaultWidthGallery : CGFloat!
    private var defaultWidthAudio : CGFloat!
    private var defaultWidthText : CGFloat!
    
    
    
    private var config : ConfigView!
    private var selectorImageViewController = UIImagePickerController()   
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init (_ config : ConfigView){
        self.config = config
        let width = config.viewController.view.frame.width
        let heigth = config.viewController.view.frame.height 
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: heigth))
        preload()
    }
   
    private func preload(){
        registerXib()
        applyBlurImageViewBlur()
        configImagePickerController()
        addListenersToImagesView()
        configTapRecord()
        addInViewControllerContainer()
        hiddenAllElementsToSelect()
        selectElementsToShow()
    }
    
    private func applyBlurImageViewBlur(){
        ImageViewBlur.blurImage()
    }
    
    private func registerXib(){
        Bundle.main.loadNibNamed("AttachmentAlert", owner: self, options: nil)
        
    }
    
    private func configImagePickerController(){
        selectorImageViewController.delegate = self
    }
    
    private func addListenersToImagesView(){
        enableInteractionWithUser()
        addGesturesTap()
    }
    
    private func enableInteractionWithUser(){
        ImageViewCamera.isUserInteractionEnabled = true
        ImageViewGallery.isUserInteractionEnabled = true
        
    }
    
    private func addGesturesTap(){
        let gestureImageViewCamera = UITapGestureRecognizer(target: self, action: #selector(listenImageViewCamera))
        let gestureImageViewGallery = UITapGestureRecognizer(target: self, action: #selector(listenImageViewGallery))
                
        ImageViewCamera.addGestureRecognizer(gestureImageViewCamera)
        ImageViewGallery.addGestureRecognizer(gestureImageViewGallery)
        
    }  
    	
    @objc func listenImageViewCamera(){
        selectorImageViewController.allowsEditing = false
        selectorImageViewController.sourceType = .camera
        config.viewController.present(selectorImageViewController, animated: true,completion: nil)
    }
    
    @objc func listenImageViewGallery(){
        selectorImageViewController.allowsEditing = false
        selectorImageViewController.sourceType = .photoLibrary
        config.viewController.present(selectorImageViewController, animated: true,completion: nil)
    } 
   
    private func configTapRecord(){
        TapRecord.delegate = generateDelegate()
    }
    
    private func generateDelegate() -> ViewTapRecord.ViewTapRecordDelegate {
        let delegate = ViewTapRecord.ViewTapRecordDelegate()
        delegate.successfulSaveAudio = successfulSaveAudio
        delegate.failSaveAudio = failSaveAudio
        delegate.withoutPermits = withoutPermits
        return delegate
    }
    
    private func successfulSaveAudio(_ urlAudio : URL){
        let newAttachment = Attachment()
        newAttachment.imageAsociate = UIImage(named: "icMicrophone")
        newAttachment.URL = urlAudio.absoluteString
        newAttachment.AttachmentTypeId = Constants.AttachmentType.AUDIO.getId() as NSNumber 
        self.config.attachmentAlertDelegate.attachmentSelected(newAttachment)
        closeAlert()
    }
    
    private func failSaveAudio(){
        
    }
    
    private func withoutPermits(){
        
    }
    
    private func addInViewControllerContainer(){
        ContentView.frame = frame
        self.addSubview(ContentView)
        config.viewController.view.addSubview(self)
    }
    
    private func hiddenAllElementsToSelect(){
        hiddenCamara()
        hiddenGallery()
        hiddenAudio()
        hiddenText()
    }
    
    private func hiddenCamara(){
        defaultWidthCamara = ConstraintWidthCamera.constant
        ConstraintWidthCamera.constant = 0
        ImageViewCamera.isHidden = true
        LabelCamera.isHidden = true
    }
    
    private func hiddenGallery(){
        defaultWidthGallery = ConstraintWidthGallery.constant
        ConstraintWidthGallery.constant = 0
        ImageViewGallery.isHidden = true
        LabelGallery.isHidden = true
    }
    
    private func hiddenAudio(){
        defaultWidthAudio = ConstraintWithTapRecord.constant
        ConstraintWithTapRecord.constant = 0
        TapRecord.isHidden = true
        LabelRecord.isHidden = true
    }
    
    private func hiddenText(){
        defaultWidthText = ConstraintWidthText.constant
        ConstraintWidthText.constant = 0
        ImageViewText.isHidden = true
        LabelText.isHidden = true
    }
    
    
    
    private func selectElementsToShow(){
        for itemToShow in config.ElementsAlert{
            switch itemToShow{
            case ElementAlert.Camara:
                showCamara()
                continue
            case ElementAlert.Gallery:
                showGallery()
                continue
            case ElementAlert.Audio:
                showAudio()
                continue
            case ElementAlert.Text:
                showText()
                continue
            }
        }
    }
    
    private func showCamara(){
        ConstraintWidthCamera.constant = defaultWidthCamara
        ImageViewCamera.isHidden = false
        LabelCamera.isHidden = false
    }
    
    private func showGallery(){
        ConstraintWidthGallery.constant = defaultWidthGallery
        ImageViewGallery.isHidden = false
        LabelGallery.isHidden = false
    }
    
    private func showAudio(){
        ConstraintWithTapRecord.constant = defaultWidthAudio
        TapRecord.isHidden = false
        LabelRecord.isHidden = false
    }
    
    private func showText(){
        ConstraintWidthText.constant = defaultWidthText
        ImageViewText.isHidden = false
        LabelText.isHidden = false
    }
    
    
    @IBAction func listenButtonCancel(_ sender: Any) {
        closeAlert()
    }
    
    private func closeAlert(){
        removeFromSuperview()
    }
    
    class ConfigView{
        var viewController : UIViewController!
        var ElementsAlert : [ElementAlert]! = [ElementAlert.Camara,ElementAlert.Gallery,ElementAlert.Audio]
        var attachmentAlertDelegate : AttachmentAlertDelegate!
    }
}

extension AttachmentAlert : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            generateNewAttachment(pickedImage)	
        }
        closeAlert()
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    private func generateNewAttachment(_ image : UIImage){
        let newAttachment = Attachment()
        newAttachment.URL = saveImage(image)
        newAttachment.imageAsociate = loadImage(newAttachment.URL)
        
        newAttachment.AttachmentTypeId = Constants.AttachmentType.IMAGE.getId() as NSNumber
        self.config.attachmentAlertDelegate.attachmentSelected(newAttachment)
    }
    
    private func saveImage(_ image : UIImage) -> String{
        let url = documentsURL()
        let nameImage = "Image_\(Date().generateDateToAudioFile())"
        let fileURL = url.appendingPathComponent(nameImage)
        
        if let imageData = image.jpegData(compressionQuality: CGFloat(1.0)){
            try? imageData.write(to: fileURL,options: .atomic)
            return nameImage
        }
        
        return ""
    }
    
    private func documentsURL() ->  URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
    
   
}

extension AttachmentAlert : UINavigationControllerDelegate{
    
}


extension UIImageView{        
    func blurImage()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}

