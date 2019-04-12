#include <ruby.h>
#include "ductwork_native.h"

VALUE Ductwork;
VALUE Server;
VALUE Client;

static void ductwork_free(void *p) {
  dw_free((dw_instance *)p);
}

static size_t ductwork_size(const void* data) {
	return 1;
}

static const rb_data_type_t dw_type = {
	.wrap_struct_name = "dw_type",
	.function = { .dmark = NULL, .dfree = ductwork_free, .dsize = ductwork_size },
	.data = NULL,
	.flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static void error_handler(const char *message) {
  rb_raise(rb_eRuntimeError, "%s", message);
}

/*
 * Server
*/

static VALUE ductwork_server_allocate(VALUE klass) {
  return TypedData_Wrap_Struct(klass, &dw_type, dw_init(
    DW_SERVER_TYPE,
    NULL,
    error_handler,
    NULL
  ));
}

static VALUE ductwork_server_init(VALUE self, VALUE path) {
  Check_Type(path, T_STRING);
  const char *strPath = StringValueCStr(path);

  dw_instance *dw;
  TypedData_Get_Struct(self, dw_instance, &dw_type, dw);
  dw_set_path(dw, strPath);

  return self;
}

static VALUE ductwork_server_create(VALUE self, VALUE timeout) {
  Check_Type(timeout, T_FIXNUM);
  int intTimeout = FIX2INT(timeout);

  dw_instance *dw;
  TypedData_Get_Struct(self, dw_instance, &dw_type, dw);
  
  dw_create_pipe(dw, intTimeout);
  return Qnil;
}

/*
 * Client
*/

static VALUE ductwork_client_allocate(VALUE klass) {
  return TypedData_Wrap_Struct(klass, &dw_type, dw_init(
    DW_CLIENT_TYPE,
    NULL,
    error_handler,
    NULL
  ));
}

static VALUE ductwork_client_init(VALUE self, VALUE path) {
  Check_Type(path, T_STRING);

  dw_instance *dw = dw_init(
    DW_CLIENT_TYPE,
    StringValuePtr(path),
    error_handler,
    NULL
  );

  return TypedData_Wrap_Struct(Client, &dw_type, dw);
}

/*
 * Ruby
*/

void Init_ductwork(void) {
  Ductwork = rb_define_module("Ductwork");

  Server = rb_define_class_under(Ductwork, "Server", rb_cObject);
  rb_define_alloc_func(Server, ductwork_server_allocate);
  rb_define_method(Server, "initialize", ductwork_server_init, 1);
  rb_define_method(Server, "create", ductwork_server_create, 1);

  Client = rb_define_class_under(Ductwork, "Client", rb_cObject);
  rb_define_alloc_func(Client, ductwork_client_allocate);
  rb_define_method(Client, "initialize", ductwork_client_init, 1);
}
