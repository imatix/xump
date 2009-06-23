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
    name      = "xump_store_ram_queue"
    comment   = "Xump queue class for RAM storage layer"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The RAM storage layer uses this class to implement queues.  A queue has
a name, and a list of messages.
</doc>

<inherit class = "icl_object">
    <option name = "alloc"  value = "cache" />
</inherit>

<import class = "xump" />

<context>
    ipr_looseref_list_t
        *messages;                      //  List of messages
    size_t
        message_id;                     //  Last issued message ID
    <property name = "name" type = "char *" />
    <property name = "message count" type = "size_t" readonly = "1" />
</context>

<method name = "new">
    <argument name = "name" type = "char *" />
    //
    self->messages = ipr_looseref_list_new ();
    self->name = icl_mem_strdup (name);
</method>

<method name = "destroy">
    <local>
    xump_store_ram_message_t
        *message;
    </local>
    //
    while ((message = (xump_store_ram_message_t *) ipr_looseref_pop (self->messages)))
        xump_store_ram_message_destroy (&message);
    ipr_looseref_list_destroy (&self->messages);
    icl_mem_free (self->name);
</method>

<method name = "put message" template = "function">
    <doc>
    Attaches a message to the tail of the queue.  Stamps the message with a
    new unique id value.
    </doc>
    <argument name = "message" type = "xump_store_ram_message_t *" />
    //
    xump_store_ram_message_set_id (message, ++self->message_id);
    ipr_looseref_queue (self->messages, message);
    self->message_count++;
</method>

<method name = "get message" template = "function">
    <doc>
    Fetches the specified message relative to the queue head.  Returns 0 and
    sets message_p if ok, returns -1 and sets message_p to NULL if no such
    message.  iCL lists start at the head and end at the tail.
    </doc>
    <argument name = "message_p" type = "xump_store_ram_message_t **" />
    <argument name = "index" type = "size_t" />
    <local>
    ipr_looseref_t
        *looseref;
    </local>
    //
    looseref = ipr_looseref_list_first (self->messages);
    while (index-- && looseref)
        looseref = ipr_looseref_list_next (&looseref);

    if (looseref)
        *message_p = (xump_store_ram_message_t *) (looseref->object);
    else {
        *message_p = NULL;
        rc = -1;
    }
</method>

<method name = "find message" template = "function">
    <doc>
    Locates the message specified by id.  Returns 0 and sets message_p if ok,
    returns -1 and sets message_p to NULL if no such message.  This version
    does a simple scan of all the list from the head.
    </doc>
    <argument name = "message_p" type = "xump_store_ram_message_t **" />
    <argument name = "id" type = "size_t" />
    <local>
    ipr_looseref_t
        *looseref;
    </local>
    //
    looseref = ipr_looseref_list_first (self->messages);
    while (looseref) {
        xump_store_ram_message_t
            *message;
        message = (xump_store_ram_message_t *) (looseref->object);
        if (xump_store_ram_message_id (message) == id) {
            *message_p = message;
            break;
        }
        else
            looseref = ipr_looseref_list_next (&looseref);
    }
    if (!looseref) {
        *message_p = NULL;
        rc = -1;
    }
</method>

<method name = "delete message" template = "function">
    <doc>
    Deletes the message specified by id.  Returns 0 if the message was
    deleted, else returns -1.  This version does a simple scan of all the
    list from the head.
    </doc>
    <argument name = "id" type = "size_t" />
    <local>
    ipr_looseref_t
        *looseref;
    </local>
    //
    rc = -1;                            //  Assume we don't find message
    looseref = ipr_looseref_list_first (self->messages);
    while (looseref) {
        xump_store_ram_message_t
            *message;
        message = (xump_store_ram_message_t *) (looseref->object);
        if (xump_store_ram_message_id (message) == id) {
            ipr_looseref_destroy (&looseref);
            xump_store_ram_message_destroy (&message);
            self->message_count--;
            rc = 0;                     //  Found, and deleted
            break;
        }
        else
            looseref = ipr_looseref_list_next (&looseref);
    }
</method>

<method name = "selftest" />

</class>
