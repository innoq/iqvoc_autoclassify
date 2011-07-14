# encoding: UTF-8

require File.join(File.dirname(__FILE__), 'test_helper')
require 'document_parser'


class ParserDocumentTest < Test::Unit::TestCase

  # source: http://de.wikipedia.org/wiki/Stoppwort
  @@text = <<-EOF
    Stoppwörter nennt man im Information Retrieval Wörter, die bei einer Volltextindexierung nicht beachtet werden, da sie sehr häufig auftreten und gewöhnlich keine Relevanz für die Erfassung des Dokumentinhalts besitzen[1].

    Allgemein übliche Stoppwörter in deutschsprachigen Dokumenten sind bestimmte Artikel ('der', 'die', 'das'), unbestimmte Artikel ('einer', 'eine', 'ein'), Konjunktionen (z. B. 'und', 'oder', 'doch') und häufig gebrauchte Präpositionen (z. B. 'an', 'in', 'von'), sowie die Negation 'nicht'[2]. Im Englischen sind unter anderem 'a', 'of', 'the', 'I', 'it', 'you' und 'and' Stoppwörter[3]. Abhängig von den zu erschließenden Dokumenten können Stoppwörter auch mehrsprachig vorliegen[4]. Obwohl eher als Stoppzeichen zu benennen werden häufig auch der Punkt (.), das Komma (,) und der Strichpunkt (;) als Stoppwörter bezeichnet[5].

    Allen Stoppwörtern ist gemeinsam, dass sie vor allem grammatikalische/syntaktische Funktionen übernehmen und daher keine Rückschlüsse auf den Inhalt des Dokumentes zulassen[6].

    Eine weitere Gemeinsamkeit ist ihre große Zahl: sie treten in jedem Dokument sehr zahlreich auf und kommen in sehr vielen Dokumenten vor, wodurch sie bei der Erschließung der Dokumente einen hohen Aufwand verursachen würden[7].

    Stoppwörter dienen der Steigerung der Effizienz von Suchmaschinen[8]. Würde man Stoppwörter bei einem Suchauftrag beachten, würde die Ergebnismenge nahezu jedes Dokument des Bestandes enthalten[9]. Ein solches Suchergebnis wäre für den Anwender nutzlos[10].

    Hans Peter Luhn, einer der Pioniere des Information Retrieval, prägte den Begriff der Stoppwörter und benutzte dieses Konzept im Design und in der Implementation des Indexers KWIC[11].
  EOF

  def test_sample_document
    doc = DocumentParser.new @@text
    assert_equal 13, doc.sentences.length # base parser doesn't handle abbreviations

    doc = GermanDocumentParser.new @@text
    assert_equal 11, doc.sentences.length
  end
end
