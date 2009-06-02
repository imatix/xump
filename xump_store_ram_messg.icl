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

<import class = "asl" />
<import class = "xump" />

<context>
    ipr_looseref_list_t
        *messages;                      //  List of messages
    <property name = "name" type = "char *" />
</context>

<method name = "new">
    <argument name = "name" type = "char *" />
    //
    icl_console_print ("I: creating RAM queue '%s'", name);
    self->messages = ipr_looseref_list_new ();
    self_set_name (self, name);
</method>

<method name = "destroy">
    //while ((message = (xump_message_t *) ipr_looseref_pop (self->messages)))
    //  xump_message_destroy (&message);
    icl_console_print ("I: deleting RAM queue '%s'", self->name);
    ipr_looseref_list_destroy (&self->messages);
    icl_mem_free (self->name);
</method>

<method name = "selftest">
    xump_store_ram_queue_t
        *queue;

    queue = xump_store_ram_queue_new ("queue 1");
    xump_store_ram_queue_destroy (&queue);
</method>

</class>
