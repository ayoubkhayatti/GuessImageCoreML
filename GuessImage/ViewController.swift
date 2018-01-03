//
//  ViewController.swift
//  GuessImage
//
//  Created by Ayoub Khayati on 11/06/2017.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate {
	
	//MARK: - Properties
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var textView: UITextView!
	
	let imagePicker = UIImagePickerController()
	
	//MARK: - ViewController
	
	override func viewDidLoad() {
		super .viewDidLoad()
		self.imagePicker.delegate = self
	}
	
	@IBAction func openImagePicker(_ sender: Any) {
		imagePicker.allowsEditing = false
		imagePicker.sourceType = .photoLibrary
		present(imagePicker, animated: true, completion: nil)
	}
	
}

extension ViewController: UIImagePickerControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imageView.contentMode = .scaleAspectFit
			imageView.image = pickedImage
			textView.text = "Guessing..."
			processImage(pickedImage.cgImage!) { [weak self] text in
				self?.textView.text = text
			}
		}
		
		picker.dismiss(animated: true, completion: nil)
	}
	
}

//MARK: - CoreML

extension ViewController {
	
	func processImage(_ image: CGImage, completion: @escaping (String)->Void ){
		
		DispatchQueue.global(qos: .userInitiated).async {
			
			//Init Core Vision Model
			guard let vnCoreModel = try? VNCoreMLModel(for: Inceptionv3().model) else { return }
			
			//Init Core Vision Request
			let request = VNCoreMLRequest(model: vnCoreModel) { (request, error) in
				guard let results = request.results as? [VNClassificationObservation] else { fatalError("Failure") }
				var text = ""
				for classification in results {
						text.append("\n" + "\(classification.identifier, classification.confidence)")
				}
				
				DispatchQueue.main.async {
					completion(text)
				}
			}
			//Init Core Vision Request Handler
			let handler = VNImageRequestHandler(cgImage: image)
			
			//Perform Core Vision Request
			do {
				try handler.perform([request])
			} catch {
				print("did throw on performing a VNCoreRequest")
			}
		}
	}
}
