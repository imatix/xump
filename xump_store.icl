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

<import class = "asl" />
<import class = "xump" />

<context>
    icl_shortstr_t
        name;                           //  Store name
</context>

<data>
    <request name = "announce" />

    <request name = "queue create">
        <doc>
        Creates a new queue in the store.  If the name is null, generates a
        queue name.  The queue may already exist. Returns 0 if OK, -1 if the
        request failed.
        </doc>
        <field name = "queue" type = "xump_queue_t *">Queue object</field>
    </request>
    <request name = "queue fetch">
        <doc>
        Fetches a queue from the store, by name. Returns 0 if OK, -1 if the
        request failed.
        </doc>
        <field name = "queue" type = "xump_queue_t *">Queue object</field>
    </request>
    <request name = "queue update">
        <doc>
        Updates a queue in the store.  The caller must previous have fetched
        or created the queue. Returns 0 if OK, -1 if the request failed.
        </doc>
        <field name = "queue" type = "xump_queue_t *">Queue object</field>
    </request>
    <request name = "queue delete">
        <doc>
        Deletes a queue in the store.  The caller must previous have fetched
        or created the queue. Returns 0 if OK, -1 if the request failed.
        </doc>
        <field name = "queue" type = "xump_queue_t *">Queue object</field>
    </request>
</data>

<method name = "new">
    <doc>
    Creates a new store instance object.
    </doc>
    <argument name = "name" type = "char *" />
    icl_shortstr_cpy (self->name, name);
</method>

</class>
