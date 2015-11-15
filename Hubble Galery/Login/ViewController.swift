//
//  ViewController.swift
//  Login
//
//  Created by Dusan Matejka on 10/16/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit
import Parse

class ViewController: UIViewController {
    let userName = "login"
    let userPassword = "password"
    let loggedNormal = "logedNormal"
    let tweetName = "tweetName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //-----------------------------------------############ GLOBAL ############----------------------------------------
    //Zisti ci je text prazdny
    private func jePrazdne(text : NSString)->Bool{
        return text == ""
    }
    
    //-----------------------------------------############ MENO ############----------------------------------------
    @IBOutlet private weak var imageMeno: UIImageView!
    @IBOutlet private weak var textMeno: UITextField!
    private let minimalnyPocetZnakovMeno = 3
    
    //Zmenil sa meno, skontroluj ci vyhovuje
    @IBAction private func zmeniloSaMeno(sender: AnyObject) {
        if(jePrazdne(textMeno.text!)){
            imageMeno.image = nil
        }else if (self.jeDobreMeno()){
            imageMeno.image = UIImage(named: "tick")
        }else{
            imageMeno.image = UIImage(named: "cross")
        }
    }
    //Kontrola mena
    private func jeDobreMeno()->Bool{
        if let obsah = textMeno.text{
            if (obsah.characters.count > minimalnyPocetZnakovMeno){
                return true;
            }
        }
        return false;
    }
    
    //-----------------------------------------############ MAIL ############----------------------------------------
    
    @IBOutlet private weak var imageMail: UIImageView!
    @IBOutlet private weak var textMail: UITextField!
    
    //Zmenil sa email, skontroluj ho
    @IBAction private func zmenilSaMail(sender: AnyObject) {
        if(jePrazdne(textMail.text!)){
            imageMail.image = nil
        }else if (self.skontrolujEmail()){
            imageMail.image = UIImage(named: "tick")
        }else{
            imageMail.image = UIImage(named: "cross")
        }
    }
    //Kontrola mailu
    private func skontrolujEmail()->Bool{
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(textMail.text)
    }
    
    //-----------------------------------------############ HESLO ############----------------------------------------
    
    @IBOutlet weak var textHeslo: UITextField!
    @IBOutlet weak var progresHeslo: UIProgressView!
    @IBOutlet weak var vysledokHodnoteniaHeslo: UILabel!
    private let pocetZnakovKratkeHeslo = 6
    private let pocetZnakovDlheHeslo = 12
    
    private let malePismenoTest = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[a-z]).+$")
    private let velkePismenoTest = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[A-Z]).+$")
    private let cisloTest = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[0-9]).+$")
    private let znakTest = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[-+_!@#$%^&*.,?]).+$")
    
    //Zmenilo sa heslo, treba skontrolovat heslo
    @IBAction private func zmeniloSaHeslo(sender: AnyObject) {
        zkontrolujOpakovaneHeslo()
        zkontrolujHeslo()
    }
    
    //Zkontroluje heslo
    private func zkontrolujHeslo()->Bool{
        if (jePrazdne(textHeslo.text!)){
            vysledokHodnoteniaHeslo.text = ""
            progresHeslo.hidden = true
            return false
        }else if (self.jeKratkeHeslo(textHeslo.text!)){
            progresHeslo.progress = 0.1
            progresHeslo.tintColor = UIColor.redColor()
            vysledokHodnoteniaHeslo.text = "Krátke"
            vysledokHodnoteniaHeslo.textColor = UIColor.redColor()
            progresHeslo.hidden = false
            return false
        }else{
            let obtiaznost = zistiObtiaznost()
            if (obtiaznost == 1){
                progresHeslo.hidden = false
                progresHeslo.progress = 0.3
                progresHeslo.tintColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
                vysledokHodnoteniaHeslo.text = "Veľmi slabé"
                vysledokHodnoteniaHeslo.textColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
            }else if (obtiaznost == 2){
                progresHeslo.progress = 0.5
                progresHeslo.tintColor = UIColor(red: 0.4, green: 0.0, blue: 0.0, alpha: 1.0)
                vysledokHodnoteniaHeslo.text = "Slabé"
                vysledokHodnoteniaHeslo.textColor = UIColor(red: 0.4, green: 0.0, blue: 0.0, alpha: 1.0)
            }else if(obtiaznost == 3){
                progresHeslo.progress = 0.7
                progresHeslo.tintColor = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
                vysledokHodnoteniaHeslo.text = "Dobré"
                vysledokHodnoteniaHeslo.textColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
            }else if (obtiaznost == 4){
                progresHeslo.progress = 0.85
                progresHeslo.tintColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
                vysledokHodnoteniaHeslo.text = "Veľmi dobré"
                vysledokHodnoteniaHeslo.textColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
            }else{
                progresHeslo.progress = 1
                progresHeslo.tintColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                vysledokHodnoteniaHeslo.text = "Výborné"
                vysledokHodnoteniaHeslo.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            }
            return true
        }
    }
    
    //Ak je heslo kratke, nepusti ho dalej
    private func jeKratkeHeslo(text : NSString)->Bool{
        return text.length < pocetZnakovKratkeHeslo;
    }
    
    //Zisti celkovu obtiaznost hesla, ak sa splni nejaka podmienka prirata sa jednotka k obtiaznosti
    private func zistiObtiaznost()->Int16{
        var obtiaznost : Int16 = 0
        obtiaznost += self.obsahujeMalePismeno()
        obtiaznost += self.obsahujeVelkePismeno()
        obtiaznost += self.obsahujeCisloPismeno()
        obtiaznost += self.obsahujeZnakPismeno()
        obtiaznost += self.jeDlheHeslo()
        return obtiaznost
    }
    //Zisti ci heslo obsahuje male pismeno
    private func obsahujeMalePismeno()->Int16{
        return malePismenoTest.evaluateWithObject(textHeslo.text) ? 1 : 0;
    }
    //Zisti ci heslo obsahuje velke pismeno
    private func obsahujeVelkePismeno()->Int16{
        return velkePismenoTest.evaluateWithObject(textHeslo.text) ? 1 : 0;
    }
    //Zisti ci heslo obsahuje cislo
    private func obsahujeCisloPismeno()->Int16{
        return cisloTest.evaluateWithObject(textHeslo.text) ? 1 : 0;
    }
    //Zisti ci heslo obsahuje specialny znak
    private func obsahujeZnakPismeno()->Int16{
        return znakTest.evaluateWithObject(textHeslo.text) ? 1 : 0;
    }
    //Zisti ci je heslo dlhe
    private func jeDlheHeslo()->Int16{
        return textHeslo.text?.characters.count > pocetZnakovDlheHeslo ? 1 : 0;
    }
    
    //-----------------------------------------############ OPAKOVANIE HESLA ############----------------------------------------
    @IBOutlet private weak var textHesloOpakovane: UITextField!
    @IBOutlet private weak var obrazokOpakovaneHeslo: UIImageView!
    
    @IBAction private func zmeniloSaOpakovaneHeslo(sender: AnyObject) {
        zkontrolujOpakovaneHeslo()
    }
    
    private func zkontrolujOpakovaneHeslo(){
        if (self.jePrazdne(self.textHesloOpakovane.text!)){
            obrazokOpakovaneHeslo.image = nil
        }else{
            if (jeFunkcneHeslo()){
                obrazokOpakovaneHeslo.image = UIImage(named: "tick")
            }else{
                obrazokOpakovaneHeslo.image = UIImage(named: "cross")
            }
        }
    }
    
    private func jeFunkcneHeslo()->Bool{
        if (jeKratkeHeslo(textHesloOpakovane.text!)){
            return false
        }else{
            if(textHesloOpakovane.text == textHeslo.text){
                return true
            }else{
                return false
            }
        }
    }
    
    //-----------------------------------------############ END EDITING ############----------------------------------------
    @IBAction func skriKlavesnicu(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //-----------------------------------------############ POSLI DATA ############----------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "prejdiNaLogin"){
            //Nothing to do
        }
    }
    @IBAction func signIn(sender: AnyObject) {
        if let presentingViewController = self.presentingViewController {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        } else {
            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(loginVC!, animated: true, completion: nil)
        }
    }
    
    @IBAction func zaregistruj(sender: UIButton) {
        if (jeDobreMeno()){
            if (skontrolujEmail()){
                if (jeFunkcneHeslo()){
                    
                    let user = PFUser()
                    user.username = self.textMeno.text
                    user.password = self.textHeslo.text
                    user.email = self.textMail.text
                    
                    user.signUpInBackgroundWithBlock {
                        (succeeded: Bool, error: NSError?) -> Void in
                        if let error = error {
                            let errorString = error.userInfo["error"] as? NSString
                            print(errorString)
                            let alert = UIAlertController(title: "Not Ok", message: "Taký uživateľ už existuje.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Pokračuj.", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            print("Registrovany")
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults.setObject(self.textMeno.text, forKey: self.userName)
                            defaults.setObject(self.textHeslo.text, forKey: self.userPassword)
                            let alert = UIAlertController(title: "Ok", message: "Váš účet bol vytvorený. Budete presmerovaný na login.", preferredStyle: UIAlertControllerStyle.Alert)
                            let callActionHandler = { (action:UIAlertAction!) -> Void in
                                self.performSegueWithIdentifier("prejdiNaLogin", sender: self);
                            }
                            alert.addAction(UIAlertAction(title: "Pokračuj", style: UIAlertActionStyle.Default, handler: callActionHandler))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }else{
                    if (!zkontrolujHeslo()){
                        let alert = UIAlertController(title: "Zlé heslo", message: "Heslo musí obsahodať aspoň 6 znakov.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Späť", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "Zlé opakované heslo", message: "Heslá sa musia zhodovať.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Späť", style: UIAlertActionStyle.Default, handler: nil))

                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }else{
                let alert = UIAlertController(title: "Zle zadaný mail", message: "Mail musí byť vo formáte priklad@priklad.priklad, len určité znaky sú povolené.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Späť", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "Zlé meno", message: "Uživateľské meno musí obsahodať aspoň 4 znaky.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Späť", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
   /* //-----------------------------------------############ VRAT SA SPAT ############----------------------------------------
    
    @IBAction func unwindNaRegistraciu(segue: UIStoryboardSegue) {
        
    }*/
}

