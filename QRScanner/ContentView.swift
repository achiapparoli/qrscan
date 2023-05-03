//
//  ContentView.swift
//  QRScanner
//
//  Created by Alberto Chiapparoli on 02/05/23.
//

import SwiftUI
import AVFoundation

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()



struct ContentView: View {
    @State private var isShowingScanner = false
        @State private var importedTasks: [Task] = []

        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }()

        var body: some View {
            NavigationView {
                VStack {
                    if !importedTasks.isEmpty {
                        List(importedTasks) { task in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(task.title)
                                    .font(.headline)
                                Text("Due Date: \(task.date, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                    } else {
                        Text("Scan a QR Code")
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingScanner = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    QRCodeScannerView { code in
                        fetchTask(from: code)
                        isShowingScanner = false
                    }
                }
            }
        }
    
    func fetchTask(from url: String) {
        guard let taskURL = URL(string: url) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: taskURL) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }

            // Print the fetched data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Fetched JSON data: \(jsonString)")
            }
            
            parseTaskJSON(data: data)
        }.resume()
    }

    
    func parseTaskJSON(data: Data) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let tasks = try decoder.decode([Task].self, from: data)
            DispatchQueue.main.async {
                // Process the imported tasks here
                importedTasks = tasks // Update the importedTasks state variable with the fetched tasks
                print("Imported tasks: \(tasks)")
            }
        } catch {
            print("Error decoding JSON data: \(error.localizedDescription)")
            print("Decoding error details: \(error)")
        }
    }



}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
