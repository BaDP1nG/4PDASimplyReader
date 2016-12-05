//
//  Parser.swift
//  4PDA
//
//  Created by Полар Групп on 05.12.16.
//  Copyright © 2016 Polar Development Group. All rights reserved.
//

import UIKit

struct News {
    var title: String!
    var description: String!
    var link: String!
    var date: String!
}

enum eParsingStatus {
    case EStopped
    case EParsing
    case ESuccees
    case EFailed
}

protocol ParserDelegate {
    func parseSuccess(_ parser: Parser, didParseArray items: [News])
    
}

class Parser: NSObject, XMLParserDelegate {
    var newsArray:[News] = []
    var parser: XMLParser?
    var tmpNews: News? = nil
    var tempElement: String?
    private var status: eParsingStatus = .EStopped
    var currentElementName: String!
    var url: URL?
    
    var delegate: ParserDelegate?
    
    init(url: URL) {
        self.url = url
    }
    
    
    func startParsing() {
        
        if status == .EParsing {
            return
        }
        
        status = .EParsing
        
        stopParsing()
        
        parser = XMLParser(contentsOf: url!)!
        parser?.delegate = self
        
        if (parser != nil) { // received
            status = .EParsing
            parser!.shouldProcessNamespaces = true
            parser!.delegate = self
            parser!.parse()
            
            delegate?.parseSuccess(self, didParseArray: newsArray)
        } else { // error
            status = .EFailed
        }
        
    }
    
    func stopParsing() {
        
        status = .EStopped
        currentElementName = nil
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parse error: \(parseError)")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentElementName = elementName
        if elementName == "rss" {
            newsArray = []
        }
        
        if elementName == "item" {
            tmpNews = News(title: "", description:"", link: "", date: "")
        }
        
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let post = tmpNews {
                newsArray.append(post)
            }
            tmpNews = nil
        }
        
        if elementName == "rss" {
         status = .ESuccees
         }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        let string: String? = String(data: CDATABlock, encoding: String.Encoding.utf8)
        
        switch currentElementName {
        case "title":
            tmpNews?.title = try! HTMLDecode(string!)
        case "description":
            tmpNews?.description = try! HTMLDecode(string!)
        case "pubDate":
            tmpNews?.date = string
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        switch currentElementName {
        case "link":
            tmpNews?.link = string
        case "pubDate":
            tmpNews?.date = string
        default:
            break
        }
        
    }
    
    func HTMLDecode(_ string: String) throws -> String? {
        guard let tmpData = string.data(using: .utf8) else { return nil }
        
        return try NSAttributedString(data: tmpData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil).string
    }
}
