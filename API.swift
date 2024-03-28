//
//  API.swift
//  MyMovies
//
//  Created by Leticia Oliveira Neves on 03/04/24.
//

import Foundation

struct APIResult: Codable {
    let results: [Trailer]
}

struct Trailer: Codable {
    let previewUrl: String
}

class API {
    //Este objeto irá conter o endereço base para nossa API.
    //Ao final dessa URL iremos adicionar o nome do filme
    static let basePath = "https://itunes.apple.com/search?media=movie&entity=movie&term="
    
    //Aqui estamos criando nosso objeto URLSessionConfiguration,
    //utilizando o modo default
    static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        
        //Vamos permitir o uso de conexões via redes celulares
        config.allowsCellularAccess = true
        
        //Abaixo, atribuímos o header de Content-Type à nossa config.
        //Com isso, estamos dizendo que nossa requisição trabalha com
        //conteúdo em formato JSON
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        
        //Limitamos o tempo de espera de resposta para 45 segundos
        config.timeoutIntervalForRequest = 45.0
        
        //No máximo, 5 conexões poderão ser feitas
        config.httpMaximumConnectionsPerHost = 5
        
        return config
    }()
    
    //Criamos o objeto URLSession, passando o arquivo de configuração como parâmetro.
    //Note que não usamos nenhum dos singletons (.default, .efhemeral, .background)
    static let session = URLSession(configuration: configuration)
    
    //Se quiséssemos usar uma session mais simples, com
    //configurações padrões, poderíamos usar a opção abaixo
    //static let session = URLSession.shared
    
    //Este método fará a leitura de todas as informações
    //referentes ao título do filme passado. Note que estamos trabalhando
    //com métodos de classe (métodos estáticos)
    static func loadTrailers(title: String, onComplete: @escaping (APIResult?) -> Void) {
        
        //A linha abaixo formata o título para que possa ser usado na URL de chamada,
        //pois sabemos que URLs não podem conter espaços ou caracteres especiais.
        guard let encodedTitle = (title).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            
        //Combinando a url base com o título do filme
        let url = URL(string: basePath+encodedTitle) else {
            onComplete(nil)
            return
        }

        
        //Estamos utilizando o método dataTask que aceita como parâmetros a url com a rota
        //que será chamada e a closure que será executada nos trazendo todas as informações da requisição,
        //como o objeto Data, a resposta (URLResponse) e o erro caso tenha ocorrido
        let task = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
                onComplete(nil) //Caso tenha ocorrido algum erro, devolvemos nil para o onComplete
            } else {
                //Fazemos o cast de URLResponse para HTTPURLResponse pois esperamos uma resposta HTTP
                guard let response = response as? HTTPURLResponse else {
                    onComplete(nil) //Não obtivemos um objeto válido de resposta do servidor
                    return
                }
                //Caso o código seja 200, o servidor respondeu com sucesso
                if response.statusCode == 200 {
                    guard let data = data else {
                        onComplete(nil) //Não trouxe dados
                        return
                    }
                    //Criando nosso objeto json com os dados obtidos
                    do {
                        let apiResult = try JSONDecoder().decode(APIResult.self, from: data)
                        onComplete(apiResult)  //Devolvemos o array de resultados
                    } catch {
                        onComplete(nil)
                    }
                } else {
                    onComplete(nil)
                }
            }
        }
        
        //Esta chamada é fundamental pois sem ela a task não é executada
        task.resume()
    }
}
