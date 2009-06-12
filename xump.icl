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
    name      = "xump"
    comment   = "Xump engine class"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The xump class implements the Xump engine.  To use Xump, create an instance
of this class.
</doc>

<inherit class = "xump_store_front" />

<!-- We import all project classes, so xump.h acts as the library header -->
<import class = "asl" />
<import class = "xump_store" />
<import class = "xump_queue" />
<import class = "xump_message" />
<import class = "xump_selector" />
<import class = "xump_headers" />
<import class = "xump_store_ram" />
<import class = "xump_store_ram_queue" />
<import class = "xump_store_ram_message" />
<import class = "xump_store_ram_selector" />

<context>
    ipr_hash_table_t
        *queues;                        //  Queues that engine manages
</context>

<method name = "new">
    <doc>
    Creates a new Xump engine instance.  Xump engines are unnamed containers
    for stores and the resources they contain.
    </doc>
    self->queues = ipr_hash_table_new ();
</method>

<method name = "destroy">
    ipr_hash_table_destroy (&self->queues);
</method>

<method name = "set store" template = "function">
    <doc>
    Registers a store instance with the engine.  The caller is responsible
    for creating the store using a xump_store_xyz_xump_store_new () method.
    The engine will automatically destroy the store instance at shutdown
    time.
    </doc>
    <argument name = "store" type = "xump_store_t *" />
    //
    xump__xump_store_bind (self, store);
    xump_store_request_announce (store);
    xump_store_unlink (&store);
</method>

<method name = "store" return = "store">
    <doc>
    Returns the named store instance, or NULL if no such store was registered.
    </doc>
    <argument name = "self" type = "$(selftype) *">Reference to self</argument>
    <argument name = "name" type = "char *" />
    <declare name = "store" type = "xump_store_t *" default = "NULL" />
    <local>
    ipr_looseref_t
        *looseref;                      //  Store portals are in looseref list
    </local>
    //
    looseref = ipr_looseref_list_first (self->xump_store_list);
    while (looseref) {
        store = (xump_store_t *) (looseref->object);
        if (streq (store->name, name))
            break;                      //  We've found the matching store
        store = NULL;
        looseref = ipr_looseref_list_next (&looseref);
    }
</method>

<method name = "cache queue lookup" return = "queue">
    <doc>
    Looks for a queue among all store instances, using the queue name
    cache.  Returns a new xump_queue object, or NULL.
    </doc>
    <argument name = "self" type = "$(selftype) *" />
    <argument name = "name" type = "char *" />
    <declare name = "queue" type = "xump_queue_t *" default = "NULL" />
    <local>
    xump_store_t
        *store;
    ipr_looseref_t
        *looseref;                      //  Store portals are in looseref list
    </local>
    //
    //  Check in local queue cache, then ask each store
    store = ipr_hash_lookup (self->queues, name);
    if (store) {
        queue = xump_queue_fetch (store, name);
        icl_console_print ("Queue found in store");
    }
    else {
        looseref = ipr_looseref_list_first (self->xump_store_list);
        while (looseref) {
            store = (xump_store_t *) (looseref->object);
            queue = xump_queue_fetch (store, name);
            if (queue) {
                icl_console_print ("Queue found by store");
                break;                      //  Found our queue
            }
            looseref = ipr_looseref_list_next (&looseref);
        }
    }
</method>

<method name = "selftest">
    <local>
    xump_t
        *xump;
    xump_store_t
        *store;
    xump_queue_t
        *queue;
    xump_message_t
        *message;
    xump_selector_t
        *selector;
    icl_shortstr_t
        queue_name;
    int count;
    </local>
    //
    xump = xump_new ();
    xump_set_store (xump, xump_store_ram__xump_store_new (NULL, "RAM1"));
    xump_set_store (xump, xump_store_ram__xump_store_new (NULL, "RAM2"));

    assert (xump_store (xump, "RAM1") != NULL);
    assert (xump_store (xump, "RAM0") == NULL);
    store = xump_store (xump, "RAM1");

    //  Check that the methods work
    queue = xump_queue_create (store, "Test queue");
    assert (queue);
    xump_queue_unlink (&queue);

    queue = xump_queue_fetch (store, "Test queue");
    assert (queue);
    xump_queue_delete (&queue);
    assert (queue == NULL);
    queue = xump_queue_fetch (store, "Test queue");
    assert (queue == NULL);

    //  Check methods on auto-named queue
    queue = xump_queue_create (store, NULL);
    assert (queue);
    icl_shortstr_cpy (queue_name, xump_queue_name (queue));
    xump_queue_unlink (&queue);

    queue = xump_queue_fetch (store, queue_name);
    assert (queue);
    xump_queue_delete (&queue);
    assert (queue == NULL);
    queue = xump_queue_fetch (store, queue_name);
    assert (queue == NULL);

    //  Create a queue and post messages to it
    queue = xump_queue_create (store, NULL);
    icl_shortstr_cpy (queue_name, xump_queue_name (queue));
    message = xump_message_create (queue, "address1", NULL, "abc", 4);
    xump_message_unlink (&message);
    message = xump_message_create (queue, "address2", NULL, "def", 4);
    xump_message_unlink (&message);

    //  Check that we can fetch messages off the queue
    message = xump_message_fetch (queue, 0);
    assert (message);
    assert (streq (xump_message_address (message), "address1"));
    xump_message_unlink (&message);

    message = xump_message_fetch (queue, 1);
    assert (message);
    assert (streq (xump_message_address (message), "address2"));
    xump_message_unlink (&message);

    xump_queue_unlink (&queue);

    //  Delete the messages and check they are gone
    queue = xump_queue_fetch (store, queue_name);
    assert (xump_queue_size (queue) == 2);

    message = xump_message_fetch (queue, 0);
    assert (message);
    xump_message_delete (&message);

    message = xump_message_fetch (queue, 0);
    assert (message);
    xump_message_delete (&message);

    message = xump_message_fetch (queue, 0);
    assert (message == NULL);
    xump_queue_unlink (&queue);
    queue = xump_queue_fetch (store, queue_name);
    assert (xump_queue_size (queue) == 0);

    //  Check that we can work with selectors
    selector = xump_selector_create (queue, "dest", "EQ", "address", XUMP_SELECTOR_COPY);
    assert (selector);
    xump_selector_unlink (&selector);
    selector = xump_selector_fetch (queue, 0);
    assert (selector);
    assert (xump_selector_operation (selector) == XUMP_SELECTOR_COPY);
    xump_selector_delete (&selector);
    xump_queue_unlink (&queue);

    //  Check engine API
    queue = xump_cache_queue_lookup (xump, queue_name);
    assert (queue);
    assert (streq (xump_queue_name (queue), queue_name));
    xump_queue_unlink (&queue);

    xump_destroy (&xump);
</method>

</class>
