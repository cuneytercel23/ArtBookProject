//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Cüneyt Erçel on 1.08.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate { // 3.2 UIUIImagePickerControllerDelegate, UINavigationControllerDelegate EKLEDİK 3.1 BÖLÜMÜ İÇİN!!

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    
    
    @IBOutlet weak var artistText: UITextField!
    
    
    @IBOutlet weak var yearText: UITextField!
    //9 + YA BASARSAK NORMAL HALİ , TABLEVİEW BASARSAK İSTEDİĞİMİZ ID İLE NAME ALARAK, DOLU HALİNİ GÖNDERME YANİ VERİ AKTARIMI MEVZUSU- En başta isim atıyoruz buraya choosenview controllera selected diye
   var choosenPainting = ""
    var choosenPaintingId : UUID?
    
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //9.1 eğer chosen painting boşşa + ya basmış gibi gönderip değilse, tableviewdan bastığımızı yapma için if ve else açtık içi boş 9.5 de dolduracağız
        
        // 9.5 - aslında 9.1 de sadece if else açtık, else i doldurduk şimdi ifi doldurcaz
        if choosenPainting != "" {
            //11 savebutton saklama ve tıklanabilir yapma önce outlet olarak storyboarddan ekledik.
            //şimdi eğer eşit değilse hidden yapcaz.
            // else kısmına gidip hidden false, enabled false yapcaz yani görünür olsun ama tıklanmasın.
            //imagepicker kontrol yerinde resim seçildikten sonra enable olsun istiyoruz. o yüzden orada enable true dicez bitiyor.
            saveButton.isHidden = true

            
            
            //Core Data, yani tableviewa bastığımda olan şey.
            //9.5 Aslında 6 da olan mevzu ile aynı o yüzden acıklama pek yazmıcam.
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            let idString = choosenPaintingId?.uuidString// bu ve aşağısı idleri atama yeri
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)// burası işte id yapma olayı gibi bişi
            
            
            do {
                let results = try context.fetch(fetchRequest)
                  if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    nameText.text = name
                    
                }
                if let artist = result.value(forKey: "artist") as? String {
                    artistText.text = artist }
                
                if let year = result.value(forKey: "year") as? Int {
                    yearText.text = String(year)
                }
                
                if let imageData = result.value(forKey: "image") as? Data {
                    
                    let image = UIImage(data: imageData)
                    imageView.image = image
                }
                
            }
                  }
        
            }catch {
                print("eror")
            }
            
        }else  { // eğer boşsa + ya bastığımdaki gibi olsun hesabı.
            
            saveButton.isHidden = false  // 11.2
            saveButton.isEnabled = false// 11.2
            nameText.text = ""
            yearText.text = ""
            artistText.text = ""
            
            
            
            
        }
        
        
    
        
        
        
        
        

        //2 -gesture recognizer oluşturma klavyeden kurtulmak için -
        // isim verdim eşittir tapgesturer... sonra target self actiona da selector açtım ki objc fonksiyonu yazabileyim ve view.addgesturer.. yazan kısımda ise ekranın herhangi bi yerine basınca, kaldırmasını emrettim. oraya mesela resim falan filan koyabiliyoruz.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)// ekranın bir kısmına dokununca kaldır istiyorum burada.
        
        
        // 3-RESİME TIKLAYINCA GALERİ AÇILMASI MEVZUATI
        //İlk satırda resime kullanıcı dokunabilir mi yes dedik, daha sonra altta UITapGestureRecognizer tanımladık. 3.1 de de fonksiyonu açıp selector kısmını doldurduk.
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        
        
        
        
    }
    // 2.1 view içinde endEditing yaptım endEditing o alan içinde yaptığın değişiklikleri bitiriyor bizimde değişikliğimiz klavye cıkması zaten
    @objc func hideKeyboard() {
        
        view.endEditing(true)
    }
    
// bunu storyboardla yaptık
    @IBAction func saveButtonClicked(_ sender: Any) {
        // 4 VERİYİ SAKLAMA İLK BÖLÜMLER AŞIRI KARMAŞIK ANLAMADIK DEVAMINDA DA Entity yaptığımız kısımları tanıtıyoruz. AYRICA CORE DATA İMPORTLUYORUZ BU BÖLÜMDE YUKARDA
        //İLK 2 KOD EZBER
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // bunu yaparak app delegatei değişken olarak tanımlamış olduk.
        let context = appDelegate.persistentContainer.viewContext // bunu da yaparak supporting contextleri kullanabilir hale gelmişiz supcontext = do try catch aşağıda görcez.
        
        // 4.1 entiti tanımlama
        
        // NSEntitydescription yazarak Entitylerdeki paintings yazdığım yere ulaştım daha sonra .insertnewobjects yazarak entity ismim paintingsdi onu yazdım. into da bana kaydedebileceğim bişi ver diyo bende context yapmıştım yukarda onun içiin onu verdim.
        
       let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        
        // 4.2 entity içindeki setleri ayarlama kısmı attributes diye geçiyor (name artist year falan) - .setvalue kullanarak yapıyoruz.
        
        newPainting.setValue(nameText.text!, forKey: "name")// name kısmı

        newPainting.setValue(artistText.text!, forKey: "artist") // artist kısımı
        
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        } // kullanıcı saçma sapan bişi girmesin diye iflet yaptık bunu
        
        newPainting.setValue(UUID(), forKey: "id") // id için UUID yazıyoruz sol kısma
        
        // burada resimi dataya çevirme işlemini yaptık, .jpegdata yazarak resim yerini veriye çevirebiliyoruz. compression quaility dediği de sıkıştırma yüzde 50 sıkıştır dedimki mb si biraz azalsın.
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        // 4.3 do try catch olayı yap dene hata varsa yakala, Context.save yaparak üstte yaptıklarımızı kaydettik. yani bir foto, isim artist falan bunları yazdığımızda bizim için context kısmına kaydetecek. do try catch olayıda şimdilik ezber
        
        
        do {
            try context.save()
            print("succes")
            
        } catch {
            print("error")
        }
        // 4.4 BU 4 ve küsüratları KOMPLE BİTİRİNCE foto seçip yazıları yazıp contexte kaydetmiş olabiliyoruz deneme için de succes yazdırdık. Ama kaydettiğimiz yerlere nerden bakıcam şuan anlatılmadı.
        
            // 7 - 6 yı bitirdik kaydedince, bişi olmuyor hiçbir animasyon vesayre, ayrıca backe basınca o an kaydedilimiş gözükmüyor çıkıp girmemiz lazım. BURADA ONU DÜZELTECEĞİZ VE KAYDETE BASINCA DİREK TABLEVİEWA ATACAK BİZİ ANLADIĞIM BİR BÖLÜM!!
        
        
        //7.1BİLDİRİM MEVZUATI - burada  bildirim merkezi oluşturduk ve newdata diye isim verdik şimdi view controllara yani ilk sayfaya gidicez ve observer oluşturucaz o observer newdata bildirimini alınca bi kere daha yaptığımız getdatayı calısıtrıcak ve böylece orada direkt gözükücek.
        
        // yani 7.3 view controllerda
        // burada name kısmına NSNotification.Name (rawValue: "newData") BUNLARIN HEPSİNİ BİZ YAZIYORUZ OTO GELMİYOR
        NotificationCenter.default.post(name:NSNotification.Name (rawValue: "newData"), object: nil)
        
        
        //7.2 -KAYDETE BASINCA Bİ GERİ SAYFAYA DÖNME- save sonuna yaptık, save bitince bunu yapacak
        self.navigationController?.popViewController(animated: true)
    
        
    }
    
    
    // 3.1 Burada pickerı tanımladık, delege ettik(zor ama şartmış), sourcetype verdik, editlemye izin verdik en sonda da present diye sunduk kullanıcıya, alert kullanırken de present kullanıyoruz btw. VE BUNLARI YAPARKEN AYNI TABLEVİEWDA OLDUĞU GİBİ EN ÜSTE GİDİP UIImagePickerControllerDelegate, UINavigationControllerDelegate EKLEMESİ YAPMAK ZORUNDAYIZ. YOKSA HATA VERİYOR
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary // Kaynak tipi diye seçiyoruz ve karşımıza 3 çeşit geliyor biri galeri yani seçtiğim diğeri kamera, diğeride saved photo albüm.
        picker.allowsEditing = true // bunu vermesek de olurdu foto üzerinde edit yapma izini verdik.
        present(picker, animated: true, completion: nil)
        
    }
    
    //3.3 DİDFİNİSHPİCKİNG İLE RESİM SEÇİLDEKTEN SONRA KAPAMA
    // burda didfinish yazıoyurz gelene tıklıyoruz. ilk gelen kodun son kısmında infokey alanı var orası dictonary imiş yani oradan seçili olan bir şey seçicez biz oroginalresimi seçiyoruz en cok tercih edildiği için, daha sonra ilk kodda any diye geçiyor info key onu UIImage diye cast ediyoruz.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage // info kısmı dictionary diye [] bunu açıp seçtik, original image dışında livephoto vb bir kaç şey daha var.
        
        saveButton.isEnabled = true // 11.3
        self.dismiss(animated: true, completion: nil) // bunu da yaparak kapatmış oluyorum.
        
    }
    
    
    
    
    

}
