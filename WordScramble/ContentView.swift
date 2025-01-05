//
//  ContentView.swift
//  WordScramble
//
//  Created by Anurag on 03/01/25.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var playerScore = 0;
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard answer.count >= 3 else {
            wordError(title: "Word too short", message: "Words must be at least 3 characters long")
            
            return
        }
        
        guard answer != rootWord else{
            wordError(title: "You cant use the same word", message: "Use Different Words")
            playerScore-=1
            return
        }
        
        guard isOriginal(word:answer) else {
            wordError(title: "Word used already",message: "Be more orignal")
            playerScore-=1
            return
        }
        
        guard isPossible(word:answer) else {
            wordError(title: "Word not possible",message: "You can't spell that word from '\(rootWord)'!")
            playerScore-=1
            return
        }
        
        guard isReal(word:answer) else {
            wordError(title: "Word not recognized",message: "You can't just make them up,you know!")
            playerScore-=1
            return
        }
        
        withAnimation{
            usedWords.insert(answer,at: 0)
        }
        playerScore += 1
        newWord = ""
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf:startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    
    func isOriginal(word:String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word:String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false;
            }
        }
        return true;
    }
    
    func isReal(word:String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title:String,message:String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    var body: some View {
        NavigationStack{
            List{
                Section {
                    TextField("Enter your word",text:$newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords,id: \.self){ word in
                        HStack{
                            Image(systemName:"\(word.count).circle")
                            Text(word)
                        }
                         
                    }
                }
                Section {
                    Text("Your score is \(playerScore)")
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(
            perform: startGame
            )
            .alert(errorTitle, isPresented:$showingError){
                Button("OK"){}
            } message:{
                Text(errorMessage)
            }
            .toolbar{
                Button("New Game"){
                    startGame()
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
