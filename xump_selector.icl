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
    name      = "xump_selector"
    comment   = "Xump selector class"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The xump_selector class references a selector resource held in a storage
layer. This class implements the create/fetch/delete access methods on the
selector. Note: probably needs addition of headers object for header based
routing.
</doc>

<todo>Queue reference must be name, not object</todo>

<inherit class = "icl_object">
    <option name = "alloc" value = "cache" />
    <option name = "links" value = "1" />
</inherit>

<import class = "xump" />

<public name = "header">
#define XUMP_SELECTOR_COPY           1      //  Operation
#define XUMP_SELECTOR_MOVE           2      //  Operation
#define XUMP_SELECTOR_INFINITE      -1      //  Credit
</public>

<context readonly = "1">
    <property name = "id" type = "size_t" readonly = "0" />
    <property name = "store" type = "xump_store_t *" />
    <property name = "queue" type = "xump_queue_t *" />
    <property name = "destination" type = "char *" />
    <property name = "match type" type = "char *" />
    <property name = "match arg" type = "char *" />
    <property name = "operation" type = "int" />
    <property name = "credit" type = "int" />
</context>

<method name = "new">
    <argument name = "queue" type = "xump_queue_t *" />
    <argument name = "destination" type = "char *" />
    <argument name = "match type" type = "char *" />
    <argument name = "match arg" type = "char *" />
    <argument name = "operation" type = "int" />
    //
    self->store = xump_store_link (xump_queue_store (queue));
    self->queue = xump_queue_link (queue);
    self->destination = icl_mem_strdup (destination);
    self->match_type = icl_mem_strdup (match_type);
    self->match_arg = icl_mem_strdup (match_arg);
    self->operation = operation;
</method>

<method name = "destroy" private = "1">
    xump_store_unlink (&self->store);
    xump_queue_unlink (&self->queue);
    icl_mem_free (self->destination);
    icl_mem_free (self->match_type);
    icl_mem_free (self->match_arg);
</method>

<method name = "create" return = "self">
    <doc>
    This public method defines a new selector for to the queue.  It acts
    as a constructor and returns a new selector object when successful.
    The caller must unlink this selector object when finished using it.
    </doc>
    <argument name = "queue" type = "xump_queue_t *" />
    <argument name = "destination" type = "char *" />
    <argument name = "match type" type = "char *" />
    <argument name = "match arg" type = "char *" />
    <argument name = "operation" type = "int" />
    <declare name = "self" type = "$(selftype) *" />
    //
    xump_store_request_selector_create (xump_queue_store (queue),
        queue, &self, destination, match_type, match_arg, operation);
</method>

<method name = "fetch" return = "self">
    <doc>
    This public method fetches a selector from a queue.  It acts as a
    constructor and returns a new selector object when successful.  The
    caller must unlink this selector object when finished using it. The
    index is 0 or higher.
    </doc>
    <argument name = "queue" type = "xump_queue_t *">Enclosing queue</argument>
    <argument name = "index" type = "size_t">Selector ndex</argument>
    <declare name = "self" type = "$(selftype) *" />
    //
    xump_store_request_selector_fetch (xump_queue_store (queue),
        queue, &self, index);
</method>

<method name = "delete">
    <doc>
    This public method deletes a selector from the queue.  It acts as
    a destructor and nullifies the provided selector object reference.
    The selector object may already be destroyed.
    </doc>
    <argument name = "self_p" type = "$(selftype) **">Selector object ref</argument>
    assert (self_p);
    if (*self_p) {
        xump_store_request_selector_delete ((*self_p)->store, *self_p);
        self_unlink (self_p);
    }
</method>

<method name = "add credit" template = "function">
    <doc>
    This public method grants credit to a selector.  Credit is measured in
    messages.
    </doc>
    <argument name = "amount" type = "size_t" />
    //
    self->credit += amount;
    xump_store_request_selector_add_credit (self->store, self, amount);
</method>

<method name = "eq" template = "function">
    <doc>
    Returns TRUE if the two specified selectors are equal.
    </doc>
    <argument name = "selector" type = "xump_selector_t *" />
    //
    if (self->queue == xump_selector_queue (selector)
    &&  streq (self->destination, xump_selector_destination (selector))
    &&  streq (self->match_type, xump_selector_match_type (selector))
    &&  streq (self->match_arg, xump_selector_match_arg (selector))
    &&  self->operation == xump_selector_operation (selector))
        rc = TRUE;
    else
        rc = FALSE;
</method>

<method name = "selftest" />

</class>
