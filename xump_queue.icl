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
This class implements the create/fetch/delete access methods on the queue.
</doc>

<inherit class = "icl_object">
    <option name = "alloc" value = "cache" />
    <option name = "links" value = "1" />
</inherit>

<import class = "xump" />

<context>
    int64_t
        last_id;
    <property name = "store" type = "xump_store_t *" readonly = "1" />
    <property name = "name" type = "char *" />
</context>

<method name = "new">
    <argument name = "store" type = "xump_store_t *">Enclosing store</argument>
    <argument name = "name" type = "char *">Queue name, if any</argument>
    //
    self->store = xump_store_link (store);
    self->name = icl_mem_strdup (name);
</method>

<method name = "destroy" private = "1">
    xump_store_unlink (&self->store);
    icl_mem_free (self->name);
</method>

<method name = "create" return = "self">
    <doc>
    This public method creates or fetches a queue in the store.  It acts
    as a constructor and returns a new queue object when successful.  The
    caller must unlink this queue object when finished using it.
    </doc>
    <argument name = "store" type = "xump_store_t *">Enclosing store</argument>
    <argument name = "name" type = "char *">Queue name, if any</argument>
    <declare name = "self" type = "$(selftype) *" />
    //
    xump_store_request_queue_create (store, &self, name);
</method>

<method name = "fetch" return = "self">
    <doc>
    This public method fetches a queue in the store.  It acts as a
    constructor and returns a new queue object when successful.  The
    caller must unlink this queue object when finished using it.
    </doc>
    <argument name = "store" type = "xump_store_t *">Enclosing store</argument>
    <argument name = "name" type = "char *">Queue name, if any</argument>
    <declare name = "self" type = "$(selftype) *" />
    //
    xump_store_request_queue_fetch (store, &self, name);
</method>

<method name = "delete">
    <doc>
    This public method deletes a queue in the store.  It acts as a
    destructor and nullifies the provided queue object reference.
    The queue object may already be destroyed.
    </doc>
    <argument name = "self_p" type = "$(selftype) **">Queue object ref</argument>
    assert (self_p);
    if (*self_p) {
        xump_store_request_queue_delete ((*self_p)->store, *self_p);
        self_unlink (self_p);
    }
</method>

<method name = "selftest" />

</class>
