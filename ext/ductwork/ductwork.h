#ifndef DUCTWORK_H
#define DUCTWORK_H

#ifndef _WIN32
#define _POSIX_C_SOURCE 200809L
#endif

#define DW_FULL_PATH_SIZE 4096

#ifndef bool
typedef int bool;
#define true 1
#define false 0
#endif

#ifdef _WIN32
#define DW_PATH_PREFIX "//.pipe"
#endif

typedef struct dw_instance dw_instance;
typedef struct dw_thread_info dw_thread_info;

enum dw_instance_type {
  DW_SERVER_TYPE,
  DW_CLIENT_TYPE
};

dw_instance *dw_init(
  enum dw_instance_type type,
  const char *requestedPath,
  void (*errorHandler)(const char * message),
  void *userData);

void dw_free(dw_instance *dw);

bool dw_create_pipe(dw_instance *dw, int defaultTimeoutMs);

bool dw_open_pipe(dw_instance *dw, int overrideTimeoutMs);

void dw_close_pipe(dw_instance *dw);

const char *dw_get_full_path(dw_instance *dw);

void dw_set_path(dw_instance *dw, const char *path);

int dw_get_fd(dw_instance *dw);

void *dw_get_user_data(dw_instance *dw);

void dw_set_user_data(dw_instance *dw, void *userData);

enum dw_instance_type dw_get_type(dw_instance *dw);

#endif
