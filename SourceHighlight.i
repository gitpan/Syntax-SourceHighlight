%module "Syntax::SourceHighlight"

%feature("compactdefaultargs");
%include "std_string.i"
%include "exception.i"

%{
#include <sstream>
#include <srchilite/sourcehighlight.h>
#include <srchilite/langmap.h>
#include <srchilite/ioexception.h>

using namespace srchilite;
%}

%exception {
  try {
    $action
  }
  catch (srchilite::IOException &e) {
    SWIG_exception(SWIG_IOError, e.message.c_str());
  }
  SWIG_CATCH_STDEXCEPT
}

%nodefaultctor SourceHighlight;
class SourceHighlight {
 public:
  SourceHighlight(const std::string &outputLang = "html.outlang");
  //void initialize();
  %rename(highlightFile) highlight;
  void highlight(const std::string &input, const std::string &output, const std::string &inputLang);
  //void highlight(std::istream &input, std::ostream &output, const std::string &inputLang, const std::string &inputFileName = "");
  void checkLangDef(const std::string &langFile);
  void checkOutLangDef(const std::string &langFile);
  //void printHighlightState(const std::string &langFile, std::ostream &os);
  //void printLangElems(const std::string &langFile, std::ostream &os);
  const std::string createOutputFileName(const std::string &inputFile);
  void setDataDir(const std::string &datadir);
  void setStyleFile(const std::string &styleFile);
  void setStyleCssFile (const std::string &styleFile);
  void setStyleDefaultFile(const std::string &styleDefaultFile);
  void setTitle(const std::string &title);
  void setCss(const std::string &css);
  void setHeaderFileName(const std::string &h);
  void setFooterFileName(const std::string &f);
  void setOutputDir(const std::string &outputDir);
  //const TextStyleFormatterCollection &getFormatterCollection() const;
  void setOptimize(bool b = true);
  void setGenerateLineNumbers(bool b = true);
  void setGenerateLineNumberRefs(bool b = true);
  void setLineNumberPad(char c);
  void setLineNumberAnchorPrefix(const std::string &prefix);
  void setGenerateEntireDoc(bool b = true);
  void setGenerateVersion(bool b = true);
  void setCanUseStdOut(bool b = true);
  void setBinaryOutput(bool b = true);
  //void setHighlightEventListener(HighlightEventListener *l);
  void setRangeSeparator(const std::string &sep);
  //DocGenerator *getDocGenerator() const;
  //DocGenerator *getNoDocGenerator() const;
  //LineRanges *getLineRanges() const;
  //void setLineRanges(LineRanges *lr);
  //RegexRanges *getRegexRanges () const;
  //void setRegexRanges(RegexRanges *rr);
  //void setCTagsManager(CTagsManager *m);
  void setTabSpaces(unsigned int i);
} ;

%extend SourceHighlight {
  const std::string highlightString(const std::string &input, const std::string &inputLang, const std::string &inputFileName = "") {
    std::stringstream inputStream(input);
    std::stringstream outputStream;

    $self->highlight(inputStream, outputStream, inputLang, inputFileName);

    return outputStream.str();
  }
}

%nodefaultctor LangMap;
class LangMap {
 public:
  LangMap(const std::string &filename = "lang.map");
  LangMap(const std::string &path, const std::string &filename);
  //const_iterator begin();
  //const_iterator end();
  //void print();
  //void open();
  //const std::string getFileName(const std::string &lang);
  const std::string getMappedFileName(const std::string &lang);
  const std::string getMappedFileNameFromFileName(const std::string &fileName);
  //std::set< std::string > getLangNames() const;
  //std::set< std::string > getMappedFileNames() const;
} ;
