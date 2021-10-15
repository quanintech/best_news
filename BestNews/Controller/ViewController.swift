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
    var asyncFetchRequest: NSAsynchronousFetchRequest<BestNews>!
    var bestNews_: BestNews!
    var page: Int = 0
    var limit: Int = 10
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bestnews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath)
        print("position\(indexPath.row)")
        print("count\(self.bestnews.count)")
        cell.textLabel?.text = bestnews[indexPath.row].title
//        print("xxxxIMAGE01\(bestnews[indexPath.row].title)")
//        print("xxxxIMAGE02\(bestnews[indexPath.row].url)")
//        print("xxxxIMAGE03\(bestnews[indexPath.row])")
        let imageUrl_ = bestnews[indexPath.row].url!
        let imageUrl:URL = URL(string: imageUrl_)!
        let imageData = try? Data(contentsOf: imageUrl)
        cell.imageView?.image = UIImage(data:imageData!)
        return cell
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            self.tableView.reloadData()
        }
    

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("xxxooo")
        getOutData()//获取并保存数据
        
        let newPageBegin = self.bestnews.count/10
        let newPage = ceil(Double(newPageBegin))
        self.getHowManyDataIn()
        let newlimit = (Int(newPage) + 1) * limit
        fetchRestaurantData(limit: newlimit)
        print("xxxooocountend\(self.bestnews.count)")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getOutData()//获取并保存数据
        fetchRestaurantData(limit: self.limit)
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
                            for (_, element) in json["data"] {
                                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                                    self.bestNews_ = BestNews(context: appDelegate.persistentContainer.viewContext)
                                    self.bestNews_.title = element["title"].string
                                    self.bestNews_.url = element["url"].string
                                    print("Saving data to context...")
                                    appDelegate.saveContext()
                                }
                            }
                        }catch{
                            print("pppp:\(error)")
                        }
                    }
                case .failure(let error):
                    print("\(error)")
            }
        }
    }
    
    
//    func savedata(parameters: JSON) throws -> String {
//        for (_, element) in parameters {
//            print("xxx\(element)")
//            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
//                self.bestNews_ = BestNews(context: appDelegate.persistentContainer.viewContext)
//                self.bestNews_.title = element.string!
//                print("test\(element.string!)")
//                print("Saving data to context...")
//                appDelegate.saveContext()
//            }
//        }
//        return "ok"
//    }
    
    
//    func fetchRestaurantData(limit:Int) {
//        // Fetch data from data store
//        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
//            let context = appDelegate.persistentContainer.viewContext
//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BestNews")
//            do {
//                    let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//                    request.sortDescriptors = [sortDescriptor]
//                    request.fetchLimit = limit
//                    let students = (try context.fetch(request)) as! [BestNews]
//                    self.bestnews = students
//                } catch {
//                    print("Fetch failed...")
//                }
//        }
//    }
  
    func fetchRestaurantData(limit:Int) {
        // Fetch data from data store
        let fetchRequest:NSFetchRequest<BestNews> = NSFetchRequest<BestNews>(entityName: "BestNews")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = limit
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

    func updateSnapshot() {
        if let fetchedObjects = fetchResultController.fetchedObjects {
            self.bestnews = fetchedObjects
            print("xxxooo:countE\(self.bestnews.count)")
        }
    }
    
    
    // 获取Context
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    

    
    func getHowManyDataIn(){
        let fetchRequest: NSFetchRequest<BestNews> = BestNews.fetchRequest()
        getContext().perform {
            do {
                let result = try fetchRequest.execute()
                print("end:\(result.count)")
            }catch{
                print("Unable to Execute Fetch Request, \(error)")
            }
        }
        
//        getContext().refreshAllObjects()
//
//        // Perform Fetch Request
//        getContext().perform {
//            do {
//                // Execute Fetch Request
//                let result = try fetchRequest.execute()
//
//                // Update Books Label
//                //self.booksLabel.text = "\(result.count) Books"
//                print("end:\(result.count)")
//
//            } catch {
//                print("Unable to Execute Fetch Request, \(error)")
//            }
//        }
//        do {
//            let searchResults = try getContext().count(for: fetchRequest)
//            print("numbers of \(searchResults)")
//        } catch  {
//            print(error)
//        }
    }
    
}
