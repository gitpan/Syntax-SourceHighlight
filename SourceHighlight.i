%module "Syntax::SourceHighlight"

%feature("compactdefaultargs");
%include "std_string.i"
%include "exception.i"

%{
#include <sstream>
#include <srchilite/highlighttoken.h>
#include <srchilite/highlightevent.h>
#include <srchilite/highlighteventlistener.h>
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

%typemap(out) MatchedElements & {
  AV *elements = newAV();

  for (MatchedElements::const_iterator it = $1->begin(); it != $1->end(); ++it)
    av_push(elements, newSVpvf("%s:%s", it->first.c_str(), it->second.c_str()));

  $result = sv_2mortal((SV *)newRV_noinc((SV *)elements));
  argvi++;
}

%nodefaultctor HighlightToken;
class HighlightToken {
 public:
  //HighlightToken(const HighlightRule *rule = 0);
  //HighlightToken(const std::string &elem, const std::string &matched, const std::string &prefix, const HighlightRule *rule = 0);
  //void copyFrom(const HighlightToken &token);
  //void clearMatched();
  //void addMatched(const std::string &elem, const std::string &s);
  //std::string prefix;
  //bool prefixOnlySpaces;
  //std::string suffix;
  //MatchedElements matched;
  //unsigned int matchedSize;
  //MatchedSubExps matchedSubExps;
  //const HighlightRule *rule;
} ;

%extend HighlightToken {
  const std::string &prefix() {
    return $self->prefix;
  }

  bool isPrefixOnlySpaces() {
    return $self->prefixOnlySpaces;
  }

  const std::string &suffix() {
    return $self->suffix;
  }

  unsigned int matchedSize() {
    return $self->matchedSize;
  }

  const MatchedElements &matched() {
    return $self->matched;
  }
}

%nodefaultctor HighlightEvent;
class HighlightEvent {
 public:
  enum HighlightEventType {
    FORMAT = 0,
    FORMATDEFAULT,
    ENTERSTATE,
    EXITSTATE
  } ;

  //HighlightEvent(const HighlightToken &token, HighlightEventType type = FORMAT);
  //const HighlightToken &token;
  //HighlightEventType type;
} ;

%extend HighlightEvent {
  const HighlightToken &token() {
    return $self->token;
  }

  HighlightEventType type() {
    return $self->type;
  }
}

%{
class PerlHighlightEventListener : public HighlightEventListener {
 private:
  SV *callback;
  
 public:
  PerlHighlightEventListener(SV *callback) : HighlightEventListener(), callback(callback) {
    SvREFCNT_inc(callback);
  }
  
  virtual ~PerlHighlightEventListener() {
    SvREFCNT_dec(callback);
  }
  
  virtual void notify(const HighlightEvent &event) {
    dSP;
    
    ENTER;
    SAVETMPS;
    
    PUSHMARK(SP);
    XPUSHs(SWIG_NewPointerObj(SWIG_as_voidptr(&event),
			      SWIGTYPE_p_HighlightEvent, SWIG_SHADOW));
    PUTBACK;
    
    call_sv(callback, G_VOID | G_EVAL);
    
    FREETMPS;
    LEAVE;
    
    if (SvTRUE(ERRSV)) {
      STRLEN len;
      throw std::runtime_error(SvPV(ERRSV, len));
    }
  }
} ;
%}

%typemap(in) HighlightEventListener * {
  $1 = new PerlHighlightEventListener($input);
}

%{
class PerlSourceHighlight : public SourceHighlight {
 private:
  HighlightEventListener *highlightEventListener;

 public:
  PerlSourceHighlight(const std::string &outputLang) : SourceHighlight(outputLang), highlightEventListener(0) {
  }

  ~PerlSourceHighlight() {
    setHighlightEventListener(0);
  }

  void setHighlightEventListener(HighlightEventListener *l) {
    SourceHighlight::setHighlightEventListener(l);
    
    if (highlightEventListener)
      delete highlightEventListener;
    
    highlightEventListener = l;
  }
} ;
%}

%rename(SourceHighlight) PerlSourceHighlight;
%nodefaultctor PerlSourceHighlight;
class PerlSourceHighlight {
 public:
  PerlSourceHighlight(const std::string &outputLang = "html.outlang");
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
  void setHighlightEventListener(HighlightEventListener *l);
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

%extend PerlSourceHighlight {
  const std::string highlightString(const std::string &input, const std::string &inputLang, const std::string &inputFileName = "") {
    std::stringstream inputStream(input);
    std::stringstream outputStream;

    $self->highlight(inputStream, outputStream, inputLang, inputFileName);

    return outputStream.str();
  }
}

%typemap(out) std::set< std::string > {
  AV *elements = newAV();

  for (std::set< std::string >::const_iterator it = $1.begin(); it != $1.end(); ++it)
    av_push(elements, newSVpvn(it->data(), it->size()));

  $result = sv_2mortal((SV *)newRV_noinc((SV *)elements));
  argvi++;
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

%extend LangMap {
  const std::set< std::string > langNames() {
    $self->open();
    return $self->getLangNames();
  }

  const std::set< std::string > mappedFileNames() {
    $self->open();
    return $self->getMappedFileNames();
  }
}

%perlcode %{

BEGIN {
  use File::Spec::Functions qw/catfile/;

  unless (exists $ENV{SOURCE_HIGHLIGHT_DATADIR}) {
    for (@INC) {
      my $data = catfile($_, 'Syntax', 'SourceHighlight');
      if (-d $data) {
	$ENV{SOURCE_HIGHLIGHT_DATADIR} = $data;
      }
    }
  }
}

our $VERSION = "1.1.1";
%}
