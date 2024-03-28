//
//  ViewController.swift
//  MyMovies
//
//  Created by Leticia Oliveira Neves on 27/03/24.
//

import UIKit
import UserNotifications
import AVKit

class ViewController: UIViewController {
    
    var moviePlayer: AVPlayer?
    var moviePlayerController: AVPlayerViewController?
    
    //Criando datepicker para recuperar a data
    var datePicker = UIDatePicker()
        
        //Criando objeto de alerta
    var alert: UIAlertController!
    
    var trailer : String = ""
    
    
    var movies: [Movie] = []
    
    var movie: Movie?
    
    @IBOutlet weak var ivMovie: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCategories: UILabel!
    
    @IBOutlet weak var lbDuration: UILabel!
    @IBOutlet weak var lbRating: UILabel!
    @IBOutlet weak var tvSummary: UITextView!
    @IBOutlet weak var btPlay: UIButton!
    
    
        override func viewDidLoad() {
          super.viewDidLoad()
            if let title = movie?.title {
                loadTrailers(title: title)
            }
            
            //definindo a data minima do datePicker p hoje
            datePicker.minimumDate = Date()
            
            //adicionando  metodo a ser chamado quando o datePicker tiver seu valor alterado
            datePicker.addTarget(self, action: #selector(changeDate), for: .valueChanged)
            
        }
    
    @IBAction func play(_ sender: Any) {
        guard let moviePlayerController = moviePlayerController else {return}
        present(moviePlayerController, animated: true) {
            self.moviePlayer?.play()
        }
    }
    
    
    func prepareVideo() {
        //Criando a URL com o endereço do trailer do filme
        guard let url = URL(string: trailer) else {return}

        //Instanciando o moviePlayer e moviePlayerController
        moviePlayer = AVPlayer(url: url)
        moviePlayerController = AVPlayerViewController()

        //Definimos que o moviePlayer será o player de vídeo da
        //controller
        moviePlayerController?.player = moviePlayer

        //Definindo que os controles de playback do vídeo serão
        //mostrados
        moviePlayerController?.showsPlaybackControls = true
    }
    
    
    @objc func changeDate() {
            
        //Criamos o dateFormatter para formatar a data
        let dateformatter = DateFormatter()
        
        //Aqui, definimos o estilo que a data será
        //apresentada
        dateformatter.dateFormat = "dd/MM/yyyy HH:mm'h"
        
        //Recuperamos a data do datePicker para repassar ao
        //TextField
        alert.textFields?.first?.text = dateformatter.string(from: datePicker.date)
    }
    
    @IBAction func scheduleNotification(_ sender: UIButton) {
        
        //Criando Alert Controller como .alert
        alert = UIAlertController(title: "Lembrete", message: "Quando deseja ser lembrado de assistir o filme?", preferredStyle: .alert)
        
        //Adicionando um Text Field ao alerta
        alert.addTextField { (textField) in
            textField.placeholder = "Data do lembrete"
            self.datePicker.date = Date()
            textField.inputView = self.datePicker
        }
        
        //Adicionando botões de Agendar e Cancelar. Para criar uma
        //Action, definimos o seu titulo e seu estilo.
        //O estilo .default é o padrão.
        let okAction = UIAlertAction(title: "Agendar", style: .default) { (action) in
            self.schedule()
        }
        
        //Em uma action que serve para cancelar uma ação, o ideal
        //é utilizar o estilo .cancel
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        //Aqui, adicionamos as duas actions ao alert
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        //Mostrando o alerta para o usuário
        present(alert, animated: true, completion: nil)
    }
    
    func schedule(){
        let content = UNMutableNotificationContent()
        content.title = "Lembrete"
        let movieTitle = movie?.title ?? ""
        content.body = "Assistir filme \"\(movieTitle)\""
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: datePicker.date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Lembrete", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
        
    func loadTrailers(title: String) {
        
        API.loadTrailers(title: title) { (apiResult) in guard let results = apiResult?.results, let trailer = results.first else {return}
            
            DispatchQueue.main.async {
                self.trailer = trailer.previewUrl
                //print ("URL do Trailer:", trailer.previewUrl)
                self.prepareVideo()
            }
            
        }
    }
    
    //este metodo abrira o arquivo movies.json e convertera em um array de Movie
   /* func loadMovies() {
        
        //Recuperando a URL do arquivo
        guard let fileURL = Bundle.main.url(forResource: "movies", withExtension: "json") else {return}
        do {
            //criando o data, a representacao binaria de nosso arquivo
            let data = try Data(contentsOf: fileURL)
            
            //Decodoficando o JSON em um Array de Movie
            movies = try JSONDecoder().decode([Movie].self, from: data)
            
            //varremos o array para imprimir na debug area o nome e duracao de cada filme
            for movie in movies {
                print(movie.title, "_", movie.duration)
            }
        } catch {
            //caso aconteça algum erro na interpretacao do JSON, o sistema de tratamento exibir;a a causa
            print(error.localizedDescription)
        }
    } */
    
    override func viewWillAppear(_ animated: Bool) {
        //loadMovies()
          if let movie = movie {
              ivMovie.image = movie.image as? UIImage
              lbTitle.text = movie.title
              lbCategories.text = movie.categories
              lbDuration.text = movie.duration
              lbRating.text = "🌟 \(movie.rating)/10"
              tvSummary.text = movie.summary
          }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddEditViewController {
            vc.movie = movie
        }
    }
}

