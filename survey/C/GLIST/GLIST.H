struct lnode {
  void *data;
  struct lnode *next,*prior;
};

struct list {
  struct lnode *head,*current;
};

typedef struct list *glist;
typedef void (*voidfunctionptr)();

glist createlist();
void destroylist(glist);
void applyall(voidfunctionptr,glist);
void applycurrent(voidfunctionptr,glist);
int seek(char*,glist);
int insert(void*,glist);
int delete(glist);
int empty(glist);

