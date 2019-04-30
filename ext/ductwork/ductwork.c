#include <ruby.h>
#include <ruby/thread.h>
#include "ductwork.h"

#ifndef _WIN32
#include <errno.h>
#include <unistd.h>
#endif

#define UNWRAP() \
dw_instance *dw; \
TypedData_Get_Struct(self, dw_instance, &dw_type, dw)

#define UNWRAP_PARENT() \
dw_instance *dw; \
TypedData_Get_Struct(parent, dw_instance, &dw_type, dw)

typedef struct _dw_open_param {
  dw_instance *dw;
  int timeout;
  bool result;
} _dw_open_param;

VALUE Ductwork;
VALUE Base;
VALUE TimeoutError;
VALUE Server;
VALUE Client;
VALUE Pipe;
ID PipeParentId;

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

void *_ductwork_open(_dw_open_param *param) {
  param->result = dw_open_pipe(param->dw, param->timeout);
  return NULL;
}

/*
 * Base
 */

static VALUE ductwork_base_init(VALUE self, VALUE path) {
  Check_Type(path, T_STRING);
  const char *strPath = StringValueCStr(path);

  UNWRAP();
  dw_set_path(dw, strPath);

  return self;
}

static VALUE ductwork_base_open(int argc, VALUE *argv, VALUE self) {
  VALUE timeout;
  bool timeoutPassed = rb_scan_args(argc, argv, "01", &timeout);
  int intTimeout = -1;

  if (timeoutPassed) {
    Check_Type(timeout, T_FIXNUM);
    intTimeout = FIX2INT(timeout);
  }

  UNWRAP();
  _dw_open_param param = { .dw = dw, .timeout = intTimeout };
  
  rb_thread_call_without_gvl(
    (void *(*)(void *))_ductwork_open, 
    &param, 
    NULL, // TODO: make open interuptable
    NULL
  );

  if (!param.result) {
    rb_raise(TimeoutError, "%s", "Open timed out");
    return Qnil;
  }
  else if (dw_get_fd(dw) < 1) {
    rb_raise(rb_eIOError, "%s %s", dw_get_last_error(dw), dw_get_full_path(dw));
    return Qnil;
  }

  return rb_funcall(Pipe, rb_intern("new"), 1, self);
}

static VALUE ductwork_base_close(VALUE self) {
  UNWRAP();
  dw_close_pipe(dw);
  return Qnil;
}

static VALUE ductwork_base_path(VALUE self) {
  UNWRAP();
  return rb_str_new_cstr(dw_get_full_path(dw));
}

static VALUE ductwork_base_is_open(VALUE self) {
  UNWRAP();
  return dw_get_fd(dw) == -1 ? Qfalse : Qtrue;
}

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
  UNWRAP();  
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
 * Pipe
 */

static VALUE ductwork_pipe_init(VALUE self, VALUE dw_obj) {
  rb_ivar_set(self, PipeParentId, dw_obj);
  return self;
}

static VALUE ductwork_pipe_class_read(VALUE self, VALUE length) {
  // TODO: read
  return Qnil;
}

static VALUE ductwork_pipe_class_write(VALUE self, VALUE str) {
  // TODO: write
  return Qnil;
}

static VALUE ductwork_pipe_read(VALUE self, VALUE length) {
  VALUE parent = rb_ivar_get(self, PipeParentId);
  size_t lengthInt = rb_num2long(length);
  UNWRAP_PARENT();
  char *buffer = (char *)malloc(lengthInt);

#ifndef _WIN32
  size_t result = read(dw_get_fd(dw), buffer, lengthInt);
#endif

  if (result < 0) {
    // TODO: raise error properly
    printf("\nREAD ERROR\n\n");
    return 0;
  }

  return rb_str_new_cstr(buffer);
}

static VALUE ductwork_pipe_write(VALUE self, VALUE str) {
  VALUE parent = rb_ivar_get(self, PipeParentId);
  const char *cStr = StringValuePtr(str);
  UNWRAP_PARENT();

#ifndef _WIN32
  size_t result = write(dw_get_fd(dw), cStr, RSTRING_LEN(str));
#endif

  if (result < 0) {
    // TODO: raise error properly
    printf("\nWRITE ERROR\n\n");
  }

  return Qnil;
}

/*
 * Ruby
*/

// TODO: create base class
void Init_ductwork(void) {
  PipeParentId = rb_intern("@parent");

  Ductwork = rb_define_module("Ductwork");

  TimeoutError = 
    rb_define_class_under(Ductwork, "TimeoutError", rb_eRuntimeError);

  Base = rb_define_class_under(Ductwork, "Base", rb_cObject);
  rb_define_method(Base, "initialize", ductwork_base_init, 1);
  rb_define_method(Base, "open", ductwork_base_open, -1);
  rb_define_method(Base, "close", ductwork_base_close, 0);
  rb_define_method(Base, "path", ductwork_base_path, 0);
  rb_define_method(Base, "open?", ductwork_base_is_open, 0);

  Server = rb_define_class_under(Ductwork, "Server", Base);
  rb_define_alloc_func(Server, ductwork_server_allocate);
  rb_define_method(Server, "create", ductwork_server_create, 1);

  Client = rb_define_class_under(Ductwork, "Client", Base);
  rb_define_alloc_func(Client, ductwork_client_allocate);
  
  Pipe = rb_define_class_under(Ductwork, "Pipe", rb_cObject);
  rb_define_singleton_method(Ductwork, "read", ductwork_pipe_class_read, 1);
  rb_define_singleton_method(Ductwork, "write", ductwork_pipe_class_write, 1);
  rb_define_method(Pipe, "initialize", ductwork_pipe_init, 1);
  rb_define_method(Pipe, "read", ductwork_pipe_read, 1);
  rb_define_method(Pipe, "write", ductwork_pipe_write, 1);
}
