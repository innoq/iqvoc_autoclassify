# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'document_parser/base'
require 'document_parser/german_document_parser'

class ParserDocumentTest < ActiveSupport::TestCase

  # source: http://de.wikipedia.org/wiki/Stoppwort
  @@doc1 = <<-EOF
    Stoppwörter nennt man im Information Retrieval Wörter, die bei einer Volltextindexierung nicht beachtet werden, da sie sehr häufig auftreten und gewöhnlich keine Relevanz für die Erfassung des Dokumentinhalts besitzen[1].

    Allgemein übliche Stoppwörter in deutschsprachigen Dokumenten sind bestimmte Artikel ('der', 'die', 'das'), unbestimmte Artikel ('einer', 'eine', 'ein'), Konjunktionen (z. B. 'und', 'oder', 'doch') und häufig gebrauchte Präpositionen (z. B. 'an', 'in', 'von'), sowie die Negation 'nicht'[2]. Im Englischen sind unter anderem 'a', 'of', 'the', 'I', 'it', 'you' und 'and' Stoppwörter[3]. Abhängig von den zu erschließenden Dokumenten können Stoppwörter auch mehrsprachig vorliegen[4]. Obwohl eher als Stoppzeichen zu benennen werden häufig auch der Punkt (.), das Komma (,) und der Strichpunkt (;) als Stoppwörter bezeichnet[5].

    Allen Stoppwörtern ist gemeinsam, dass sie vor allem grammatikalische/syntaktische Funktionen übernehmen und daher keine Rückschlüsse auf den Inhalt des Dokumentes zulassen[6].

    Eine weitere Gemeinsamkeit ist ihre große Zahl: sie treten in jedem Dokument sehr zahlreich auf und kommen in sehr vielen Dokumenten vor, wodurch sie bei der Erschließung der Dokumente einen hohen Aufwand verursachen würden[7].

    Stoppwörter dienen der Steigerung der Effizienz von Suchmaschinen[8]. Würde man Stoppwörter bei einem Suchauftrag beachten, würde die Ergebnismenge nahezu jedes Dokument des Bestandes enthalten[9]. Ein solches Suchergebnis wäre für den Anwender nutzlos[10].

    Hans Peter Luhn, einer der Pioniere des Information Retrieval, prägte den Begriff der Stoppwörter und benutzte dieses Konzept im Design und in der Implementation des Indexers KWIC[11].
  EOF

  # source: http://www.umweltbundesamt.de/gesundheit/badegewaesser/index.htm
  @@doc2 = <<-EOF
    Gesundheit und Umwelthygiene
    Badegewässer

    Letzte Änderung: 05.07.2011

    Badegewässer sind, im Unterschied zu künstlich angelegten Schwimm- und Badebecken, Gewässer oder Teile davon, die am natürlichen Wasserkreislauf teilhaben – also Seen, Flüsse und die Küsten von Nord- und Ostsee.
    Die Qualität der Badegewässer in Deutschland

    Zur Beurteilung der Badegewässer aus hygienischer Sicht gibt es bereits seit 1976 die europäische Badegewässerrichtlinie. In Deutschland gibt es rund 2.000 offiziell gemeldete Badegewässer. Die Länder überwachen diese Badegewässer regelmäßig nach dieser Richtlinie.

    Die Ergebnisse der wasserhygienischen Untersuchungen aus den Bundesländern fasst das Umweltbundesamt zusammen, prüft sie auf Stimmigkeit und leitet sie über das Bundesministerium für Umwelt, Naturschutz und Reaktorsicherheit an die Europäische Kommission. Diese erstellt eine Qualitätseinstufung aller europäischen Badestellen. Die Ergebnisse werden als „Jährlicher Bericht zur Badewasserqualität” veröffentlicht. Die EU bietet auch einen Data viewer zur Badewasserqualität (auf Englisch) an.

    Die Bundesländer sind für die Überwachung der Badegewässer verantwortlich. Die meisten Bundesländer stellen aktuelle Daten im Internet zur Verfügung. In den Ländern, die noch keine zentrale Internetinformation bereitstellen, erteilen die zuständigen Gesundheitsbehörden Auskunft.
    Baden-Württemberg	Mecklenburg-Vorpommern	Sachsen
    Bayern	Niedersachsen	Sachsen-Anhalt
    Berlin	Nordrhein-Westfalen	Schleswig-Holstein
    Brandenburg	Rheinland-Pfalz	Thüringen
    Bremen	Hessen
    Hamburg	Saarland

    Am 24. März 2006 trat die novellierte europäische Richtlinie über die Qualität der Badegewässer und deren Bewirtschaftung in Kraft. Die Richtlinie wurde in Deutschland in 16 Länderverordnungen umgesetzt. Seit der Badesaison 2008 werden die Badegewässer nach der neuen Richtlinie überwacht. Für die Einstufung der Badegewässer nach den Vorgaben der neuen Richtlinie werden Daten aus vier Jahren benötigt; die erste Einstufung wird daher im Jahr 2011 erfolgen.

    Das Umweltbundesamt hat eine Empfehlung für die praktische Anwendung der Richtlinie PDF / 215 KB und die Beurteilung der Badegewässer in der Übergangszeit bis 2011 erarbeitet.

    Das Umweltbundesamt trägt dazu bei, die Badenden vor Infektionen zu schützen:

        Es bewertet das Infektionsrisiko in Badegewässern.
        Es erarbeitet wissenschaftliche Grundlagen für die Festsetzung mikrobiologischer Grenzwerte im Badegewässer- und Abwasserbereich (gemäß Infektionsschutzgesetz.
        Es entwickelt Konzepte zur Vorbeugung, Erkennung und Verhinderung der Weiterverbreitung der durch Wasser übertragbaren Krankheiten (gemäß Paragraf 40 des Infektionsschutzgesetzes).
        Es arbeitet laborgestützt und theoretisch an hygienisch-mikrobiologischen Fragestellungen im Badegewässerbereich zur Vorsorge vor Erkrankungen.
        Es entwickelt und standardisiert Methoden zum Nachweis von Krankheitserregern in Badegewässern und Abwassereinleitungen.
        Es koordiniert national und international die Entwicklung und Erprobung von mikrobiologischen Nachweisverfahren im Badegewässerbereich.
        Es koordiniert und prüft die Badegewässerdaten aus den Bundesländern und stellt sie der Öffentlichkeit zur Verfügung.

    Baden ist gesund – aber es gibt Risiken

    Die mit dem Baden verbundene körperliche Bewegung ist gut für die Gesundheit. Daher ist es umso wichtiger, auf gesundheitliche Risiken, die mit dem Baden verbunden sein können, zu achten:

        Unfälle
        Das Spektrum reicht von Schnittverletzungen und Schürfwunden bis zum Ertrinken. An bewachten Badestellen sind Unfälle jedoch selten.
        Krankheitserreger
        Magen-Darm-Erkrankungen können auftreten, falls mit Fäkalien bestimmte Krankheitserreger in ein Gewässer gelangen. Dies ist möglich, falls Abwasser, Regenwasserüberläufe oder Abschwemmungen aus landwirtschaftlichen Flächen hineinfließen. Auch die Badenden selbst oder Vögel können lokal zu fäkalen Verunreinigungen beitragen. Insbesondere in heißen Sommern können nach Kontakt mit Meerwasser PDF / 213 KB auch Infektionen mit dem Bakterium Vibrio vulnificus vorkommen.
        Cyanobakterien (Blaualgen)
        Postkarte Vorsicht Cyanobakterien!Cyanobakterien können sich in Gewässern mit hohem Nährstoffgehalt massenhaft vermehren. Sie bilden Giftstoffe, die bei Menschen Gesundheitsstörungen hervorrufen können. Das Umweltbundesamt hat eine Empfehlung zum Schutz von Badenden vor Cyanobakterien-Toxinen PDF / 292 KB veröffentlicht.

        Postkarte Vorsicht Cyanobakterien! Oder was schwimmt da eigentlich? PDF / 986 KB

        Das CyanoCenter berät und unterstützt das Umweltbundesamt bei der Analyse und gesundheitlichen Bewertung des Vorkommens möglicherweise toxischer Cyanobakterien sowie bei der Entwicklung und Optimierung von situationsangepassten Überwachungsprogrammen und Strategien zur Beherrschung des Problems.

    Weitere Informationen

        Linksammlung
        Publikationen
  EOF

  test "sample documents" do
    doc = DocumentParser::Base.new @@doc1
    assert_equal 15, doc.sentences.length # base parser doesn't handle abbreviations

    doc = DocumentParser::German.new @@doc1
    assert_equal 11, doc.sentences.length

    doc = DocumentParser::German.new @@doc2
    assert_equal 46, doc.sentences.length # NB: the actual value here was in manually checking the parser output against the original
  end
end
