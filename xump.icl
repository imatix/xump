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

<import class = "asl" />
<import class = "xump_store" />
<import class = "xump_store_ram" />
<import class = "xump_queue" />

<context>
    <property name = "store" type = "xump_store_t *" readonly = "1" />
</context>

<method name = "new">
    <doc>
    Creates a new Xump engine instance.  Xump engines are unnamed containers
    for stores.  For now we create one store instance.
    </doc>
    <local>
    </local>
    //
    //  Register RAM storage back-end
    self->store = xump_store_ram__xump_store_new (NULL, "RAM");
    xump__xump_store_bind (self, self->store);
    xump_store_request_announce (self->store);
</method>

<method name = "destroy">
    xump_store_unlink (&self->store);
</method>

<method name = "selftest">
    <local>
    xump_t
        *xump;
    xump_queue_t
        *queue;
    int
        rc;
    int count1, count2;
    </local>
    //
    xump = xump_new ();

    queue = xump_queue_new (xump_store (xump), "Test queue");

    for (count1 = 0; count1 < 1000000; count1++) {
        for (count2 = 0; count2 < 1000; count2++) {
            rc = xump_queue_create (queue);
        }
    }
    assert (rc == -1);
    rc = xump_queue_fetch (queue);
    assert (rc == -1);
    rc = xump_queue_update (queue);
    assert (rc == -1);
    rc = xump_queue_delete (queue);
    assert (rc == -1);
    xump_queue_destroy (&queue);

    xump_destroy (&xump);
</method>

</class>
