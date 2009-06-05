<?xml?>
<!--
    Copyright (c) 1996-2009 iMatix Corporation

    This file is licensed under the GPL as follows:

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or (at
    your option) any later version.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    For information on alternative licensing for OEMs, please contact
    iMatix Corporation.
 -->
<class
    name      = "xump_store_ram"
    comment   = "Xump RAM store back-end"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
This class implements a RAM-based storage layer.  Queues and messages are
local to the Xump engine instance and are destroyed when the engine or the
portal to this back-end are destroyed.  Queues are implemented via the
xump_store_ram_queue.icl class, and messages are implemented via the
xump_store_ram_messg.icl class.
</doc>

<inherit class = "xump_store_back" />

<context>
    ipr_hash_table_t
        *queues;                        //  Queues that store contains
</context>

<method name = "new">
    self->queues = ipr_hash_table_new ();
</method>

<method name = "destroy">
    ipr_hash_table_apply (self->queues, s_destroy_queue, NULL);
    ipr_hash_table_destroy (&self->queues);
</method>

<method name = "announce">
    icl_console_print ("I: initializing RAM-based storage instance '%s'", portal->name);
</method>

<method name = "queue create">
    <local>
    icl_shortstr_t
        name;
    xump_store_ram_queue_t
        *ram_queue;
    </local>
    //
    assert (queue);
    //  If queue is unnamed, invent a unique random name now
    if (xump_queue_name (queue) == NULL) {
        do {
            ipr_str_random (name, "Q-AAAAAA");
        } until (ipr_hash_lookup (self->queues, name) == NULL);
        xump_queue_set_name (queue, name);
    }
    //  Now either create or fetch queue
    ram_queue = ipr_hash_lookup (self->queues, xump_queue_name (queue));
    if (ram_queue == NULL) {
        ram_queue = xump_store_ram_queue_new (queue);
        ipr_hash_insert (self->queues, xump_queue_name (queue), ram_queue);
    }
    xump_queue_set_name (queue, xump_store_ram_queue_name (ram_queue));
</method>

<method name = "queue fetch">
    <local>
    xump_store_ram_queue_t
        *ram_queue;
    </local>
    //
    assert (queue);
    ram_queue = ipr_hash_lookup (self->queues, xump_queue_name (queue));
    if (!ram_queue)
        rc = -1;
</method>

<method name = "queue delete">
    <local>
    xump_store_ram_queue_t
        *ram_queue;
    </local>
    //
    assert (queue);
    ram_queue = ipr_hash_lookup (self->queues, xump_queue_name (queue));
    if (ram_queue) {
        xump_store_ram_queue_destroy (&ram_queue);
        ipr_hash_delete (self->queues, xump_queue_name (queue));
    }
</method>

<method name = "message create">
    <local>
    xump_store_ram_queue_t
        *ram_queue;
    xump_store_ram_message_t
        *ram_message;
    </local>
    //
    assert (queue);
    assert (message);
    ram_queue = ipr_hash_lookup (self->queues, xump_queue_name (queue));
    if (ram_queue) {
        ram_message = xump_store_ram_message_new (message);
        xump_store_ram_queue_accept (ram_queue, ram_message);
    }
    else
        rc = -1;                        //  Error - no such queue
</method>

<method name = "message fetch">
</method>

<method name = "message update">
</method>

<method name = "message delete">
</method>

<private name = "header">
static void
    s_destroy_queue (ipr_hash_t *hash, void *argument);
</private>

<private name = "footer">
static void
s_destroy_queue (ipr_hash_t *hash, void *argument)
{
    xump_store_ram_queue_t
        *queue;

    queue = hash->data;
    xump_store_ram_queue_destroy (&queue);
}
</private>

</class>
