//
//  MapViewController.swift
//  MyMovies
//
//  Created by Leticia Oliveira Neves on 07/04/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    //Criando objeto CLLocationManager
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pedimos que o mapa mostre a localizacao do usuario
        mapView.showsUserLocation = true
        
        //Atraves da propriedade userTrackingMode, definimos que o mapa irá rastrear
        // a localização do usuário, centralizando onde ele estiver
        mapView.userTrackingMode = .follow
        
        mapView.delegate = self
        
        requestAuthorization()
    }
    
    //Criamos o método abaixo para solicitar a autorização do usuário p/ acesso à sua localização
    func requestAuthorization() {
        //Definindo precisão da localização. A constante kCLLocationAccuracyBest fornce a maior precisão possivel
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Método que solicita a autorização
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    @IBAction func search(_ sender: Any) {
        
        textField.resignFirstResponder()
        
        //objeto que ocnfigura os parâmetros da pesquisa
        let request = MKLocalSearch.Request()
        
        //a propriedade naturalLanguageQuery contém o texto que sera utilizado na busca
        request.naturalLanguageQuery = textField.text
        print(textField.text!)
        
        //definimos a regiao que sera usada para buscar os pontos de interesse
        request.region = mapView.region
        
        //Aqui, criamos o objeto que realizará a busca
        let search = MKLocalSearch(request: request)
        
        //atraves do metodo start realizamos a busca
        search.start { (response, error) in
            if error == nil {
                //caso nao tenha erro, recuperamos os elementos solicitados
                guard let response = response else {return}
                
                //O objeto response possui uma propriedade chamada mapItems contendo todos os locais encontrados para a pesquisa
                
                /*for item in response.mapItems {
                 
                 //caso o local tenha um nome, imprimimos no console
                 if let name = item.name {
                 print("-", name)*/
                
                //antes de adicionar novas, removemos todas as annotations presentes no mapa
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                for item in response.mapItems {
                    //criando uma annotation
                    let annotation = MKPointAnnotation()
                    
                    //definindo sua coordenada, titulo e subtitulo
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.url?.absoluteString
                    
                    //adicionando annotation no mapa
                    self.mapView.addAnnotation(annotation)
                    
                    
                }
                
            }
        }
        
        
        
        
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation

         func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let vc = segue.destination as? SiteViewController, let sender = sender as? String {
                 vc.site = sender
             }

         }
         
        
    }
}
    
extension MapViewController: MKMapViewDelegate {

    //Método chamado quando uma Annotation View é selecionada
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //Recuperando annotation e nome
        guard let annotation = view.annotation, let name = annotation.title else {return}

        let alert = UIAlertController(title: name, message: "O que deseja fazer?", preferredStyle: .actionSheet)

        //Se houver subtitle, adiciona action para ir ao site
        if let subtitle = annotation.subtitle, let url = subtitle {
            let urlAction = UIAlertAction(title: "Acessar site", style: .default) { (action) in
                //Ir para o site
                self.performSegue(withIdentifier: "webSegue", sender: url)
            }
            alert.addAction(urlAction)
        }

        //Action para traçar a rota
        let routeAction = UIAlertAction(title: "Traçar rota", style: .default) {(action) in

        //Chamando método que irá mostrar a rota
        self.showRoute(to: annotation.coordinate)
        }
        alert.addAction(routeAction)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showRoute(to destination: CLLocationCoordinate2D) {
        //Objeto de requisição de rota
        let request = MKDirections.Request()

        //Configurando origem e destino. Note que estes objetos
        //são do tipo MKMapItem, e para criar um MKMapItem
        //precisamos criar um MKPlacemark, que pode ser criado a
        //partir de uma coordenada.
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))

        //O objeto que faz o cálculo da rota é o MKDirections
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if error == nil {

                //Abaixo, desembrulhamos o response e também
                //recuperamos a primeira rota da lista de rotas
                //presentes no response
                guard let response = response, let route = response.routes.first else {return}

                //É possível recuperar uma série de informações
                //sobre a rota, como nome, distância, tempo, etc
                print("Nome:", route.name, "- distância:", route.distance, "- duração:", route.expectedTravelTime)

                //Além disso, é possível recuperar todos os
                //passos da rota
                for step in route.steps {
                    print("Em", step.distance, "metros, ", step.instructions)
                }

                //Antes de adicionar o overlay, precisamos
                //remover qualquer outra rota apresentada
         self.mapView.removeOverlays(self.mapView.overlays)
                //Agora, vamos adicionar a rota no mapa. Isso é
                //feito utilizando overlay.
                //A propriedade polyline nos dá a linha poligonal
                //que representa a rota, e é esta linha que
                //iremos colocar por cima do mapa.
                //Vamos colocar a rota por cima das ruas e abaixo
                //dos nomes das ruas
                self.mapView.addOverlays([route.polyline], level: .aboveRoads)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Se o overlay for uma MKPolyline, usamos o renderer correspondente
        if overlay is MKPolyline {
            //Criando um renderer para polylines
            let renderer = MKPolylineRenderer(overlay: overlay)

            //Definindo sua espessura e cor
            renderer.lineWidth = 8.0
            renderer.strokeColor = .blue

            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

