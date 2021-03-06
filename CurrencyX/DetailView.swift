//
//  DetailView.swift
//  CurrencyX
//
//  Created by Kha on 11/1/17.
//  Copyright © 2017 Team 5. All rights reserved.
//


import Foundation
import UIKit
import Charts
import FirebaseDatabase
import Firebase
import FirebaseAuth


class infos : NSObject {
    var Amount: String?
    var Cost : String?
    var TotalPrice : String?
    var date : String?
    var type : String?
    
    override init()
    {
        Cost = ""
        Amount = ""
        TotalPrice = ""
        date = ""
        type = ""
    }
    init(amount1: String, cost1: String, totalprice : String, data1 : String, type1 : String){
        Amount = amount1
        Cost = cost1
        TotalPrice = totalprice
        date = data1
        type = type1
    }
    init(data : Dictionary<String, String>)
    {
        if let amount = data["Amount"] as? String {
            self.Amount = amount
        }
        if let date = data["data"] as? String {
            self.date = date
        }
        if let cost = data["Cost"] as? String {
            self.Cost = cost
        }
        if let totalprice = data["TotalPrice"] as? String {
            self.TotalPrice = totalprice
        }
        if let type1 = data["Type"] as? String {
            self.type = type1
        }
        
    }
}
// struct for cryptoPrices
struct dailyCryptoPrices : Codable
{
    private enum CodingKeys: String, CodingKey {
        case Response
        case _type = "Type"
        case Aggregated
        case Data
        case TimeTo
        case TimeFrom
        case FirstValueInArray
        case ConversionType
        
    }
    
    let Response : String
    let _type : Int
    let Aggregated : Bool
    let Data : [data]
    let TimeTo : Double
    let TimeFrom : Double
    let FirstValueInArray : Bool
    let ConversionType : convType
    
    
    struct data : Codable
    {
        let time : Double
        let close : Double
        let high : Double
        let low : Double
        let open : Double
        let volumefrom : Double
        let volumeto : Double
        init()
        {
            time = 0
            close = 0.0
            high = 0.0
            low = 0.0
            open = 0.0
            volumefrom = 0.0
            volumeto = 0.0
        }
    }
    
    init()
    {
        Response = ""
        _type = 0
        
        Aggregated = false
        Data = [data]()
        TimeTo  = 0.0
        TimeFrom = 0.0
        FirstValueInArray = true
        ConversionType = convType()
        
        
    }
    struct convType : Codable
    {
        let type : String
        let conversionSymbol : String
        init()
        {
            type = ""
            conversionSymbol = ""
        }
    }
}


class DetailView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    /********************************
     TableView Functions
     **************************************/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("asdjasd \(numOfInfo)")
        return numOfInfo
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell")
        
        let dateLbl = cell?.contentView.viewWithTag(1) as! UILabel
        let typeLbl = cell?.contentView.viewWithTag(2) as! UILabel
        let totalAmountLbl = cell?.contentView.viewWithTag(3) as! UILabel
        let amountLvb = cell?.contentView.viewWithTag(4) as! UILabel
        dateLbl.text = Information[indexPath.row].date
        typeLbl.text = Information[indexPath.row].type
        totalAmountLbl.text = Information[indexPath.row].TotalPrice
        amountLvb.text = "\(Information[indexPath.row].Amount!) shares at \(Information[indexPath.row].Cost!)/share"
        
        return cell!
        
    }
    
    
    // daily cryptocurrencies urls
    var dailyCryptoUrls : [String: String] = ["Bitcoin" : "https://min-api.cryptocompare.com/data/histohour?fsym=BTC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ethereum" : "https://min-api.cryptocompare.com/data/histohour?fsym=ETH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Bitcoin Cash" : "https://min-api.cryptocompare.com/data/histohour?fsym=BCH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ripple" : "https://min-api.cryptocompare.com/data/histohour?fsym=XRP&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Dash" : "https://min-api.cryptocompare.com/data/histohour?fsym=DASH&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Litecoin" : "https://min-api.cryptocompare.com/data/histohour?fsym=LTC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Bitcoin Gold" : "https://min-api.cryptocompare.com/data/histohour?fsym=BTG&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "IOTA" : "https://min-api.cryptocompare.com/data/histohour?fsym=IOTA&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Cardano" : "https://min-api.cryptocompare.com/data/histohour?fsym=ADA&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Monero" : "https://min-api.cryptocompare.com/data/histohour?fsym=XMR&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Ethereum Classic" : "https://min-api.cryptocompare.com/data/histohour?fsym=ETC&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "NEO" : "https://min-api.cryptocompare.com/data/histohour?fsym=NEO&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "NEM"  : "https://min-api.cryptocompare.com/data/histohour?fsym=XEM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "EOS" : "https://min-api.cryptocompare.com/data/histohour?fsym=EOS&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Stellar Lumens" : "https://min-api.cryptocompare.com/data/histohour?fsym=XLM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "BitConnect" : "https://min-api.cryptocompare.com/data/histohour?fsym=BCCOIN&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "OmiseGO" : "https://min-api.cryptocompare.com/data/histohour?fsym=OMG&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Qtum" : "https://min-api.cryptocompare.com/data/histohour?fsym=QTUM&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Lisk" : "https://min-api.cryptocompare.com/data/histohour?fsym=LSK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "Zcash" : "https://min-api.cryptocompare.com/data/histohour?fsym=ZEC&tsym=USD&limit=24&aggregate=3&e=CCCAGG"]
    
    //weekly cryptocurrencies urls
    var weeklyCryptoUrls : [String: String] = ["Bitcoin" : "https://min-api.cryptocompare.com/data/histoday?fsym=BTC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ethereum" : "https://min-api.cryptocompare.com/data/histoday?fsym=ETH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Bitcoin Cash" : "https://min-api.cryptocompare.com/data/histoday?fsym=BCH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ripple" : "https://min-api.cryptocompare.com/data/histoday?fsym=XRP&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Dash" : "https://min-api.cryptocompare.com/data/histoday?fsym=DASH&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Litecoin" : "https://min-api.cryptocompare.com/data/histoday?fsym=LTC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Bitcoin Gold" : "https://min-api.cryptocompare.com/data/histoday?fsym=BTG&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "IOTA" : "https://min-api.cryptocompare.com/data/histoday?fsym=IOTA&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Cardano" : "https://min-api.cryptocompare.com/data/histoday?fsym=ADA&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Monero" : "https://min-api.cryptocompare.com/data/histoday?fsym=XMR&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Ethereum Classic" : "https://min-api.cryptocompare.com/data/histoday?fsym=ETC&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "NEO" : "https://min-api.cryptocompare.com/data/histoday?fsym=NEO&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "NEM"  : "https://min-api.cryptocompare.com/data/histoday?fsym=XEM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "EOS" : "https://min-api.cryptocompare.com/data/histoday?fsym=EOS&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Stellar Lumens" : "https://min-api.cryptocompare.com/data/histoday?fsym=XLM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "BitConnect" : "https://min-api.cryptocompare.com/data/histoday?fsym=BCCOIN&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "OmiseGO" : "https://min-api.cryptocompare.com/data/histoday?fsym=OMG&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Qtum" : "https://min-api.cryptocompare.com/data/histoday?fsym=QTUM&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Lisk" : "https://min-api.cryptocompare.com/data/histoday?fsym=LSK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "Zcash" : "https://min-api.cryptocompare.com/data/histoday?fsym=ZEC&tsym=USD&limit=7&aggregate=3&e=CCCAGG"]
    
    //currency daily urls : Order : JPY, CHF, CAD, SEK, NOK, MXN, ZAR, TRY, CNH, EUR, GBP, AUD, NZD
    var dailyCurrencyUrls : [String : String] = ["USDJPY" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=JPY&limit=24&aggregate=3&e=CCCAGG", "USDCHF" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=CHF&limit=24&aggregate=3&e=CCCAGG", "USDCAD" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=CAD&limit=24&aggregate=3&e=CCCAGG", "USDSEK" : "https://min-api.cryptocompare.com/data/histohour?fsym=SEK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDNOK" : "https://min-api.cryptocompare.com/data/histohour?fsym=NOK&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDMXN" : "https://min-api.cryptocompare.com/data/histohour?fsym=MXN&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDZAR" : "https://min-api.cryptocompare.com/data/histohour?fsym=ZAR&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDTRY" : "https://min-api.cryptocompare.com/data/histohour?fsym=TRY&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDCNH" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=CNH&limit=24&aggregate=3&e=CCCAGG", "USDEUR" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=EUR&limit=24&aggregate=3&e=CCCAGG", "USDGBP" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=GBP&limit=24&aggregate=3&e=CCCAGG", "USDAUD" : "https://min-api.cryptocompare.com/data/histohour?fsym=AUD&tsym=USD&limit=24&aggregate=3&e=CCCAGG", "USDNZD" : "https://min-api.cryptocompare.com/data/histohour?fsym=NZD&tsym=USD&limit=24&aggregate=3&e=CCCAGG"]
    
    //currency weekly urls : Order : JPY, CHF, CAD, SEK, NOK, MXN, ZAR, TRY, CNH, EUR, GBP, AUD, NZD
    var weeklyCurrencyUrls : [String: String] = ["USDJPY" : "https://min-api.cryptocompare.com/data/histohour?fsym=USD&tsym=JPY&limit=7&aggregate=3&e=CCCAGG", "USDCHF" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=CHF&limit=7&aggregate=3&e=CCCAGG", "USDCAD" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=CAD&limit=7&aggregate=3&e=CCCAGG", "USDSEK" : "https://min-api.cryptocompare.com/data/histoday?fsym=SEK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDNOK" : "https://min-api.cryptocompare.com/data/histoday?fsym=NOK&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDMXN" : "https://min-api.cryptocompare.com/data/histoday?fsym=MXN&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDZAR" : "https://min-api.cryptocompare.com/data/histoday?fsym=ZAR&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDTRY" : "https://min-api.cryptocompare.com/data/histoday?fsym=TRY&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDCNH" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=CNH&limit=7&aggregate=3&e=CCCAGG", "USDEUR" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=EUR&limit=7&aggregate=3&e=CCCAGG", "USDGBP" : "https://min-api.cryptocompare.com/data/histoday?fsym=USD&tsym=GBP&limit=7&aggregate=3&e=CCCAGG", "USDAUD" : "https://min-api.cryptocompare.com/data/histoday?fsym=AUD&tsym=USD&limit=7&aggregate=3&e=CCCAGG", "USDNZD" : "https://min-api.cryptocompare.com/data/histoday?fsym=NZD&tsym=USD&limit=7&aggregate=3&e=CCCAGG"]
    
    
    
    //  Create variable to set background image
    var backgroundImage = UIImage()
    var backgroundImageView = UIImageView()
    var backgroundImageName = ""
    
    //  var urls : String = [""]
    var dailyCryptoData = dailyCryptoPrices()
    var cPriceList =  [Double]()
    // Variable Initialize
    var cryptCurrency = CryptoCurrency()
    var regCurrency = currency()
    var ref: DatabaseReference!
    var currencyName : String = ""
    var amountTxt = String()
    
    var numOfInfo : Int = 0
    var Information = [infos]()
    static var amount : String = ""
    let userID = Auth.auth().currentUser?.uid
    @IBOutlet var mainView: UIView!
    
    //dates variable
    let hh2 = (Calendar.current.component(.hour, from: Date()))
    let mm2 = (Calendar.current.component(.minute, from: Date()))
    let ss2 = (Calendar.current.component(.second, from: Date()))
    let day = (Calendar.current.component(.day, from: Date()))
    let month = (Calendar.current.component(.month, from: Date()))
    let year = (Calendar.current.component(.year, from: Date()))
    
    
    //firebase
    var refPrice: DatabaseReference!
    var user = Auth.auth().currentUser
    // UI variable initialize
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0
        {
            if(MainView.isCryptoSelect == true)
            {
                
                
                readAmount()
                getCryptoData(arrayUrl: dailyCryptoUrls, name: cryptCurrency.name)
                updateCryptoChart()
            }
            else
            {
                readAmount()
                displayCurrency()
                getCryptoData(arrayUrl: dailyCurrencyUrls, name: regCurrency.symbol)
                updateCryptoChart()
                
            }
        }
        else if sender.selectedSegmentIndex == 1
        {
            if(MainView.isCryptoSelect == true)
            {
                readAmount()
                readInfo()
                getCryptoData(arrayUrl: weeklyCryptoUrls, name: cryptCurrency.name)
                updateCryptoChart()
            }
            else
            {
                readAmount()
                readInfo()
                displayCurrency()
                getCryptoData(arrayUrl: weeklyCurrencyUrls, name: regCurrency.symbol)
                updateCryptoChart()
            }
            
        }
        
    }
    //table view cell variables
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var buyButtonHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var buyButtonWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var fromCurrencyLbl: UILabel!
    @IBOutlet weak var toCurrencyLbl: UILabel!
    @IBOutlet weak var fromCurrAmount: UILabel!
    @IBOutlet weak var toCurrAmount: UILabel!
    
    @IBAction func sellButton(_ sender: Any) {
        performSegue(withIdentifier: "DetailToSell", sender: self)
    }
    
    @IBAction func buyButton(_ sender: Any) {
        performSegue(withIdentifier: "DetailToBuy", sender: self)
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //add notification button in navigation bar
        let notificationButton = UIButton(type: .custom)
        notificationButton.setImage(UIImage(named: "notificationBell"), for: .normal)
        notificationButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        notificationButton.addTarget(self, action: #selector(NotificationButton), for: .touchDown)//
        let btn = UIBarButtonItem(customView: notificationButton)
        self.navigationItem.setRightBarButton(btn, animated: true)
        
    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        backgroundImageName = "background6.png"
        setBackgroundImage()
        
        TableView.delegate = self
        TableView.dataSource = self
        
        if(MainView.isCryptoSelect == true)
        {
            currencyName = cryptCurrency.name
            readAmount()
            readInfo()
            
            getCryptoData(arrayUrl: dailyCryptoUrls, name: cryptCurrency.name)
            updateCryptoChart()
            displayCrypto()
        }
        else
        {
            currencyName = regCurrency.symbol
            readAmount()
            readInfo()
            displayCurrency()
            getCryptoData(arrayUrl: dailyCurrencyUrls, name: regCurrency.symbol)
            updateCryptoChart()
        }
        
        _ = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(DetailView.refresh), userInfo: nil, repeats: true)
        
        //reload crypto chart
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(DetailView.updateCryptoChart), userInfo: nil, repeats: true)
        //read firebase continously
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DetailView.readAmount), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DetailView.readInfo), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()

        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)

        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backgroundImageName = "background6.png"
        setBackgroundImage()
        AppUtility.lockOrientation(.portrait)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
        //  AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    //notification button function
    @objc func NotificationButton()
    {
        performSegue(withIdentifier: "DetailToNotification", sender: self)
        
    }
    
    /**********************************
     Search function - returns url
     **********************************/
    func getUrl(urlname : String, arrayUrl : [String : String]) -> String
    {
        for (key, value) in arrayUrl
        {
            if (urlname == key)
            {
                return value
            }
        }
        return ""
    }
    /**********************************
     Load JSON function
     **********************************/
    func getCryptoData(arrayUrl : [String : String], name : String)
    {
        let urlString = getUrl(urlname: name, arrayUrl: arrayUrl )
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
            
            if let data = data {
                do{
                    self.cPriceList.removeAll()
                    
                    let jsonDecoder = JSONDecoder()
                    self.dailyCryptoData = try jsonDecoder.decode(dailyCryptoPrices.self , from: data)
                    DispatchQueue.main.async {
                        
                    }
                }
                catch {
                    print("Can't pull JSON")
                }
                self.addCryptoPrices()
            }
        }
        task.resume()
    }
    /**********************************
     Add points to graph function
     **********************************/
    func addCryptoPrices()
    {
        for i in dailyCryptoData.Data
        {
            cPriceList.append(i.open )
            
        }
    }
    /**********************************
     Display graph function
     **********************************/
    @objc  func updateCryptoChart()
    {
        
        //array displays on the graph
        var lineChartEntry = [ChartDataEntry]()
        var b = 0
        //hourly time
        let now = Date()
        //let hourlyArray = [String]
        var components = DateComponents()
        components.hour = -1
        let oneHourAgo = Calendar.current.date(byAdding: components, to: now)
        //loop
        for i in cPriceList
        {
            
            
            let value = ChartDataEntry(x: Double(b), y: i ) //set x and yc
            b = b + 1
            lineChartEntry.append(value)//add info to chart
        }
        self.lineChart.reloadInputViews()
        self.lineChart.pin(to: lineChart)
        self.lineChart.notifyDataSetChanged()
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Price") //convert lineChartEntry to a LineChartDataSet
        
        line1.colors = [NSUIColor.red]  //sets color to blue
        
        let data = LineChartData() //this is the object that will be added to the chart
        
        data.addDataSet(line1) //adds the line to the dataset
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        self.lineChart.legend.enabled = false
        self.lineChart.data = data
        
        self.lineChart.lineData?.setDrawValues(false)
        self.lineChart.borderColor = NSUIColor.cyan
        //self.lineChart.lineData?.se
        self.lineChart.backgroundColor = NSUIColor.clear
        self.lineChart.chartDescription?.enabled = false //set title for the graph
        self.lineChart.invalidateIntrinsicContentSize()
        
    }
    /**********************************************
     Read From Firebase Functions
     **********************************************/
    @objc func readInfo()
    {
        self.Information = [infos]()
        ref = Database.database().reference().child("Information").child((user?.uid)!).child(currencyName)//.childByAutoId()
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.numOfInfo = Int(snapshot.childrenCount)
            print("asdljasdh \(self.numOfInfo)")
            for snap in snapshot.children {
                if let valueDictionary = (snap as! DataSnapshot).value as? [String:String]
                {
                    
                    let type = valueDictionary["Type"]
                    let amount = valueDictionary["Amount"]
                    let cost = valueDictionary["Cost"]
                    let totalamount = valueDictionary["TotalPrice"]
                    let date = valueDictionary["data: "]
                    self.Information.insert(infos(amount1: amount!, cost1: cost!, totalprice : totalamount!, data1 : date!, type1 : type!), at: 0)
                }
                DispatchQueue.main.async {
                    self.TableView.reloadData()
                }
            }
        })
        TableView.delegate = self
        TableView.dataSource = self
    }
    @objc func readAmount()
    {
        ref = Database.database().reference().child("Amount").child(userID!).child(currencyName)
        ref.keepSynced(true) // keeps reading firebase
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                if let value = snapshot.value as? NSDictionary {
                    for snapDict in value {
                        DetailView.amount = snapDict.value as! String //save number to be use in the buy/sell view
                        print(DetailView.amount)
                    }
                    
                }
            }
                //if firebase doesn't have a value, the sell button is hidden
            else {
                DetailView.amount = "0"
                self.sellButton.isHidden = true
                //  self.buyButton.addTarget(self, action: #selector(self.buyButtonFunction), for: UIControlEvents.touchUpInside)
                
                self.buyButton.frame.size = CGSize(width: 140.0, height: 40.0)
                self.buyButton.frame.origin.x = 60
                self.buyButton.frame.origin.y = 10
                
                
            }
        })
    }
    @objc func refresh(){
        
        if(MainView.isCryptoSelect == true)
        {
            displayCrypto()
        }
        else
        {
            displayCurrency()
        }
    }
    func setBackgroundImage() {
        if backgroundImageName > "" {
            backgroundImageView.removeFromSuperview()
            backgroundImage = UIImage(named: backgroundImageName)!
            backgroundImageView = UIImageView(frame: self.mainView.bounds)
            backgroundImageView.image = backgroundImage
            self.mainView.addSubview(backgroundImageView)
            self.mainView.sendSubview(toBack: backgroundImageView)
        }
    }
    
    // detect device orientation changes
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if UIDevice.current.orientation.isLandscape {
            print("rotated device to landscape")
            setBackgroundImage()
        } else {
            print("rotated device to portrait")
            setBackgroundImage()
        }
    }
    
    
    /**********************************
     Display textfield functions
     **********************************/
    func displayCrypto()
    {
        fromCurrencyLbl.text = cryptCurrency.name
        toCurrencyLbl.text = "USD"
        fromCurrAmount.text = "1"
        toCurrAmount.text = String(cryptCurrency.price_usd)
        
    }
    func displayCurrency()
    {
        fromCurrencyLbl.text = String(regCurrency.symbol.characters.prefix(3))
        toCurrencyLbl.text = String(regCurrency.symbol.characters.suffix(3))
        fromCurrAmount.text = "1"
        toCurrAmount.text = String(regCurrency.price)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func buyButtonFunction()
    {
        performSegue(withIdentifier: "DetailToBuy", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "DetailToBuy")
        {
            let passToBuy = segue.destination as! BuyView
            if(MainView.isCryptoSelect)
            {
                passToBuy.buyCryptoData = cryptCurrency
            }else if (MainView.isCurrencySelect){
                passToBuy.buyRegularData = regCurrency
            }
        }else if (segue.identifier == "DetailToSell"){
            let passToSell = segue.destination as! SellView
            if(MainView.isCryptoSelect)
            {
                passToSell.sellCryptoData = cryptCurrency
            }else if (MainView.isCurrencySelect){
                passToSell.sellRegularData = regCurrency
            }
        }
    }
    //lock rotation
    
    
    
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
//lock screen struct
struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}

