import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class App {
    let router = Router()
    let cloudEnv = CloudEnv()

    // A simple collection of String names paired with Meal instances    
    private var mealStore: [String: Meal] = [:]

    public init() throws {
        // Run the metrics initializer
        initializeMetrics(router: router)
    }

    func postInit() throws {
        // Endpoints
        initializeHealthRoutes(app: self)
     
        // Routes that the application will respond on:
        // POST on /meals calls storeHandler()
        // GET  on /meals calls loadHandler()   
        router.post("/meals", handler: storeHandler)
        router.get("/meals", handler: loadHandler)
    }
    
    // storeHander() implements best practices for REST requests.
    // It receives a Meal from the client, and "completes" by sending
    // back the newly stored object or an error
    func storeHandler(meal: Meal, completion: (Meal?, RequestError?) -> Void ) {
        mealStore[meal.name] = meal
        completion(mealStore[meal.name], nil)
    }
   
    // loadHandler() implememts best practices for REST requests
    // It receives a request for all of the Meal object and completes 
    // by sending an array of Meals or an error 
    func loadHandler(completion: ([Meal]?, RequestError?) -> Void ) {
        let meals: [Meal] = self.mealStore.map({ $0.value })
        completion(meals, nil)
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}
