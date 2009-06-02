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
    name      = "xump_queue"
    comment   = "Xump queue class"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The xump_queue class references a queue resource held in a storage layer.
This class implements the create/fetch/update/delete access methods on
the queue.
</doc>

<inherit class = "icl_object">
    <option name = "alloc"  value = "cache" />
</inherit>

<import class = "asl" />
<import class = "xump" />

<context>
    xump_store_t
        *store;
    <property name = "name" type = "char *" />
</context>

<method name = "new">
    <argument name = "store" type = "xump_store_t *">Enclosing store</argument>
    <argument name = "name" type = "char *">Queue name, if any</argument>
    //
    self->store = xump_store_link (store);
    xump_queue_set_name (self, name);
</method>

<method name = "destroy">
    xump_store_unlink (&self->store);
    icl_mem_free (self->name);
</method>

<method name = "create" template = "function">
    rc = xump_store_request_queue_create (self->store, self);
</method>

<method name = "fetch" template = "function">
    rc = xump_store_request_queue_fetch (self->store, self);
</method>

<method name = "update" template = "function">
    rc = xump_store_request_queue_update (self->store, self);
</method>

<method name = "delete" template = "function">
    rc = xump_store_request_queue_delete (self->store, self);
</method>

<method name = "selftest" />

</class>
