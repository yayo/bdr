/*-------------------------------------------------------------------------
 *
 * typecmds.h
 *	  prototypes for typecmds.c.
 *
 *
 * Portions Copyright (c) 1996-2015, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 * src/include/commands/typecmds.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef TYPECMDS_H
#define TYPECMDS_H

#include "access/htup.h"
#include "catalog/dependency.h"
#include "nodes/parsenodes.h"


#define DEFAULT_TYPDELIM		','

extern Oid	DefineType(List *names, List *parameters);
extern void RemoveTypeById(Oid typeOid);
extern Oid	DefineDomain(CreateDomainStmt *stmt);
extern Oid	DefineEnum(CreateEnumStmt *stmt);
extern Oid	DefineRange(CreateRangeStmt *stmt);
extern Oid	AlterEnum(AlterEnumStmt *stmt, bool isTopLevel);
extern Oid	DefineCompositeType(RangeVar *typevar, List *coldeflist);
extern Oid	AssignTypeArrayOid(void);

extern ObjectAddress AlterDomainDefault(List *names, Node *defaultRaw);
extern ObjectAddress AlterDomainNotNull(List *names, bool notNull);
extern ObjectAddress AlterDomainAddConstraint(List *names, Node *constr);
extern ObjectAddress AlterDomainValidateConstraint(List *names, char *constrName);
extern ObjectAddress AlterDomainDropConstraint(List *names, const char *constrName,
						  DropBehavior behavior, bool missing_ok);

extern void checkDomainOwner(HeapTuple tup);

extern List *GetDomainConstraints(Oid typeOid);

extern ObjectAddress RenameType(RenameStmt *stmt);
extern Oid	AlterTypeOwner(List *names, Oid newOwnerId, ObjectType objecttype);
extern void AlterTypeOwnerInternal(Oid typeOid, Oid newOwnerId,
					   bool hasDependEntry);
extern Oid	AlterTypeNamespace(List *names, const char *newschema, ObjectType objecttype);
extern Oid	AlterTypeNamespace_oid(Oid typeOid, Oid nspOid, ObjectAddresses *objsMoved);
extern Oid AlterTypeNamespaceInternal(Oid typeOid, Oid nspOid,
						   bool isImplicitArray,
						   bool errorOnTableType,
						   ObjectAddresses *objsMoved);

#endif   /* TYPECMDS_H */
