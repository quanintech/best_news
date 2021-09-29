//
//  ViewController.swift
//  BestNews
//
//  Created by admin on 2021/9/14.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON
import CoreData

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate {
    var newsTitle = [String]()
    var bestnews: [BestNews] = []
    var fetchResultController: NSFetchedResultsController<BestNews>!
    var bestNews_: BestNews!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bestnews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath)
        
        cell.textLabel?.text = bestnews[indexPath.row].title
        print("xxxx\(bestnews[indexPath.row])")
        cell.imageView?.image = UIImage(named: "news")
        return cell
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            //getOutData()//获取并保存数据
            updateSnapshot()
        }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getOutData()//获取并保存数据
        fetchRestaurantData()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func getOutData() {
        //return "神舟十二号三名航天员凯旋 150秒回顾90天太空之旅"
        let URL = "http://localhost:8080/test123"
        let parameters: Parameters = ["sort": "string"]
        AF.request(URL,parameters:parameters).responseJSON{response  in
            //your code here
            switch response.result {
                case .success( _):
                    if let data = response.data {
                        do{
                            let json = try JSON(data: data)
                            //result指的是json的第一个key值，以及后面的取值方式是以一个数组拿出来，这里需要自己按照实际情况
                            //let title = json["data"].array![0].string!
                            for (_, element) in json["data"] {
                                print("xxx\(element)")
                                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                                    self.bestNews_ = BestNews(context: appDelegate.persistentContainer.viewContext)
                                    self.bestNews_.title = element.string!
                                    print("test\(element.string!)")
                                    print("Saving data to context...")
                                    appDelegate.saveContext()
                                }
                            }
                        }catch{
                        }
                    }
                case .failure(let error):
                    print("\(error)")
            }
        }
    }
    
    
//    func fetchRestaurantData() {
//        // Fetch data from data store
//        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
//            let context = appDelegate.persistentContainer.viewContext
//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BestNews")
//            do {
//                    let students = (try context.fetch(request)) as! [BestNews]
//                    bestnews = students
//                } catch {
//                    print("Fetch failed...")
//                }
//        }
//    }
  
    func fetchRestaurantData() {
        // Fetch data from data store
        let fetchRequest:NSFetchRequest<BestNews> = NSFetchRequest<BestNews>(entityName: "BestNews")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

            fetchResultController.delegate = self

            do {
                try fetchResultController.performFetch()
                updateSnapshot()

            } catch {
                print(error)
                
            }
        }
    }
    
    func updateSnapshot(animatingChange: Bool = false) {

        if let fetchedObjects = fetchResultController.fetchedObjects {
            bestnews = fetchedObjects
            print("endyyy:\(fetchedObjects)")
        }
        // Create a snapshot and populate the data
    }
    
}
