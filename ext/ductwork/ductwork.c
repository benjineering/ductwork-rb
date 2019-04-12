#include <ruby.h>
#include "ductwork_native.h"

VALUE Ductwork;
VALUE Server;

static void error_handler(const char *message) {
  rb_raise(rb_eRuntimeError, "%s", message);
}

static void ductwork_free(void *p) {
  dw_free((dw_instance *)p);
}

static VALUE ductwork_server_init(VALUE self, VALUE path) {
  dw_instance *dw = dw_init(
    DW_SERVER_TYPE,
    StringValuePtr(path),
    error_handler,
    NULL
  );

  return Data_Wrap_Struct(Server, NULL, ductwork_free, dw);
}

void Init_ductwork(void) {
  Ductwork = rb_define_module("Ductwork");
  Server = rb_define_class_under(Ductwork, "Server", rb_cObject);
  rb_define_method(Server, "initialize", ductwork_server_init, 1);
}
