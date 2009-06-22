<?xml?>
<!--
    Copyright (c) 1996-2009 iMatix Corporation

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
    name    = "xump_store"
    comment = "Xump store portal"
    script  = "icl_gen"
    >
<doc>
    This class enables the creation of store back-ends.  Store back-ends
    are synchronous classes that implement the request methods defined here.
    Store extensions may be internally multithreaded (i.e. pass requests to
    internally asynchronous objects) but that is invisible to the calling
    application.
</doc>

<inherit class = "ipr_portal">
    <option name = "front_end" value = "sync" />
    <option name = "back_end" value = "sync" />
</inherit>

<import class = "xump" />

<context>
    <property name = "name" type = "char *" readonly = "1" />
</context>

<data>
    <request name = "announce">
        <field name = "opening" type = "Bool">Or, closing</field>
    </request>

    <request name = "queue create">
        <doc>
        Creates a new queue in the store.  If the name is null, generates a
        queue name.  The queue may already exist. Constructs a xump_queue_t
        object, if successful. Returns 0 if OK, -1 if the request failed.
        </doc>
        <field name = "queue_p" type = "xump_queue_t **" />
        <field name = "queue name" type = "char *" />
    </request>

    <request name = "queue fetch">
        <doc>
        Fetches a queue from the store, by name. The queue must exist.
        Constructs a new xump_queue_t object, if successful. Returns 0 if
        OK, -1 if the request failed.
        </doc>
        <field name = "queue_p" type = "xump_queue_t **" />
        <field name = "queue name" type = "char *" />
    </request>

    <request name = "queue delete">
        <doc>
        Deletes a queue in the store.  The caller must already have fetched
        or created the queue. Returns 0 if OK, -1 if the request failed.  The
        queue does not need to exist - delete is idempotent.
        </doc>
        <field name = "queue" type = "xump_queue_t *" />
    </request>

    <request name = "selector create">
        <doc>
        Creates a new selector on the queue.  Constructs a xump_selector_t
        object for the caller.  Returns 0 if OK, -1 if the request failed.
        </doc>
        <field name = "queue" type = "xump_queue_t *" />
        <field name = "selector_p" type = "xump_selector_t **" />
    </request>

    <request name = "selector fetch">
        <doc>
        Fetches a selector by ID.  Constructs a xump_selector_t object for
        the caller.  Returns 0 if OK, -1 if the request failed.
        </doc>
        <field name = "queue" type = "xump_queue_t *" />
        <field name = "selector_p" type = "xump_selector_t **" />
        <field name = "id" type = "uint" />
    </request>

    <request name = "selector delete">
        <doc>
        Deletes a selector from the queue.  The caller must already have
        fetched or created the selector.  Returns 0 if OK, -1 if the request
        failed.  The selector does not need to exist - delete is idempotent.
        </doc>
        <field name = "selector" type = "xump_selector_t *" />
    </request>

    <request name = "message create">
        <doc>
        Creates a new message in the queue.  Constructs a xump_message_t
        object for the caller.  Returns 0 if OK, -1 if the request failed.
        </doc>
        <field name = "queue" type = "xump_queue_t *" />
        <field name = "message_p" type = "xump_message_t **" />
        <field name = "address" type = "char *" />
        <field name = "headers" type = "xump_headers_t *" />
        <field name = "body data" type = "void *" />
        <field name = "body size" type = "size_t" />
    </request>

    <request name = "message fetch">
        <doc>
        Fetches a message from the queue.  Constructs a xump_message_t
        object for the caller.  Returns 0 if OK, -1 if the request failed.
        Index is offset from the head of the queue.
        </doc>
        <field name = "queue" type = "xump_queue_t *" />
        <field name = "message_p" type = "xump_message_t **" />
        <field name = "index" type = "size_t" />
    </request>

    <request name = "message delete">
        <doc>
        Deletes a message from the queue.  The caller must already have
        fetched or created the message.  Returns 0 if OK, -1 if the request
        failed.  The message does not need to exist - delete is idempotent.
        </doc>
        <field name = "message" type = "xump_message_t *" />
    </request>
</data>

<method name = "new">
    <doc>
    Creates a new store instance object.
    </doc>
    <argument name = "name" type = "char *" />
    //
    self->name = icl_mem_strdup (name);
</method>

<method name = "destroy">
    icl_mem_free (self->name);
</method>

</class>
