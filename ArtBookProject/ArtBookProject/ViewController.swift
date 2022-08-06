//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Cüneyt Erçel on 1.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{ // 5.2 i yaparken bunları koyuyoruz mecbur

    
    @IBOutlet weak var tableView: UITableView!
   var nameArray = [String]() //6.1
   var idArray = [UUID]()
    
    // 9.2 selectedlar
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // 1 - İLK SAYFA SAĞ ÜSTE KOD İLE BUTON EKLEME-
        // İlk navlı yerlerde konumunu belirtip oraya barbutonu koyduk. Parantez açıp systemitem olanı seçtik ve nokta koyduktan sonra done,plus gibi bazı şekiller belirdi hoca plus yaptı ben done yaptım sonra action kısmına selector verip aşağıda da objektifc fonksiyonu açtık
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        // 5 TABLE VİEW OLUŞTURMALARI
        
        tableView.delegate = self
        tableView.dataSource = self
        
      
    getData() // 6.7 fonksiyon dışında calıstrmak için bunu yazdık
        // 7.4 ile bunu objc ye cevirdik 6.6 da getData() idi.
        
        
      
    }
    
    // 7.3 OBSERVER OLUŞTURMA- 7.2 DE ANLATTIĞIMI BURDA YAPICAM FAKAT viewdidloada yapmadım çünkü o sadece bi kere çağırılıyor. o yüzden buraya yapıyoruz
    override func viewWillAppear(_ animated: Bool) {
        
        
        // NSNotification.Name (rawValue: "newData" Kısmını elle yazıyoruz normalde sadece name veriyor.
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name:NSNotification.Name (rawValue: "newData"), object: nil)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    //6 VERİ ÇEKMEK-ÖNCE ÜSTTE nameArray ve idArray tanımladık 6.1 dite yazcam onu ve import coredata yaptık
    
    @objc func getData() {  // 7.4 ile bunu objc ye cevirdik 6yı yaparken getData() idi.
        
        
        
        // 8 DUBLİKE OLANLARI KALDIRMA- yediyi bitirdikten sonra kaydedince çifter çifter ediyodu, yani mesela şelale ve kitap kaydettim önceden, sonradan da elma kaydedince bu üçü olması lazım, ama hepsinin kopyası oluyodu, BUNUN İÇİNDE EZBER KOD YAPIYORUZ.
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        
        
        
        
        
        
        // 6.1,5 dördüncü bölümde yaptığımız gibi appdelegati tanımlıcam yani ilk 2 kod ezber gene
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // 6.2 FETCHREQUEST = GİDİP GETİRMEK - DATAYI TUTUP ÇEKME İŞLEMİ YAPIYORUZ BURASIDA EZBER FAKAT entitynamemiz entitleride yaptığımız paintingi yazdık.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        fetchRequest.returnsObjectsAsFaults = false // bu büyük projelerde önemliymiş, hızı arttırıyomuş cokomelli değil yapmasakda olur.
        
        //6.3 Context.fetch yapıyoruz ama hata gelebilir dediği için do try catch içinde yapmalıyız
        
        do {
          let results = try context.fetch(fetchRequest)
            if results.count > 0 {
            // 6.4Anlayamadım valla ama result kısmını yaparken nsmanagement object yaptık çünkü results kısmından normal any,string,yadaint falan gelir ya, results kısmından nsmanagemedresults geliyodu o yüzden bizde resultu nsmanagedobject diye atadık yoksa any geliyodu.
            //6.5
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    self.idArray.append(id)
                }
            }
            
            // 6.6 kaydetme yaptıktan sonra refresh yapma
            self.tableView.reloadData()
            }
        }catch{
            print("error")
    }
    
        
    }
    
    
    
    
    
    // 1.2 Obj fonksiyonu ile performsegue yani diğer sayfaya geç yaptık
    @objc func addButtonClicked() {
        selectedPainting = "" // 9.3.1 gibi bişi burada addbutona basınca seçilmemiş sayfa gelsin istiyorum
        performSegue(withIdentifier: "toDetailsVC", sender: nil )
    }
    
    // 5.1 table view fonkları
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    
    //9.3 Didselectrow ve prepareforsegue oluşturuyoruz.  ALTTAKİ TABLEVİEW KISMI İÇİN =Add button clicked kısmına(YUKARDA) basınca yani artıya orayı selectedpaintingi boş yapıyoruz(9.3.1 de yaptım). burada(aşağıdaki didselctrow) selectedpaintingi name ve id arreye bağlıyoruz ki basıldığı zaman oradaki dataları çekebilelim hesabı.
    
    // prepare for segue burada kafama oturdu diyebilirim. ŞİMDİ BURADA EN BAŞTA DİYORUZKİ EĞER SEGUENİN İDENTİFARI DETAİLSVC İSE, BANA destinationVC diye bişi tanımla ve bu 2.sayfadaki yani detailsvcdeki şeylere erişebilsin. en sonda da destinationVC yazarak erişmiş oluyoruz nokta koyarak oradaki choosenpaintigi buradaki selectedpaintige eşitliyoruz ve burdan sonra 9.5 e geçiyoruz (details sayfasında 9.1 in orası).
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.choosenPainting = selectedPainting
            destinationVC.choosenPaintingId = selectedPaintingId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    
    // 10 table view sağa kaydırarak silme- GENE 9.5 İLE 6 NIN AYNISI DİYE ACIKLAMICAM
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        let idString = idArray[indexPath.row].uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        
        do {
            
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    
                    if let id = result.value(forKey: "id") as? UUID {
                    if id == idArray[indexPath.row] {
                        context.delete(result)
                        nameArray.remove(at: indexPath.row)
                        idArray.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        
                        do{
                            try context.save()
                            
                        }catch {
                            print( "erororoeos")
                        }
                        break
                    }
                    
                    
                    
                }
            }
        }
        }catch {
            
            
            
            
            print("ofofofofof")
            
        }
    }
}

}
