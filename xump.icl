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
<import class = "xump_store_ram" />

<context>
</context>

<method name = "new">
    <doc>
    Creates a new Xump engine instance.  Xump engines are unnamed containers
    for stores.
    </doc>
    <local>
    xump_store_t
        *store;
    </local>
    //
    //  Register RAM storage back-end
    store = xump_store_ram__xump_store_new (NULL, "RAM");
    xump__xump_store_bind (self, store);
    xump_store_request_announce (store);
    xump_store_unlink (&store);
</method>

<method name = "destroy">
</method>

<method name = "selftest">
    <local>
    xump_t
        *xump;
    </local>
    //
    xump = xump_new ();
    xump_destroy (&xump);
</method>

</class>
