//
//  AddEditViewController.swift
//  MyMovies
//
//  Created by Leticia Oliveira Neves on 28/03/24.
//

import UIKit

class AddEditViewController: UIViewController {
    
    var movie: Movie?
    
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfCategories: UITextField!
    @IBOutlet weak var tfRating: UITextField!
    @IBOutlet weak var tfDuration: UITextField!
    @IBOutlet weak var tvSummary: UITextView!
    @IBOutlet weak var ivMovie: UIImageView!
    @IBOutlet weak var btAddEdit: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let movie = movie {
            ivMovie.image = movie.image as? UIImage
            tfTitle.text = movie.title
            tfCategories.text = movie.categories
            tfDuration.text = movie.duration
            tfRating.text = "🌟 \(movie.rating)/10"
            tvSummary.text = movie.summary
            btAddEdit.setTitle("Alterar", for: .normal)
        }
    }
    
    @IBAction func addPoster(_ sender: UIButton) {
        
        //criando alerta do tipo actionSheet
        let alert = UIAlertController(title: "Selecionar pôster", message: "De onde você quer escolher o pôster?", preferredStyle: .actionSheet)
        
        //verificamos se a camera esta disponivel no device.
        //obs.: nao temos acesso à cmera pelo simulador.
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default) { (action) in
                self.selectPicture(source: .camera)
            }
            alert.addAction(cameraAction)
        }
        
        //criando as actions para abrir a biblioteca de fotos e o album de fotos
        let libraryAction = UIAlertAction(title: "Biblioteca de Fotos", style: .default) { (action) in
            self.selectPicture(source: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de Fotos", style: .default) { (action) in
            self.selectPicture(source: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    func selectPicture(source: UIImagePickerController.SourceType) {
        //Criando obejto UIImagePickerController
        let imagePicker = UIImagePickerController()
        
        //definindo sourceType baseado no parâmetro
        imagePicker.sourceType = source
        
        //definimos esta classe como sua delegate
        imagePicker.delegate = self
        
        //apresentando ao usuario
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addEditMovie(_ sender: Any) {
        if movie == nil {
            movie = Movie(context: context)
        }
        
        movie?.title = tfTitle.text
        movie?.categories = tfCategories.text
        movie?.duration = tfDuration.text
        movie?.rating = Double(tfRating.text!) ?? 0
        movie?.image = ivMovie.image
        movie?.summary = tvSummary.text
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
        
        func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
            
        }
        
        // Do any additional setup after loading the view.
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
    }
}

extension AddEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            //Recuperando de forma segura a imagem através da
            //chave UIImagePickerController.InfoKey.originalImage
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                
                //Vamos recuperar a largura e altura originais
                //para definirmos a proporção da imagem e assim
                //podermos reduzí-la, deixando com 800 pixels de
                //tamanho no seu lado maior.
                let aspectRatio = image.size.width / image.size.height
                var smallSize: CGSize
                if aspectRatio > 1 {
                    smallSize = CGSize(width: 800, height: 800/aspectRatio)
                } else {
                    smallSize = CGSize(width: 800*aspectRatio, height: 800)
                }
                
                //Os códigos abaixo são necessários para criarmos
                //uma versão reduzida da imagem
                UIGraphicsBeginImageContext(smallSize)
                image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
                let smallImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                //Vamos atribuir a imagem pequena à nossa
                //Image View
                ivMovie.image = smallImage
                
                //Aqui, fechamos o Image Picker
                dismiss(animated: true, completion: nil)
            }
        }
    }

