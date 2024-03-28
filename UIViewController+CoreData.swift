//
//  UIViewController+CoreData.swift
//  MyMovies
//
//  Created by Leticia Oliveira Neves on 27/03/24.
//

import UIKit
import CoreData

extension UIViewController {

    //Esta variável computada nos dará acesso ao NSManagedObjectContext a partir de qualquer tela
    var context: NSManagedObjectContext {

        //Aqui estamos criando uma referência ao AppDelegate
        let appDelegate = UIApplication.shared.delegate
             as! AppDelegate


        //Conseguimos acessar o NSManagedObjectContext a partir da propriedade .viewContext presente em nosso persistentContainer. Aqui apenas retornamos essa propriedade.
        return appDelegate.persistentContainer.viewContext
    }
}
