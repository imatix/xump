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
</doc>

<inherit class = "icl_object">
    <option name = "alloc" value = "cache" />
    <option name = "links" value = "1" />
</inherit>

<import class = "xump" />

<context readonly = "1">
    int64_t
        last_id;
    <property name = "store" type = "xump_store_t *" />
    <property name = "name" type = "char *" />
    <property name = "size" type = "size_t" />
    <property name = "context" type = "void *" readonly = "0" >
      Caller-defined context block, allocated by caller from heap
      <put>
        icl_mem_free (self->context);
        self->context = context;
      </put>
    </property>
</context>

<method name = "new">
    <argument name = "store" type = "xump_store_t *">Enclosing store</argument>
    <argument name = "name" type = "char *">Queue name, if any</argument>
    <argument name = "size" type = "size_t">Queue size</argument>
    //
    self->store = xump_store_link (store);
    self->name = icl_mem_strdup (name);
    self->size = size;
</method>

<method name = "destroy">
    xump_store_unlink (&self->store);
    icl_mem_free (self->name);
    icl_mem_free (self->context);
</method>

<method name = "selftest" />

</class>
