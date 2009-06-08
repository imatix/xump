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
        queue_name;
    xump_store_ram_queue_t
        *ram_queue;
    </local>
    //
    assert (queue_p);
    //  If queue is unnamed, invent a unique random name now
    if (name)
        icl_shortstr_cpy (queue_name, name);
    else
        do {
            ipr_str_random (queue_name, "Q-AAAAAA");
        } until (ipr_hash_lookup (self->queues, queue_name) == NULL);

    //  Either create or fetch RAM queue
    ram_queue = ipr_hash_lookup (self->queues, queue_name);
    if (ram_queue == NULL) {
        ram_queue = xump_store_ram_queue_new (queue_name);
        ipr_hash_insert (self->queues, queue_name, ram_queue);
    }
    //  Create queue object for caller
    *queue_p = xump_queue_new (portal, queue_name);
</method>

<method name = "queue fetch">
    <local>
    xump_store_ram_queue_t
        *ram_queue;
    </local>
    //
    assert (queue_p);
    ram_queue = ipr_hash_lookup (self->queues, name);
    if (ram_queue)
        *queue_p = xump_queue_new (portal, name);
    else {
        *queue_p = NULL;
        rc = -1;
    }
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
    assert (message_p);
    ram_queue = ipr_hash_lookup (self->queues, xump_queue_name (queue));
    if (ram_queue) {
        ram_message = xump_store_ram_message_new (address, body_data, body_size);
        xump_store_ram_queue_put_message (ram_queue, ram_message);
        *message_p = xump_message_new (queue, address, body_data, body_size);
        xump_message_set_id (*message_p, xump_store_ram_message_id (ram_message));
        icl_console_print ("I: creating message '%s' (%d)",
            xump_message_address (*message_p), xump_message_id (*message_p));
    }
    else {
        *message_p = NULL;
        rc = -1;                        //  Error - no such queue
    }
</method>

<method name = "message fetch">
    <local>
    xump_store_ram_queue_t
        *ram_queue;
    xump_store_ram_message_t
        *ram_message;
    </local>
    //
    assert (queue);
    assert (message_p);
    ram_queue = ipr_hash_lookup (self->queues, xump_queue_name (queue));
    if (ram_queue
    &&  xump_store_ram_queue_get_message (ram_queue, &ram_message, index) == 0) {
        *message_p = xump_message_new (queue,
            xump_store_ram_message_address   (ram_message),
            xump_store_ram_message_body_data (ram_message),
            xump_store_ram_message_body_size (ram_message));
        xump_message_set_id (*message_p, xump_store_ram_message_id (ram_message));

        icl_console_print ("I: fetching message '%s' (%d)",
            xump_message_address (*message_p), xump_message_id (*message_p));
    }
    else {
        *message_p = NULL;
        rc = -1;                        //  Error - no such queue
    }
</method>

<method name = "message delete">
    <local>
    xump_store_ram_queue_t
        *ram_queue;
    xump_store_ram_message_t
        *ram_message;
    </local>
    //
    assert (message);
    ram_queue = ipr_hash_lookup (self->queues, xump_queue_name (xump_message_queue (message)));
    if (ram_queue) {
        xump_store_ram_queue_delete_message (ram_queue, xump_message_id (message));
        icl_console_print ("I: deleting message '%s' (%d)",
            xump_message_address (message), xump_message_id (message));
    }
    else
        rc = -1;                        //  Error - no such queue
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
