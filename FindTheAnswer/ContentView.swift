//
//  ContentView.swift
//  FindTheAnswer
//
//  Created by Mario Alvarado on 6/14/20.
//  Copyright © 2020 Mario Alvarado. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewRouter: ViewRouter
    var body: some View {
        VStack{
            Spacer()
            Text("Find The Answer!")
            Spacer()
            HStack{
                Spacer()
                Button(action: {
                    
                }){
                    Text("Math")
                }
                Spacer()
                Button(action: {
                    
                }){
                    Text("Spelling")
                }
                Spacer()
            }
            Spacer()
            Button(action: {
                
            }){
                Text("Exit")
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewRouter: ViewRouter())
    }
}
