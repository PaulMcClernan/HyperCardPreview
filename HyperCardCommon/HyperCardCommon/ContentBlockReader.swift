//
//  ContentBlockReader.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 03/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Content of a part
/// <p>
/// Part contents are separated from parts because it makes text search easier, because
/// background fields have text contents in the card, because background buttons have hilite
/// contents in the card
public struct ContentBlockReader {
    
    private let data: DataRange
    
    private let version: FileVersion
    
    /* this parameter is read separately */
    private let identifier: Int
    
    /* this parameter is read separately */
    private let layerType: LayerType
    
    public init(data: DataRange, version: FileVersion, identifier: Int, layerType: LayerType) {
        self.data = data
        self.version = version
        self.identifier = identifier
        self.layerType = layerType
    }
    
    /// The identifier of the part
    public func readIdentifier() -> Int {
        return self.identifier
    }
    
    /// Whether the part is in the background or the card
    public func readLayerType() -> LayerType {
        return self.layerType
    }
    
    /// The string content
    public func readString() -> HString {
        
        /* Handle version 1 */
        guard self.version.isTwo() else {
            return data.readString(at: 2, length: data.length - 3)
        }
        
        /* Check if we're a raw string or a formatted text */
        let plainTextMarker = data.readUInt8(at: 4)
        
        /* Plain text */
        if plainTextMarker == 0 {
            return data.readString(at: 5, length:data.length - 5)
        }
        else {
            let formattingLengthValue = data.readUInt16(at: 4)
            let formattingLength = formattingLengthValue - 0x8000
            let stringOffset = 4 + formattingLength
            return data.readString(at: stringOffset, length:data.length - 4 - formattingLength)
        }
    }
    
    /// The style records. They are sorted by offset. If nil, the string has no associated style.
    public func readFormattingChanges() -> [IndexedTextFormatting]? {
        
        /* Handle version 1 */
        guard self.version.isTwo() else {
            return nil
        }
        
        /* Check if we're a raw string or a formatted text */
        let plainTextMarker = data.readUInt8(at: 4)
        guard plainTextMarker != 0 else {
            return nil
        }
        
        /* Plain text */
        var changes: [IndexedTextFormatting] = []
        let formattingLengthValue = data.readUInt16(at: 4)
        let formattingLength = formattingLengthValue ^ 0x8000
        let formattingCount = (formattingLength - 2) / 4
        var offset = 6
        for _ in 0..<formattingCount {
            let changeOffset = data.readUInt16(at: offset)
            let styleIdentifier = data.readUInt16(at: offset + 2)
            changes.append(IndexedTextFormatting(offset: changeOffset, styleIdentifier: styleIdentifier))
            offset += 4
        }
        return changes
    }
    
}

