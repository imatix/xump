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
    name      = "xump_store_ram_message"
    comment   = "Xump message class for RAM storage layer"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The RAM storage layer uses this class to implement messages.
</doc>

<inherit class = "icl_object">
    <option name = "alloc" value = "cache" />
</inherit>

<import class = "xump" />

<context readonly = "1">
    <property name = "id" type = "size_t" readonly = "0" />
    <property name = "address" type = "char *" />
    <property name = "headers" type = "xump_headers_t *" />
    <property name = "body data" type = "void *" />
    <property name = "body size" type = "size_t" />
</context>

<method name = "new">
    <argument name = "address" type = "char *">Message address, if any</argument>
    <argument name = "headers" type = "xump_headers_t *">Message headers, if any</argument>
    <argument name = "body data" type = "void *">Body data if any</argument>
    <argument name = "body size" type = "size_t">Size of body</argument>
    //
    self->address = icl_mem_strdup (address);
    self->headers = xump_headers_link (headers);
    if (body_size) {
        self->body_size = body_size;
        self->body_data = icl_mem_alloc (body_size);
        memcpy (self->body_data, body_data, body_size);
    }
</method>

<method name = "destroy">
    xump_headers_unlink (&self->headers);
    icl_mem_free (self->address);
    icl_mem_free (self->body_data);
</method>

<method name = "selftest" />

</class>
