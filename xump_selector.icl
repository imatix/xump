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
layer. Note: probably needs addition of headers object for header based
routing.
</doc>

<inherit class = "icl_object">
    <option name = "alloc" value = "cache" />
    <option name = "links" value = "1" />
</inherit>

<import class = "xump" />

<context readonly = "1">
    <property name = "id" type = "uint" />
    <property name = "queue name" type = "char *" />
    <property name = "credit" type = "uint" />
</context>

<method name = "new">
    <argument name = "queue name" type = "char *" />
    <argument name = "id" type = "uint" />
    //
    self->id = id;
    self->queue_name = icl_mem_strdup (queue_name);
</method>

<method name = "destroy" private = "1">
    icl_mem_free (self->queue_name);
</method>

<method name = "selftest" />

</class>
