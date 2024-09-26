import Foundation

class FileUtility {
    static let shared = FileUtility()
    
    private init() {}
    
    func writeToFile(fileName: String, content: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                if let data = content.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Failed to write to file: \(error)")
        }
    }
    
    func readFromFile(fileName: String) -> String? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("Failed to read from file: \(error)")
            return nil
        }
    }
    
    func readSettings(fileName: String) -> [String: String]? {
        guard let content = readFromFile(fileName: fileName) else {
            return nil
        }
        
        var settings = [String: String]()
        let lines = content.split(separator: "\n")
        
        for line in lines {
            let parts = line.split(separator: ":")
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                settings[key] = value
            }
        }
        
        return settings
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
