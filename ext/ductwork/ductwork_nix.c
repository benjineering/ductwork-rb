#include "ductwork.h"
#include "ductwork_nix.h"
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

struct dw_instance {
  enum dw_instance_type type;
  void *userData;
  const char *path;
  const char fullPath[DW_FULL_PATH_SIZE];
  void (*errorHandler)(const char * message);
  dw_thread_info *openThread;
  int defaultTimeoutMs;
  int fd;
};

struct dw_thread_info {
  pthread_t thread;
  pthread_cond_t condition;
  pthread_mutex_t mutex;
};

const mode_t CREATE_PERMS = S_IRUSR | S_IWUSR;
const mode_t READ_PERMS = S_IRUSR | O_RDONLY;
const mode_t WRITE_PERMS = S_IWUSR | O_WRONLY;
const char *ERROR_SEP = ": ";

char *get_error_str(int errorNum) {
  return strerror(errorNum);
}

char *get_last_error_str() {
  return get_error_str(errno);
}

void throw_error(dw_instance *dw, const char *message, const char *innerMsg) {
  if (innerMsg == NULL) {
    dw->errorHandler(message);
    return;
  }

  size_t len = strlen(message) + strlen(ERROR_SEP) + strlen(innerMsg) + 1;
  char *str = (char *)malloc(len);
  memset(str, '\0', len);
  strcpy(str, message);
  strcat(str, ERROR_SEP);
  strcat(str, innerMsg);

  dw->errorHandler(str);
  free(str);
}

void throw_last_error(dw_instance *dw, const char *message) {
  throw_error(dw, message, get_last_error_str());
}

void *open_async(dw_instance *dw) {
  int perms = dw->type == DW_SERVER_TYPE ? WRITE_PERMS : READ_PERMS;
  dw->fd = open(dw->fullPath, perms);

  if (dw->fd)
    throw_last_error(dw, "Error opening file");  

  pthread_cond_signal(&dw->openThread->condition);
  return NULL;
}

////////////////////////////////////////////////////////////////////////////////

dw_instance *dw_init(
  enum dw_instance_type type,
  const char *requestedPath,
  void (*errorHandler)(const char * message),
  void *userData
) {
  dw_instance *dw = (dw_instance *)malloc(sizeof(dw_instance));
  dw->errorHandler = errorHandler;
  dw->type = type;
  dw->userData = userData;

  dw->openThread = (dw_thread_info *)malloc(sizeof(dw_thread_info));
  pthread_cond_init(&dw->openThread->condition, NULL);
  pthread_mutex_init(&dw->openThread->mutex, NULL);

  if (requestedPath && (strlen(requestedPath) + 1) > DW_FULL_PATH_SIZE) {
    throw_last_error(dw, "Full path buffer overrun");
    return NULL;
  }

  dw_set_path(dw, requestedPath);
  return dw;
}

void dw_free(dw_instance *dw) {
  free(dw->openThread);
  free(dw);
}

bool dw_create_pipe(dw_instance *dw, int defaultTimeoutMs) {
  if (dw->type == DW_CLIENT_TYPE) {
    throw_last_error(dw, "Only a DW_SERVER_TYPE can create a pipe");
    return false;
  }

  dw->defaultTimeoutMs = defaultTimeoutMs;
  int result = mkfifo(dw->fullPath, CREATE_PERMS);

  if (result < 0) {
    throw_last_error(dw, "Couldn't create the pipe");
    return false;
  }

  return true;
}

bool dw_open_pipe(dw_instance *dw, int overrideTimeoutMs) {
  struct timespec timeout;
  int timeoutMs = overrideTimeoutMs > -1 
    ? overrideTimeoutMs : dw->defaultTimeoutMs;
  clock_gettime(CLOCK_REALTIME, &timeout);
  dw_add_ms(&timeout, timeoutMs);

  pthread_create(
    &dw->openThread->thread, 
    NULL, 
    (void *(*)(void *))open_async, 
    (void *)dw
  );

  // TODO: better mutexing
  pthread_mutex_lock(&dw->openThread->mutex);

  int waitResult = pthread_cond_timedwait(
    &dw->openThread->condition, 
    &dw->openThread->mutex, 
    &timeout
  );

  pthread_mutex_unlock(&dw->openThread->mutex);

  if (waitResult == ETIMEDOUT) {
    pthread_cancel(dw->openThread->thread);
    dw->fd = -1;
    return false;
  }

  return true;
}

void dw_close_pipe(dw_instance *dw) {
  close(dw->fd);
}

const char *dw_get_full_path(dw_instance *dw) {
  return dw->fullPath;
}

void dw_set_path(dw_instance *dw, const char *path) {
  if (path) {
    dw->path = path;
    strcpy((char *)dw->fullPath, dw->path);
  }
}

int dw_get_fd(dw_instance *dw) {
  return dw->fd;
}

void *dw_get_user_data(dw_instance *dw) {
  return dw->userData;
}

void dw_set_user_data(dw_instance *dw, void *userData) {
  dw->userData = userData;
}

enum dw_instance_type dw_get_type(dw_instance *dw) {
  return dw->type;
}

void dw_add_ms(struct timespec *time, int ms) {
  if (ms < 1000) {
    time->tv_nsec += ms * 1000;
  }
  else {
    // TODO: this more efficiently
    int secs = ms / 1000;
    time->tv_sec += secs;
    time->tv_nsec += (ms - (secs * 1000)) * 1000;
  }
}
