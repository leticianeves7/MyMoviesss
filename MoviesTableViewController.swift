//
//  MoviesTableViewController.swift
//  MyMovies
//
//  Created by Leticia Oliveira Neves on 27/03/24.
//

import UIKit
import CoreData

class MoviesTableViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController<Movie>!
    
    var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovies()
    }
    
    func loadMovies() {
        /*guard let fileURL = Bundle.main.url(forResource: "movies", withExtension: "json") else {return}
        do {
            let data = try Data(contentsOf: fileURL)
            movies = try JSONDecoder().decode([Movie].self, from: data)
        } catch {
            print(error.localizedDescription)
        }*/
        
        //O objeto fetchRequest é responsavel por fazer uma leitura dos itens do Core Data. Criamos um fetchRequest de Movie pois queremos buscar todos os filmes da base. A classe Movie (gerada pelo Core Data) já possui um método que nos retorna seu fetchRequest
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        //Abaixo definimos que os filmes serao ordenados em ordem alfabética pelo titulo
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //Instanciando objeto fetchedResultsController. Aqui precisamos passar o fetchRequest e o contexto do Core Data
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            //executando requisicao de movies
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieTableViewCell
        
        let movie = fetchedResultsController.object(at: indexPath)
        // Configure the cell...
        
        cell.lbTitle.text = movie.title
        cell.lbSummary.text = movie.summary
        cell.ivIMovie.image = movie.image as? UIImage

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //Se o usuario apertou o botao delete
        if editingStyle == .delete {
            // Delete the row from the data source
            
            //Recuperamos p filme daquela célula
            let movie = fetchedResultsController.object(at: indexPath)
            //O context possui um método para exclusão de um elemento
            context.delete(movie)
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //Recuperando a próxima cena e tratando-a como ViewController
        if let vc = segue.destination as? ViewController {
            
            //A propriedade indexPathForSelectedRow nos retorna o IndexPath da celula selecionada. Usaremos como indice para indicar o movie selecionado
            let movie = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            
            //Repassando o movie para a proxima tela
            vc.movie = movie
            
        }
        
    }
    
}

extension MoviesTableViewController:NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
