//
//  ContentView.swift
//  WordScramble
//
//  Created by Auston Youngblood on 5/22/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var score = 0
    @State private var scoreColor: Color = .green
    @State private var sentiment: String = "😐"
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Current Score") {
                    Text("\(score) \(sentiment)")
                        .foregroundColor(scoreColor)
                }
                
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                                .foregroundColor(.green)
                            Text(word)
                        }
                        .font(.title)
                    }
                }.padding().padding(.vertical, 4.0)
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {
                    newWord = ""
                    let subtract = randomNum()
                    score = score - subtract
                    scoreColor = .red
                }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Start New Game") {
                        startGame()
                    }
                }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard differentWord(word: answer) else {
            wordError(title: "Come on, man!", message: "Don't just put the same word in, that's lame!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original, darn it!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "Check the word again. You must only use the letters in the orignal word. The original word was \(rootWord).")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Not a real word", message: "Your word does not appear in the English dictionary. Try again.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            score = score + answer.count
            sentiment = sentimentAnalysis()
            scoreColor = .green
        }
        newWord = ""
    }
    
    func startGame() {
        withAnimation {
            usedWords = []
            score = 0
            scoreColor = .green
        }
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "cauliflower"
                return
            }
        }
        
        fatalError("Couldn't load the start.txt file from the bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func differentWord(word: String) -> Bool {
        word != rootWord
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func randomNum() -> Int {
        let randomInt = Int.random(in: 0..<6)
        return randomInt
    }
    
    func sentimentAnalysis() -> String {
        if score == 0 {
            return "😐"
        } else if score > 0 && score <= 3 {
            return "😀"
        } else if score > 3 {
            return "😊😱"
        } else {
            return "🤮🤮🤮"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
