//
//  MainTableViewController.swift
//  4PDA
//
//  Created by Полар Групп on 04.12.16.
//  Copyright © 2016 Polar Development Group. All rights reserved.
//

import UIKit



class MainTableViewController: UITableViewController, ParserDelegate {
    
    var newsArray:[News] = []
    var parser: Parser!
    var loading: Bool = false
    var currentElementName: String!
    let url = URL(string: "http://4pda.ru/feed")
    let limit = 5
    var page = 1
    
    @IBOutlet weak var loadingText: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        self.tableView.tableHeaderView?.backgroundColor = UIColor(red:0.00, green:0.45, blue:0.74, alpha:1.0)
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.tableView.tableFooterView?.isHidden = true
        
        parser = Parser(url: url!)
        parser.delegate = self
        parser.startParsing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsArray.count > limit*page ? limit*page: newsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: cell.frame.height-15))
        
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.45, 0.74, 1.0])
        
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.backgroundColor = UIColor.clear
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)
        
        cell.NewsTitle.text = newsArray[indexPath.row].title
        cell.NewsDescription.text = newsArray[indexPath.row].description
        cell.NewsDescription.isUserInteractionEnabled = false
        cell.NewsDescription.backgroundColor = UIColor(red:0.00, green:0.45, blue:0.74, alpha:1.0)
        cell.NewsDate.text = newsArray[indexPath.row].date
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let cell = tableView.cellForRow(at: indexPath) as? NewsCell {
            cell.NewsDescription.isUserInteractionEnabled = true
        }
        
        if let url = URL(string: newsArray[indexPath.row].link ?? "") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval)
    {
        self.tableView.reloadData()
    }
    
    func refresh() {
        refreshStart(refreshStop: {(x:Int) -> () in
            self.page = 1
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        })
    }
    
    func refreshStart(refreshStop:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            self.parser.startParsing()
            
            DispatchQueue.main.async {
                refreshStop(0)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if newsArray.count < limit*page {
            return
        }
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            infinityLoading() //imitation infinite scroll
        }
    }
    
    func parseSuccess(_ parser: Parser, didParseArray items: [News]) {
        newsArray = items
    }
    
    func infinityLoading() {
        if ( !loading ) {
            self.loading = true
            self.activityIndicator.startAnimating()
            self.tableView.tableFooterView?.isHidden = false
            infinityLoadingStart(infinityLoadingStop: { (x:Int) -> () in
                            self.tableView.reloadData()
                            self.loading = false
                            self.activityIndicator.stopAnimating()
                            self.tableView.tableFooterView?.isHidden = true
            })
        }
    }
    
    func infinityLoadingStart(infinityLoadingStop: @escaping (Int) -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            self.parser.startParsing()
            self.page += 1
            
            DispatchQueue.main.async {
                infinityLoadingStop(0)
            }
        }
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
