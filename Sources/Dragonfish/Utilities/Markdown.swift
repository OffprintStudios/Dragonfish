import Foundation
import Markdown

struct RawHTMLStripper: MarkupRewriter {
    var removedUnsafeHTML = false

    mutating func visitHTMLBlock(_ htmlBlock: HTMLBlock) -> any Markup? {
        removedUnsafeHTML = true
        // Returning nil removes raw HTML blocks (e.g. <div>, <script>, <iframe>)
        return nil
    }

    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> any Markup? {
        removedUnsafeHTML = true
        // Returning nil removes raw inline HTML tags (e.g. <br>, <span ...>)
        return nil
    }
}

/// Strips all Raw HTML from markdown inputs
func cleanMarkdown(_ rawMarkdown: String) -> String {
    let document = Document(parsing: rawMarkdown)
    var stripper = RawHTMLStripper()
    let cleaned = stripper.visit(document) ?? document

    guard stripper.removedUnsafeHTML else {
        return rawMarkdown
    }

    return cleaned.format()
}

struct WordCounter: MarkupWalker {
    private var proseText = ""
    var includeCodeBlocks = false

    mutating func visitText(_ text: Text) {
        proseText += text.plainText + " "
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) {
        if includeCodeBlocks {
            proseText += inlineCode.code + " "
        }
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        if includeCodeBlocks {
            proseText += codeBlock.code + " "
        }
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) {
        proseText += " "
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) {
        proseText += " "
    }

    func wordCount() -> Int {
        let pattern = #"[\p{L}\p{N}]+(?:['’\-][\p{L}\p{N}]+)*"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return proseText.split(whereSeparator: \.isWhitespace).count
        }
        let range = NSRange(proseText.startIndex..., in: proseText)
        return regex.numberOfMatches(in: proseText, range: range)
    }
}

/// Attempts an accurate word count for raw markdown
func countMarkdownWords(_ rawMarkdown: String, includeCodeBlocks: Bool = false) -> Int {
    let document = Document(parsing: rawMarkdown)
    var counter = WordCounter(includeCodeBlocks: includeCodeBlocks)
    counter.visit(document)
    return counter.wordCount()
}