/*
   +----------------------------------------------------------------------+
   | HipHop for PHP                                                       |
   +----------------------------------------------------------------------+
   | Copyright (c) 2010-2013 Facebook, Inc. (http://www.facebook.com)     |
   | Copyright (c) 1997-2010 The PHP Group                                |
   +----------------------------------------------------------------------+
   | This source file is subject to version 3.01 of the PHP license,      |
   | that is bundled with this package in the file LICENSE, and is        |
   | available through the world-wide-web at the following url:           |
   | http://www.php.net/license/3_01.txt                                  |
   | If you did not receive a copy of the PHP license and are unable to   |
   | obtain it through the world-wide-web, please send a note to          |
   | license@php.net so we can mail you a copy immediately.               |
   +----------------------------------------------------------------------+
*/

#ifndef incl_HPHP_EXT_XMLWRITER_H_
#define incl_HPHP_EXT_XMLWRITER_H_

// >>>>>> Generated by idl.php. Do NOT modify. <<<<<<

#include "hphp/runtime/base/base-includes.h"
#include <libxml/tree.h>
#include <libxml/xmlwriter.h>
#include <libxml/uri.h>
#include "hphp/runtime/base/file.h"
namespace HPHP {
///////////////////////////////////////////////////////////////////////////////

Variant f_xmlwriter_open_memory();
Object f_xmlwriter_open_uri(CStrRef uri);
bool f_xmlwriter_set_indent_string(CObjRef xmlwriter, CStrRef indentstring);
bool f_xmlwriter_set_indent(CObjRef xmlwriter, bool indent);
bool f_xmlwriter_start_document(CObjRef xmlwriter, CStrRef version = "1.0", CStrRef encoding = null_string, CStrRef standalone = null_string);
bool f_xmlwriter_start_element(CObjRef xmlwriter, CStrRef name);
bool f_xmlwriter_start_element_ns(CObjRef xmlwriter, CStrRef prefix, CStrRef name, CStrRef uri);
bool f_xmlwriter_write_element_ns(CObjRef xmlwriter, CStrRef prefix, CStrRef name, CStrRef uri, CStrRef content = null_string);
bool f_xmlwriter_write_element(CObjRef xmlwriter, CStrRef name, CStrRef content = null_string);
bool f_xmlwriter_end_element(CObjRef xmlwriter);
bool f_xmlwriter_full_end_element(CObjRef xmlwriter);
bool f_xmlwriter_start_attribute_ns(CObjRef xmlwriter, CStrRef prefix, CStrRef name, CStrRef uri);
bool f_xmlwriter_start_attribute(CObjRef xmlwriter, CStrRef name);
bool f_xmlwriter_write_attribute_ns(CObjRef xmlwriter, CStrRef prefix, CStrRef name, CStrRef uri, CStrRef content);
bool f_xmlwriter_write_attribute(CObjRef xmlwriter, CStrRef name, CStrRef value);
bool f_xmlwriter_end_attribute(CObjRef xmlwriter);
bool f_xmlwriter_start_cdata(CObjRef xmlwriter);
bool f_xmlwriter_write_cdata(CObjRef xmlwriter, CStrRef content);
bool f_xmlwriter_end_cdata(CObjRef xmlwriter);
bool f_xmlwriter_start_comment(CObjRef xmlwriter);
bool f_xmlwriter_write_comment(CObjRef xmlwriter, CStrRef content);
bool f_xmlwriter_end_comment(CObjRef xmlwriter);
bool f_xmlwriter_end_document(CObjRef xmlwriter);
bool f_xmlwriter_start_pi(CObjRef xmlwriter, CStrRef target);
bool f_xmlwriter_write_pi(CObjRef xmlwriter, CStrRef target, CStrRef content);
bool f_xmlwriter_end_pi(CObjRef xmlwriter);
bool f_xmlwriter_text(CObjRef xmlwriter, CStrRef content);
bool f_xmlwriter_write_raw(CObjRef xmlwriter, CStrRef content);
bool f_xmlwriter_start_dtd(CObjRef xmlwriter, CStrRef qualifiedname, CStrRef publicid = null_string, CStrRef systemid = null_string);
bool f_xmlwriter_write_dtd(CObjRef xmlwriter, CStrRef name, CStrRef publicid = null_string, CStrRef systemid = null_string, CStrRef subset = null_string);
bool f_xmlwriter_start_dtd_element(CObjRef xmlwriter, CStrRef qualifiedname);
bool f_xmlwriter_write_dtd_element(CObjRef xmlwriter, CStrRef name, CStrRef content);
bool f_xmlwriter_end_dtd_element(CObjRef xmlwriter);
bool f_xmlwriter_start_dtd_attlist(CObjRef xmlwriter, CStrRef name);
bool f_xmlwriter_write_dtd_attlist(CObjRef xmlwriter, CStrRef name, CStrRef content);
bool f_xmlwriter_end_dtd_attlist(CObjRef xmlwriter);
bool f_xmlwriter_start_dtd_entity(CObjRef xmlwriter, CStrRef name, bool isparam);
bool f_xmlwriter_write_dtd_entity(CObjRef xmlwriter, CStrRef name, CStrRef content, bool pe = false, CStrRef publicid = null_string, CStrRef systemid = null_string, CStrRef ndataid = null_string);
bool f_xmlwriter_end_dtd_entity(CObjRef xmlwriter);
bool f_xmlwriter_end_dtd(CObjRef xmlwriter);
Variant f_xmlwriter_flush(CObjRef xmlwriter, bool empty = true);
String f_xmlwriter_output_memory(CObjRef xmlwriter, bool flush = true);

///////////////////////////////////////////////////////////////////////////////
// class XMLWriter

FORWARD_DECLARE_CLASS(XMLWriter);
class c_XMLWriter : public ExtObjectData, public Sweepable {
 public:
  DECLARE_CLASS(XMLWriter)

  // need to implement
  public: c_XMLWriter(Class* cls = c_XMLWriter::classof());
  public: ~c_XMLWriter();
  public: void t___construct();
  public: bool t_openmemory();
  public: bool t_openuri(CStrRef uri);
  public: bool t_setindentstring(CStrRef indentstring);
  public: bool t_setindent(bool indent);
  public: bool t_startdocument(CStrRef version = "1.0", CStrRef encoding = null_string, CStrRef standalone = null_string);
  public: bool t_startelement(CStrRef name);
  public: bool t_startelementns(CStrRef prefix, CStrRef name, CStrRef uri);
  public: bool t_writeelementns(CStrRef prefix, CStrRef name, CStrRef uri, CStrRef content = null_string);
  public: bool t_writeelement(CStrRef name, CStrRef content = null_string);
  public: bool t_endelement();
  public: bool t_fullendelement();
  public: bool t_startattributens(CStrRef prefix, CStrRef name, CStrRef uri);
  public: bool t_startattribute(CStrRef name);
  public: bool t_writeattributens(CStrRef prefix, CStrRef name, CStrRef uri, CStrRef content);
  public: bool t_writeattribute(CStrRef name, CStrRef value);
  public: bool t_endattribute();
  public: bool t_startcdata();
  public: bool t_writecdata(CStrRef content);
  public: bool t_endcdata();
  public: bool t_startcomment();
  public: bool t_writecomment(CStrRef content);
  public: bool t_endcomment();
  public: bool t_enddocument();
  public: bool t_startpi(CStrRef target);
  public: bool t_writepi(CStrRef target, CStrRef content);
  public: bool t_endpi();
  public: bool t_text(CStrRef content);
  public: bool t_writeraw(CStrRef content);
  public: bool t_startdtd(CStrRef qualifiedname, CStrRef publicid = null_string, CStrRef systemid = null_string);
  public: bool t_writedtd(CStrRef name, CStrRef publicid = null_string, CStrRef systemid = null_string, CStrRef subset = null_string);
  public: bool t_startdtdelement(CStrRef qualifiedname);
  public: bool t_writedtdelement(CStrRef name, CStrRef content);
  public: bool t_enddtdelement();
  public: bool t_startdtdattlist(CStrRef name);
  public: bool t_writedtdattlist(CStrRef name, CStrRef content);
  public: bool t_enddtdattlist();
  public: bool t_startdtdentity(CStrRef name, bool isparam);
  public: bool t_writedtdentity(CStrRef name, CStrRef content, bool pe = false, CStrRef publicid = null_string, CStrRef systemid = null_string, CStrRef ndataid = null_string);
  public: bool t_enddtdentity();
  public: bool t_enddtd();
  public: Variant t_flush(bool empty = true);
  public: String t_outputmemory(bool flush = true);



 public:
  SmartResource<File>  m_uri;
 private:
  xmlTextWriterPtr   m_ptr;
  xmlBufferPtr       m_output;
  xmlOutputBufferPtr m_uri_output;
};

///////////////////////////////////////////////////////////////////////////////
}

#endif // incl_HPHP_EXT_XMLWRITER_H_
