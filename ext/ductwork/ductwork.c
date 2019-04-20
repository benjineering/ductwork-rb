#include <ruby.h>
#include "ductwork.h"

VALUE Ductwork;
VALUE TimeoutError;
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

/*
 * Server
*/

// TODO: allocate within the init function and get rid of path setter
static VALUE ductwork_server_allocate(VALUE klass) {
  return TypedData_Wrap_Struct(klass, &dw_type, dw_init(
    DW_SERVER_TYPE,
    NULL,
    NULL
  ));
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
    NULL
  ));
}

/*
 * Shared
 */

static VALUE ductwork_init(VALUE self, VALUE path) {
  Check_Type(path, T_STRING);
  const char *strPath = StringValueCStr(path);

  dw_instance *dw;
  TypedData_Get_Struct(self, dw_instance, &dw_type, dw);
  dw_set_path(dw, strPath);

  return self;
}

static VALUE ductwork_open(int argc, VALUE *argv, VALUE self) {
  VALUE timeout;
  bool timeoutPassed = rb_scan_args(argc, argv, "01", &timeout);
  int intTimeout = -1;

  if (timeoutPassed) {
    Check_Type(timeout, T_FIXNUM);
    intTimeout = FIX2INT(timeout);
  }

  dw_instance *dw;
  TypedData_Get_Struct(self, dw_instance, &dw_type, dw);

  bool openOk = dw_open_pipe(dw, intTimeout);

  if (!openOk) {
    rb_raise(TimeoutError, "%s", "Open timed out");
    return Qnil;
  }
  else if (dw_get_fd(dw) == -1) {
    rb_raise(rb_eIOError, "%s %s", dw_get_last_error(dw), dw_get_full_path(dw));
    return Qnil;
  }

  return rb_funcall(rb_cIO, rb_intern("new"), 1, dw_get_fd(dw));
}

static VALUE ductwork_path(VALUE self) {
  dw_instance *dw;
  TypedData_Get_Struct(self, dw_instance, &dw_type, dw);
  return rb_str_new_cstr(dw_get_full_path(dw));
}

/*
 * Ruby
*/

// TODO: create base class
void Init_ductwork(void) {
  Ductwork = rb_define_module("Ductwork");

  TimeoutError = 
    rb_define_class_under(Ductwork, "TimeoutError", rb_eRuntimeError);

  Server = rb_define_class_under(Ductwork, "Server", rb_cObject);
  rb_define_alloc_func(Server, ductwork_server_allocate);
  rb_define_method(Server, "initialize", ductwork_init, 1);
  rb_define_method(Server, "create", ductwork_server_create, 1);
  rb_define_method(Server, "open", ductwork_open, -1);
  rb_define_method(Server, "path", ductwork_path, 0);

  Client = rb_define_class_under(Ductwork, "Client", rb_cObject);
  rb_define_alloc_func(Client, ductwork_client_allocate);
  rb_define_method(Client, "initialize", ductwork_init, 1);
  rb_define_method(Client, "open", ductwork_open, -1);
  rb_define_method(Client, "path", ductwork_path, 0);
}
