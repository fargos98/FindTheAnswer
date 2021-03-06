//
//  SpellingView.swift
//  FindTheAnswer
//
//  Created by Mario Alvarado on 6/14/20.
//  Copyright © 2020 Mario Alvarado. All rights reserved.
//

import SwiftUI

struct Response: Codable{
    var id: Int
    var word: String
}

struct DefaultTextStyle: ViewModifier {
    func body(content: Content) ->some View{
        content
            .font(.system(size: 25))
    }
}

struct TitleTextStyle: ViewModifier {
    func body(content: Content) ->some View{
        content
            .font(.system(size: 40, weight: .heavy))
            .foregroundColor(Color.blue)
    }
}

struct BigTextStyle: ViewModifier {
    func body(content: Content) ->some View{
        content
            .font(.system(size: 35, weight: .heavy))
            .foregroundColor(Color.red)
    }
}

extension Text{
    func textStyle<Style: ViewModifier>(_ style:Style)-> some View{
        ModifiedContent(content: self, modifier: style)
    }
}

struct InfoButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .cornerRadius(25)
            .font(.system(size: 23))
            .background(Color.blue)
    }
}

struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .cornerRadius(25)
            .font(.system(size: 30, weight: .heavy))
            .background(Color.green)
    }
}

struct OptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .cornerRadius(25)
            .font(.system(size: 25, weight: .heavy))
            .background(Color.green)
    }
}

struct SpellingView: View {
    @ObservedObject var viewRouter: ViewRouter
    
    @State private var word: String = ""
    @State private var pos: Int = 0
    @State private var character: Character = "a"
    @State private var options: [Character] = ["a","a","a","a"]
    @State private var alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    @State private var showMessage: Bool = false
    @State private var activeAlert: Int = 0 //0 is correct, 1 is error, 2 lost
    @State private var score: Int = 0
    @State private var lifes: Int = 3
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                Button(action: {
                    self.viewRouter.currentPage = "home"
                }){
                    Text("↩︎ Go Back")
                }
                Spacer()
                Text("Score: \(self.score)")
                    .textStyle(DefaultTextStyle())
                Spacer()
                Text("Lifes: \(self.lifes)")
                    .textStyle(DefaultTextStyle())
                Spacer()
            }
            Spacer()
            Text("\(self.word)")
                .textStyle(BigTextStyle())
            Spacer()
            HStack{
                Spacer()
                Text("Answer")
                    .textStyle(DefaultTextStyle())
                Spacer()
                ForEach ( 0 ..< self.options.count ){ value in
                    Button(action: {
                        if self.options[value] == self.character{
                            self.activeAlert = 0
                            self.showMessage = true
                            self.score += 1
                            self.getWord()
                        }else{
                            if self.lifes > 0{
                                self.activeAlert = 1
                                self.showMessage = true
                                self.lifes -= 1
                                self.getWord()
                            }else{
                                self.activeAlert = 2
                                self.showMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now()+3){
                                    self.viewRouter.currentPage = "home"
                                }
                            }
                            
                        }
                    }){
                        Text("\(String(self.options[value]))")
                    }
                    .alert(isPresented: self.$showMessage){
                        switch self.activeAlert{
                        case 0:
                            return Alert(title: Text("✔︎"))
                        case 1:
                            return Alert(title: Text("✖︎"))
                        case 2:
                            return Alert(title: Text("✖︎"), message: Text("Sorry, you've lost\nThe correct answer was \(String(self.character)) \nYour score was \(self.score)"))
                        default:
                            return Alert(title: Text("Default"))
                        }
                    }
                    .buttonStyle(OptionButtonStyle())
                    Spacer()
                }
            }
            Spacer()
        }.onAppear(perform: getWord)
    }
    
    func getWord() {
        guard let url = URL(string: "http://api.wordnik.com/v4/words.json/randomWords?hasDictionaryDef=true&minCorpusCount=0&minLength=5&maxLength=15&limit=1&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request){data, response, error in
            if let data = data {
                /*if let dataString = String(data: data, encoding: .utf8){
                    print("Response \(dataString)")
                    return
                }*/
                do {
                    let returnValue = try JSONDecoder().decode([Response].self, from: data)
                    let nWord = returnValue[0].word.uppercased()
                    print(nWord)
                    self.pos = Int.random(in: 0..<String(nWord).count)
                    self.character = nWord[nWord.index(nWord.startIndex, offsetBy: self.pos)]
                    self.word = String(nWord.dropLast((nWord.count)-self.pos))+"?"+String(nWord.dropFirst(self.pos+1))
                    //Push options
                    let randPos = Int.random(in: 0..<4)
                    self.options[randPos] = self.character
                    var alph = self.alphabet
                    if self.character != "-"{
                        alph.remove(at:
                            alph.firstIndex(of: String(self.character))!)
                    }
                    for n in 0..<4 {
                        if(n != randPos){
                            let rand = Int.random(in: 0 ..< alph.count)
                            self.options[n] = Character(alph[rand])
                            alph.remove(at: rand)
                        }
                    }
                    return
                }catch{
                    print("Error")
                }
                
            }
            
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct SpellingView_Previews: PreviewProvider {
    static var previews: some View {
        SpellingView(viewRouter: ViewRouter())
    }
}
