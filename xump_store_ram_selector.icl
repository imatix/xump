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
    name      = "xump_store_ram_selector"
    comment   = "Xump selector class for RAM storage layer"
    script    = "icl_gen"
    license   = "gpl"
    opaque    = "1"
    >
<doc>
The RAM storage layer uses this class to implement selectors. Note:
probably needs addition of headers object for header based routing.
</doc>

<inherit class = "icl_object">
    <option name = "alloc" value = "cache" />
</inherit>

<import class = "xump" />

<context readonly = "1">
    <property name = "id" type = "size_t" readonly = "0" />
    <property name = "destination" type = "char *" />
    <property name = "match type" type = "char *" />
    <property name = "match arg" type = "char *" />
    <property name = "operation" type = "int" />
    <property name = "credit" type = "int" />
</context>

<method name = "new">
    <argument name = "destination" type = "char *" />
    <argument name = "match type" type = "char *" />
    <argument name = "match arg" type = "char *" />
    <argument name = "operation" type = "int" />
    //
    self->destination = icl_mem_strdup (destination);
    self->match_type = icl_mem_strdup (match_type);
    self->match_arg = icl_mem_strdup (match_arg);
    self->operation = operation;
</method>

<method name = "destroy">
    icl_mem_free (self->destination);
    icl_mem_free (self->match_type);
    icl_mem_free (self->match_arg);
</method>

<method name = "selftest" />

</class>
