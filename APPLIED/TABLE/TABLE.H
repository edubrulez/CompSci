#ifndef TABLE_H_INCLUDED
#define TABLE_H_INCLUDED
 
typedef struct {   /* generic table record                         */
  char *key;       /* pointer to key                               */
  void *data;      /* pointer to hash data item (any data type ok) */
} TableRecord;
 
typedef struct {
  int tsize;           /* number of buckets in the hash table       */
  TableRecord *data;    /* pointer to malloc'ed array of TableRecords */
} Table;
 
/* return codes for TInsert */
#define OK 0
#define DUP 1
#define FULL 2
 
void TCreate(Table*,  /* pointer to an uninitialized table */
             int);    /* number of slots to allocate       */
 
int TInsert(Table,    /* table in which insertion is made       */
            char*,    /* ptr to key field in inserted record    */
            void*);   /* ptr to data to be inserted             */
 
TableRecord *TRetrieve(Table,   /* table to be searched            */
                      char*);   /* key to search for               */
 
#endif
