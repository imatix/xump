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
    name      = "xump_message"
    comment   = "Xump message class"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The xump_message class references a message resource held in a storage layer.
This class implements the create/fetch/delete access methods on the message.
</doc>

<inherit class = "icl_object">
    <option name = "alloc" value = "cache" />
    <option name = "links" value = "1" />
</inherit>

<todo>Queue reference must be name, not object</todo>

<import class = "xump" />

<context readonly = "1">
    <property name = "id" type = "size_t" readonly = "0" />
    <property name = "store" type = "xump_store_t *" />
    <property name = "queue" type = "xump_queue_t *" />
    <property name = "address" type = "char *" />
    <property name = "headers" type = "xump_headers_t *" />
    <property name = "body data" type = "void *" />
    <property name = "body size" type = "size_t" />
    <property name = "context" type = "void *" readonly = "0" >
      Caller-defined context block, allocated by caller from heap
      <put>
        icl_mem_free (self->context);
        self->context = context;
      </put>
    </property>
</context>

<method name = "new">
    <argument name = "queue" type = "xump_queue_t *">Enclosing queue</argument>
    <argument name = "address" type = "char *">Address, if any</argument>
    <argument name = "headers" type = "xump_headers_t *">Message headers, if any</argument>
    <argument name = "body data" type = "void *">Body data if any</argument>
    <argument name = "body size" type = "size_t">Size of body</argument>
    //
    self->store = xump_store_link (xump_queue_store (queue));
    self->queue = xump_queue_link (queue);
    self->address = icl_mem_strdup (address);
    self->headers = xump_headers_link (headers);
    if (body_size) {
        assert (body_data);
        self->body_data = icl_mem_alloc (body_size);
        self->body_size = body_size;
        memcpy (self->body_data, body_data, body_size);
    }
</method>

<method name = "destroy" private = "1">
    xump_store_unlink (&self->store);
    xump_queue_unlink (&self->queue);
    xump_headers_unlink (&self->headers);
    icl_mem_free (self->address);
    icl_mem_free (self->body_data);
    icl_mem_free (self->context);
</method>

<method name = "create" return = "self">
    <doc>
    This public method adds a new message to the end of the queue.  It acts
    as a constructor and returns a new message object when successful.  The
    caller must unlink this message object when finished using it.
    </doc>
    <argument name = "queue" type = "xump_queue_t *">Enclosing queue</argument>
    <argument name = "address" type = "char *">Message address, if any</argument>
    <argument name = "headers" type = "xump_headers_t *">Message headers, if any</argument>
    <argument name = "body data" type = "void *">Body data if any</argument>
    <argument name = "body size" type = "size_t">Size of body</argument>
    <declare name = "self" type = "$(selftype) *" />
    //
    xump_store_request_message_create (xump_queue_store (queue),
        queue, &self, address, headers, body_data, body_size);
</method>

<method name = "fetch" return = "self">
    <doc>
    This public method fetches a message from a queue.  It acts as a
    constructor and returns a new message object when successful.  The
    caller must unlink this message object when finished using it.  The
    index is 0 or higher, indicating an offset from the head of the queue.
    </doc>
    <argument name = "queue" type = "xump_queue_t *">Enclosing queue</argument>
    <argument name = "index" type = "size_t">Message index</argument>
    <declare name = "self" type = "$(selftype) *" />
    //
    xump_store_request_message_fetch (xump_queue_store (queue),
        queue, &self, index);
</method>

<method name = "delete">
    <doc>
    This public method deletes a message in the queue.  It acts as a
    destructor and nullifies the provided message object reference.
    The message object may already be destroyed.
    </doc>
    <argument name = "self_p" type = "$(selftype) **">Message object ref</argument>
    assert (self_p);
    if (*self_p) {
        xump_store_request_message_delete ((*self_p)->store, *self_p);
        self_unlink (self_p);
    }
</method>

<method name = "selftest" />

</class>
