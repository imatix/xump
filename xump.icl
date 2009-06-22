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

<method name = "store create" return = "store">
    <doc>
    Creates a new store instance of the specified type, and with the
    specified name.  The caller must unlink the store when finished
    using it.  The store is deleted only at exit; the caller can use
    store_fetch to find it again, by name.  Returns null if the type
    was not valid.
    </doc>
    <argument name = "self" type = "$(selftype) *">Reference to self</argument>
    <argument name = "store type" type = "char *">Name of factory</argument>
    <argument name = "store name" type = "char *">Name of new store</argument>
    <declare name = "store" type = "xump_store_t *" default = "NULL" />
    <local>
    ipr_looseref_t
        *looseref;                      //  Store portals are in looseref list
    </local>
    //
    //  Look for factory and if we find it, create store portal
    looseref = ipr_looseref_list_first (self->xump_store_factory_list);
    while (looseref) {
        xump_store_t
            *factory = (xump_store_t *) (looseref->object);
        if (streq (xump_store_name (factory), store_type)) {
            store = xump_store_factory (factory, store_name);
            break;                  //  Have a match
        }
        looseref = ipr_looseref_list_next (&looseref);
    }
    if (store) {
        xump__xump_store_bind (self, store);
        xump_store_request_announce (store, TRUE);
    }
    //  Todo: we should interrogate the store to find out all the
    //  queues it has, for stores that are persistent.
</method>

<method name = "store fetch" return = "store">
    <doc>
    Returns the named store instance, or NULL if no such store was registered.
    The caller gets a store reference that it must unlink when finished using.
    </doc>
    <argument name = "self" type = "$(selftype) *">Reference to self</argument>
    <argument name = "store name" type = "char *" />
    <declare name = "store" type = "xump_store_t *" default = "NULL" />
    <local>
    ipr_looseref_t
        *looseref;                      //  Store portals are in looseref list
    </local>
    //
    looseref = ipr_looseref_list_first (self->xump_store_list);
    while (looseref) {
        xump_store_t
            *portal = (xump_store_t *) (looseref->object);
        if (streq (xump_store_name (portal), store_name)) {
            store = xump_store_link (portal);
            break;                      //  We've found the matching store
        }
        looseref = ipr_looseref_list_next (&looseref);
    }
</method>

<method name = "store delete" template = "function">
    <doc>
    Delete a store specified by name.  Returns 0 if store was deleted, -1 if
    the store did not exist.
    </doc>
    <argument name = "store name" type = "char *" />
    <local>
    ipr_looseref_t
        *looseref;                      //  Store portals are in looseref list
    </local>
    //
    looseref = ipr_looseref_list_first (self->xump_store_list);
    while (looseref) {
        xump_store_t
            *store = (xump_store_t *) (looseref->object);
        if (streq (xump_store_name (store), store_name)) {
            //  Need to explicitly destroy client looseref, portal
            //  implementation does not do this properly.
            //  Todo: fix portals.
            ipr_looseref_destroy (&store->client_looseref);
            xump_store_request_announce (store, FALSE);
            xump_store_destroy (&store);
            break;                      //  We've found the matching store
        }
        looseref = ipr_looseref_list_next (&looseref);
    }
    if (!looseref)
        rc = -1;                        //  Hit end of list with no match
</method>

<method name = "queue create" return = "queue">
    <doc>
    Create or fetch a queue in a specific store.  This method acts as a queue
    constructor and returns a new queue object when successful.  The caller
    must unlink the returned queue object when finished using it.  If the
    queue name is null, invents a random queue name.
    </doc>
    <argument name = "self" type = "$(selftype) *" />
    <argument name = "store name" type = "char *" />
    <argument name = "queue name" type = "char *" />
    <declare name = "queue" type = "xump_queue_t *" />
    <local>
    xump_store_t
        *store;
    icl_shortstr_t
        random_name;
    </local>
    //
    if (queue_name == NULL) {
        queue_name = random_name;
        do {
            ipr_str_random (queue_name, "Q-AAAAAA");
        } until (ipr_hash_lookup (self->queues, queue_name) == NULL);
    }
    //
    //  Todo: check for and prevent two queues with same name in different
    //  stores.  Requires that self->queues is fully populated.
    store = xump_store_fetch (self, store_name);
    if (store) {
        xump_store_request_queue_create (store, &queue, queue_name);
        //  We track the store for each known queue
        ipr_hash_insert (self->queues, queue_name, store);
        xump_store_unlink (&store);
    }
</method>

<method name = "queue fetch" return = "queue">
    <doc>
    Fetch a queue from any store.  This method acts as a queue constructor
    and returns a new queue object when successful.  The caller must unlink
    the returned queue object when finished using it.
    </doc>
    <argument name = "self" type = "$(selftype) *" />
    <argument name = "queue name" type = "char *" />
    <declare name = "queue" type = "xump_queue_t *" default = "NULL" />
    <local>
    xump_store_t
        *store;
    ipr_looseref_t
        *looseref;                      //  Store portals are in looseref list
    </local>
    //
    //  Check in local queue cache, then ask each store, since queue may
    //  exist from a previous incarnation, if the store is persistent
    store = ipr_hash_lookup (self->queues, queue_name);
    if (store)
        xump_store_request_queue_fetch (store, &queue, queue_name);
    else {
        looseref = ipr_looseref_list_first (self->xump_store_list);
        while (looseref) {
            store = (xump_store_t *) (looseref->object);
            xump_store_request_queue_fetch (store, &queue, queue_name);
            if (queue) {
                //  We track the store for each known queue
                ipr_hash_insert (self->queues, queue_name, store);
                break;                      //  Found our queue
            }
            looseref = ipr_looseref_list_next (&looseref);
        }
    }
</method>

<method name = "queue delete" template = "function">
    <doc>
    Delete a queue specified by name.  Returns 0 if queue was deleted, -1 if
    the queue did not exist.
    </doc>
    <argument name = "queue name" type = "char *" />
    <local>
    xump_queue_t
        *queue;
    </local>
    //
    queue = xump_queue_fetch (self, queue_name);
    if (queue) {
        ipr_hash_delete (self->queues, xump_queue_name (queue));
        xump_store_request_queue_delete (xump_queue_store (queue), queue);
        xump_queue_unlink (&queue);
    }
    else
        rc = -1;
</method>

<method name = "selector create" return = "selector">
    <doc>
    Create a new selector on the specified queue.  This method acts as a
    constructor and returns a new selector object when successful. The caller
    must unlink this selector object when finished using it. Returns null if
    the selector could not be created (no such queue).
    </doc>
    <argument name = "self" type = "$(selftype) *" />
    <argument name = "queue name" type = "char *" />
    <declare name = "selector" type = "xump_selector_t *" default = "NULL" />
    <local>
    xump_queue_t
        *queue;
    </local>
    //
    queue = xump_queue_fetch (self, queue_name);
    if (queue) {
        xump_store_request_selector_create (
            xump_queue_store (queue), queue, &selector);
        xump_queue_unlink (&queue);
    }
</method>

<method name = "selector fetch" return = "selector">
    <doc>
    Fetches a selector from a queue.  This method acts as a constructor and
    returns a new selector object when successful.  The caller must unlink
    this selector object when finished using it.  If the queue or the selector
    does not exist, returns NULL.
    </doc>
    <argument name = "self" type = "$(selftype) *" />
    <argument name = "queue name" type = "char *" />
    <argument name = "id" type = "uint" />
    <declare name = "selector" type = "xump_selector_t *" default = "NULL" />
    <local>
    xump_queue_t
        *queue;
    </local>
    //
    queue = xump_queue_fetch (self, queue_name);
    if (queue) {
        xump_store_request_selector_fetch (
            xump_queue_store (queue), queue, &selector, id);
        xump_queue_unlink (&queue);
    }
</method>

<method name = "selector delete" template = "function">
    <doc>
    Deletes a selector from the queue.  Returns 0 if selector was deleted,
    -1 if the queue or selector did not exist.
    </doc>
    <argument name = "queue name" type = "char *" />
    <argument name = "id" type = "uint" />
    <local>
    xump_queue_t
        *queue;
    xump_selector_t
        *selector;
    </local>
    //
    queue = xump_queue_fetch (self, queue_name);
    if (queue) {
        selector = xump_selector_fetch (self, queue_name, id);
        if (selector) {
            xump_store_request_selector_delete (
                xump_queue_store (queue), selector);
            xump_selector_unlink (&selector);
        }
        else
            rc = -1;
        xump_queue_unlink (&queue);
    }
    else
        rc = -1;
</method>

<method name = "selftest">
    <local>
    xump_t
        *engine;
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
    uint
        selector_id;
    </local>
    //
    //  Create new engine instance
    engine = xump_new ();

    //  Create portal factory for each store implementation
    store = xump_store_ram__xump_store_factory ("RAM");
    xump__xump_store_bind (engine, store);
    xump_store_unlink (&store);

    //  Check portal factory in action
    store = xump_store_create (engine, "ROM", "store-0");
    assert (!store);                    //  ROM is not a defined type
    store = xump_store_create (engine, "RAM", "store-1");
    assert (store);                     //  This should have worked
    xump_store_unlink (&store);

    //  Check we can fetch store by name
    store = xump_store_fetch (engine, "store-0");
    assert (!store);                    //  No such store
    store = xump_store_fetch (engine, "store-1");
    assert (store);                     //  This should have worked

    //  Check queue methods
    queue = xump_queue_create (engine, "store-1", "Test queue");
    assert (queue);
    xump_queue_unlink (&queue);
    queue = xump_queue_fetch (engine, "Test queue");
    assert (queue);
    xump_queue_unlink (&queue);

    assert (xump_queue_delete (engine, "Test queue") == 0);
    assert (xump_queue_delete (engine, "Test queue") == -1);
    queue = xump_queue_fetch (engine, "Test queue");
    assert (queue == NULL);

    //  Check auto-named queue creation
    queue = xump_queue_create (engine, "store-1", NULL);
    assert (queue);
    icl_shortstr_cpy (queue_name, xump_queue_name (queue));
    xump_queue_unlink (&queue);

    assert (xump_queue_delete (engine, queue_name) == 0);
    queue = xump_queue_fetch (engine, queue_name);
    assert (queue == NULL);

    //  Check that we can work with selectors
    icl_shortstr_cpy (queue_name, "queue-001");
    queue = xump_queue_create (engine, "store-1", queue_name);
    selector = xump_selector_create (engine, queue_name);
    assert (selector);
    selector_id = xump_selector_id (selector);
    xump_selector_unlink (&selector);
    selector = xump_selector_fetch (engine, queue_name, selector_id);
    assert (selector);
    xump_selector_unlink (&selector);
    xump_selector_delete (engine, queue_name, selector_id);
    xump_queue_unlink (&queue);

#if 0
    //  Create a queue and post messages to it
    queue = xump_queue_create (engine, "store-1", NULL);
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
    queue = xump_queue_fetch (engine, queue_name);
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
    queue = xump_queue_fetch (engine, queue_name);
    assert (xump_queue_size (queue) == 0);
#endif

    xump_store_unlink (&store);

    //  Check we can delete store by name
    assert (xump_store_delete (engine, "store-1") == 0);
    assert (xump_store_delete (engine, "store-1") == -1);

    xump_destroy (&engine);
</method>

</class>
