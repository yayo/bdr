/*
 * bdr_common.c
 *
 * BiDirectionalReplication
 *
 * Utility functions that can be share between extension and cli
 * (don't require server side libraries).
 *
 * Copyright (c) 2015, PostgreSQL Global Development Group
 *
 * bdr_common.c
 */


#include "postgres.h"

#include "access/xlogdefs.h"
#include "nodes/pg_list.h"

#include "bdr_internal.h"


/*
 * Format slot name string from node identifiers.
 */
void
bdr_slot_name(Name slot_name, uint64 sysid, TimeLineID tlid,
			  Oid dboid, Oid local_dboid)
{
	snprintf(NameStr(*slot_name), NAMEDATALEN, BDR_SLOT_NAME_FORMAT,
			 local_dboid, sysid, tlid, dboid,
			 EMPTY_REPLICATION_NAME);
	NameStr(*slot_name)[NAMEDATALEN-1] = '\0';
}
